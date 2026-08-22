import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/features/profile/user_profile_model.dart';
import 'package:blink/features/profile/nigerian_universities.dart'; // kNigerianUniversities — generated from the xlsx list
import 'package:blink/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile; // pass a `.clone()` in so cancel doesn't mutate the caller's copy
  final bool isDark;

  const EditProfileScreen({super.key, required this.profile, required this.isDark});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

const List<String> kAcademicLevels = ['100L', '200L', '300L', '400L', '500L', '600L', 'Post-grad', 'Alumni'];

/// Common pronoun presets — "Custom" reveals a free-text field for anything
/// not on the list.
const List<String> kPronounPresets = ['She/Her', 'He/Him', 'They/Them', 'She/They', 'He/They', 'Prefer not to say', 'Custom'];

/// Departments shown when no faculty-specific list is wired up yet.
/// Swap for a real faculty -> departments map when available.
const List<String> kDepartmentPresets = [
  'Computer Science', 'Electrical/Electronic Engineering', 'Mechanical Engineering', 'Civil Engineering',
  'Chemical Engineering', 'Petroleum Engineering', 'Biochemistry', 'Microbiology', 'Physics', 'Mathematics',
  'Economics', 'Accounting', 'Business Administration', 'Law', 'Medicine and Surgery', 'Mass Communication',
  'Architecture', 'Pharmacy', 'Nursing Science', 'Psychology', 'Other',
];

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late UserProfile p = widget.profile;

  // Page-entrance animation: gentle fade + rise for the whole form when the
  // screen first appears.
  late final AnimationController _entranceCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();
  late final Animation<double> _entranceFade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic);
  late final Animation<Offset> _entranceSlide =
      Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_entranceFade);

  // Controllers for plain text fields.
  late final _fullName = TextEditingController(text: p.fullName);
  late final _username = TextEditingController(text: p.username);
  late final _pronounsCustom = TextEditingController(
    text: kPronounPresets.contains(p.pronouns) ? '' : p.pronouns,
  );
  late final _departmentCustom = TextEditingController(
    text: kDepartmentPresets.contains(p.department) ? '' : p.department,
  );
  late final _courseOfStudy = TextEditingController(text: p.courseOfStudy);
  late final _graduationYear = TextEditingController(text: p.graduationYear);
  late final _headline = TextEditingController(text: p.professionalHeadline);
  late final _jobTitle = TextEditingController(text: p.currentJobTitle);
  late final _email = TextEditingController(text: p.email.value);
  late final _phone = TextEditingController(text: p.phone.value);
  late final _country = TextEditingController(text: p.countryOfOrigin);
  late final _city = TextEditingController(text: p.currentCityState);
  late final _hostel = TextEditingController(text: p.campusHostelLocation);
  late final _bio = TextEditingController(text: p.bio);
  late final _quote = TextEditingController(text: p.favoriteQuote);
  late final _status = TextEditingController(text: p.customStatus);
  late final _website = TextEditingController(text: p.links.website);
  late final _linkedin = TextEditingController(text: p.links.linkedin);
  late final _twitter = TextEditingController(text: p.links.twitter);
  late final _instagram = TextEditingController(text: p.links.instagram);
  late final _featuredLink = TextEditingController(text: p.links.featuredLink);
  late final _featuredLinkLabel = TextEditingController(text: p.links.featuredLinkLabel);

  // Dropdown-backed fields that aren't plain text controllers.
  late String? _pronounChoice = kPronounPresets.contains(p.pronouns) ? p.pronouns : (p.pronouns.isEmpty ? null : 'Custom');
  late String? _departmentChoice = kDepartmentPresets.contains(p.department) ? p.department : (p.department.isEmpty ? null : 'Other');

  static const List<int> _accentSwatches = [0xFFFF006E, 0xFF7C3AED, 0xFF2563EB, 0xFF059669, 0xFFF59E0B, 0xFFDC2626];

  bool _saving = false;
  @override
  void dispose() {
    for (final c in [
      _fullName, _username, _pronounsCustom, _departmentCustom, _courseOfStudy, _graduationYear,
      _headline, _jobTitle, _email, _phone, _country, _city, _hostel, _bio, _quote,
      _status, _website, _linkedin, _twitter, _instagram, _featuredLink, _featuredLinkLabel,
    ]) {
      c.dispose();
    }
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    p
      ..fullName = _fullName.text.trim()
      ..username = _username.text.trim()
      ..pronouns = _pronounChoice == 'Custom' ? _pronounsCustom.text.trim() : (_pronounChoice ?? '')
      ..department = _departmentChoice == 'Other' ? _departmentCustom.text.trim() : (_departmentChoice ?? '')
      ..courseOfStudy = _courseOfStudy.text.trim()
      ..graduationYear = _graduationYear.text.trim()
      ..professionalHeadline = _headline.text.trim()
      ..currentJobTitle = _jobTitle.text.trim()
      ..countryOfOrigin = _country.text.trim()
      ..currentCityState = _city.text.trim()
      ..campusHostelLocation = _hostel.text.trim()
      ..bio = _bio.text.trim()
      ..favoriteQuote = _quote.text.trim()
      ..customStatus = _status.text.trim();
    p.email.value = _email.text.trim();
    p.phone.value = _phone.text.trim();
    p.links
      ..website = _website.text.trim()
      ..linkedin = _linkedin.text.trim()
      ..twitter = _twitter.text.trim()
      ..instagram = _instagram.text.trim()
      ..featuredLink = _featuredLink.text.trim()
      ..featuredLinkLabel = _featuredLinkLabel.text.trim();

    // This used to just pop `p` back to the caller — it never touched
    // Supabase, so edits only ever lived in memory for the current
    // session and were gone on next launch. Now it actually persists.
    setState(() => _saving = true);
    final ok = await ProfileService.updateProfile(p);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop(p);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save to Supabase — check your connection and try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: txt,
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: _saving
                  ? const SizedBox(
                      key: ValueKey('appbar_saving'),
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save', key: ValueKey('appbar_save_text'), style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: FadeTransition(
          opacity: _entranceFade,
          child: SlideTransition(
            position: _entranceSlide,
            child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _StaggerFadeIn(
              index: 0,
              child: _AvatarCoverPicker(
                profile: p,
                isDark: isDark,
                onAvatarUploaded: (url) => setState(() => p.avatar = url),
                onCoverUploaded: (url) => setState(() => p.coverPhoto = url),
              ),
            ),
            const SizedBox(height: 24),

            _StaggerFadeIn(index: 1, child: _Section(title: 'Core Identity', txt: txt, children: [
              _text(_fullName, 'Full legal name', icon: Icons.badge_outlined, validator: _required),
              _text(_username, 'Username', icon: Icons.alternate_email, prefixText: '@', validator: _required),
              _DropdownField<String>(
                label: 'Pronouns',
                icon: Icons.person_outline,
                value: _pronounChoice,
                items: kPronounPresets,
                itemLabel: (v) => v,
                onChanged: (v) => setState(() => _pronounChoice = v),
                isDark: isDark,
              ),
              if (_pronounChoice == 'Custom') _text(_pronounsCustom, 'Enter your pronouns', icon: Icons.edit_outlined, hint: 'e.g. Ze/Zir'),
              // Verification is earned automatically once you hit the platform's
              // requirements — it isn't something you set here.
              if (p.isEligibleForVerification)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 16, color: p.verification == VerificationBadge.gold ? const Color(0xFFFFC53D) : const Color(0xFF1D9BF0)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Verified — awarded automatically for meeting platform requirements', style: TextStyle(fontSize: 11, color: muted))),
                    ],
                  ),
                ),
            ])),

            _StaggerFadeIn(index: 2, child: _Section(title: 'Academic & Professional', txt: txt, children: [
              _UniversityPicker(
                initial: p.university,
                onSelected: (v) => p.university = v,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _FacultyDropdown(
                value: p.faculty.isEmpty ? null : p.faculty,
                onChanged: (v) => setState(() => p.faculty = v ?? ''),
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              _DropdownField<String>(
                label: 'Department',
                icon: Icons.account_balance_outlined,
                value: _departmentChoice,
                items: kDepartmentPresets,
                itemLabel: (v) => v,
                onChanged: (v) => setState(() => _departmentChoice = v),
                isDark: isDark,
              ),
              if (_departmentChoice == 'Other') _text(_departmentCustom, 'Enter your department', icon: Icons.edit_outlined),
              _text(_courseOfStudy, 'Course of study / Major', icon: Icons.menu_book_outlined),
              _DropdownField<String>(
                label: 'Academic level',
                icon: Icons.stairs_outlined,
                value: p.academicLevel.isEmpty ? null : p.academicLevel,
                items: kAcademicLevels,
                itemLabel: (v) => v,
                onChanged: (v) => setState(() => p.academicLevel = v ?? ''),
                isDark: isDark,
              ),
              _text(_graduationYear, 'Graduation year / Class of', icon: Icons.event_outlined, hint: 'e.g. Class of 2027'),
              _text(_headline, 'Professional headline', icon: Icons.short_text, hint: 'One-liner under your name'),
              _text(_jobTitle, 'Current job title / internship', icon: Icons.work_outline),
              _ReadOnlyRankRow(worldRank: p.worldRank, campusRank: p.campusRank, txt: txt, muted: muted),
              const SizedBox(height: 6),
              _ChipEditor(
                label: 'Core skills / tech stack',
                icon: Icons.psychology_outlined,
                values: p.coreSkills,
                isDark: isDark,
                onChanged: (v) => setState(() => p.coreSkills = v),
              ),
            ])),

            _StaggerFadeIn(index: 3, child: _Section(title: 'Contact & Location', txt: txt, children: [
              _text(
                _email,
                'Email address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                trailing: _VisibilityToggle(
                  isPublic: p.email.isPublic,
                  onChanged: (v) => setState(() => p.email.visibility = v ? FieldVisibility.public : FieldVisibility.private),
                ),
              ),
              _text(
                _phone,
                'Phone number',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                trailing: _VisibilityToggle(
                  isPublic: p.phone.isPublic,
                  onChanged: (v) => setState(() => p.phone.visibility = v ? FieldVisibility.public : FieldVisibility.private),
                ),
              ),
              _text(_country, 'Country of origin', icon: Icons.flag_outlined, hint: 'e.g. 🇳🇬 Nigeria'),
              _text(_city, 'Current city / state', icon: Icons.location_on_outlined),
              _text(_hostel, 'Campus / hostel location', icon: Icons.other_houses_outlined),
              _DropdownField<AvailabilityStatus>(
                label: 'Availability status',
                icon: Icons.bolt_outlined,
                value: p.availability,
                items: AvailabilityStatus.values,
                itemLabel: (v) => v.label,
                onChanged: (v) => setState(() => p.availability = v ?? AvailabilityStatus.none),
                isDark: isDark,
              ),
            ])),

            _StaggerFadeIn(index: 4, child: _Section(title: 'Personal Details & Expression', txt: txt, children: [
              _text(_bio, 'Short bio / about me', icon: Icons.info_outline, maxLines: 3),
              _DropdownField<Gender>(
                label: 'Gender',
                icon: Icons.wc_outlined,
                value: p.gender,
                items: Gender.values,
                itemLabel: (v) => v.label,
                onChanged: (v) => setState(() => p.gender = v ?? Gender.preferNotToSay),
                isDark: isDark,
              ),
              _DobPicker(
                value: p.dob.value,
                isPublic: p.dob.isPublic,
                onDateChanged: (d) => setState(() => p.dob.value = d),
                onVisibilityChanged: (v) => setState(() => p.dob.visibility = v ? FieldVisibility.public : FieldVisibility.private),
                txt: txt,
                muted: muted,
                isDark: isDark,
              ),
              _DropdownField<RelationshipStatus>(
                label: 'Relationship status',
                icon: Icons.favorite_border,
                value: p.relationshipStatus,
                items: RelationshipStatus.values,
                itemLabel: (v) => v.label,
                onChanged: (v) => setState(() => p.relationshipStatus = v ?? RelationshipStatus.preferNotToSay),
                isDark: isDark,
              ),
              _ChipEditor(
                label: 'Hobbies & interests',
                icon: Icons.sports_esports_outlined,
                values: p.hobbies,
                isDark: isDark,
                onChanged: (v) => setState(() => p.hobbies = v),
              ),
              _ChipEditor(
                label: 'Spoken languages',
                icon: Icons.translate,
                values: p.languages,
                isDark: isDark,
                onChanged: (v) => setState(() => p.languages = v),
              ),
              _text(_quote, 'Favorite quote / life motto', icon: Icons.format_quote_outlined),
              _text(_status, 'Custom status message', icon: Icons.chat_bubble_outline, hint: 'e.g. Studying for exams 📚'),
            ])),

            _StaggerFadeIn(index: 5, child: _Section(title: 'Social Connections & Links', txt: txt, children: [
              _text(_website, 'Personal portfolio / website', icon: Icons.link, keyboardType: TextInputType.url),
              _text(_linkedin, 'LinkedIn profile URL', icon: Icons.business_center_outlined, keyboardType: TextInputType.url),
              _text(_twitter, 'Twitter / X handle', icon: Icons.alternate_email),
              _text(_instagram, 'Instagram handle', icon: Icons.camera_alt_outlined),
              _text(_featuredLink, 'Featured link (e.g. Linktree)', icon: Icons.star_outline, keyboardType: TextInputType.url),
              _text(_featuredLinkLabel, 'Featured link label', icon: Icons.label_outline, hint: 'e.g. "All my links"'),
            ])),

            _StaggerFadeIn(index: 6, child: _Section(title: 'Profile Theme', txt: txt, children: [
              Text('Accent color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txt)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                children: _accentSwatches.map((c) {
                  final selected = p.accentColorValue == c;
                  return InkWell(
                    onTap: () => setState(() => p.accentColorValue = c),
                    borderRadius: BorderRadius.circular(100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 40 : 36,
                      height: selected ? 40 : 36,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: txt, width: 2.5) : null,
                      ),
                      child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                    ),
                  );
                }).toList(),
              ),
            ])),

            _StaggerFadeIn(
              index: 7,
              child: AnimatedScale(
                scale: _saving ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(p.accentColorValue),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: _saving
                          ? const SizedBox(
                              key: ValueKey('save_btn_saving'),
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              key: ValueKey('save_btn_text'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ), // Closes ElevatedButton
                ), // Closes SizedBox
              ), // Closes AnimatedScale
            ), // Closes _StaggerFadeIn
          ],
        ), // Closes ListView
          ), // Closes SlideTransition
        ), // Closes FadeTransition
      ), // Closes Form
    ); // Closes Scaffold
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _text(
    TextEditingController c,
    String label, {
    IconData? icon,
    String? hint,
    String? prefixText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: c,
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: validator,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                prefixText: prefixText,
                prefixIcon: icon != null ? Icon(icon, size: 18) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Wraps [child] in a gentle fade + upward-rise entrance, delayed by
/// [index] * 60ms so a stack of these (e.g. each form section) staggers in
/// one after another instead of all popping in at once.
class _StaggerFadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const _StaggerFadeIn({required this.child, this.index = 0});

  @override
  State<_StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<_StaggerFadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(_fade);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Color txt;
  final List<Widget> children;
  const _Section({required this.title, required this.txt, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: txt, letterSpacing: 0.2)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ValueChanged<bool> onChanged;
  const _VisibilityToggle({required this.isPublic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isPublic ? 'Public — visible on your profile' : 'Private — hidden from guests',
      child: InkWell(
        onTap: () => onChanged(!isPublic),
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              isPublic ? Icons.public : Icons.lock_outline,
              key: ValueKey(isPublic),
              size: 20,
              color: isPublic ? BlinkColors.accent : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: items.map((v) => DropdownMenuItem(value: v, child: Text(itemLabel(v), overflow: TextOverflow.ellipsis))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

/// Faculty dropdown — swap the list below for your app's real faculty taxonomy.
class _FacultyDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool isDark;
  const _FacultyDropdown({required this.value, required this.onChanged, required this.isDark});

  static const List<String> _faculties = [
    'Engineering', 'Sciences', 'Arts', 'Social Sciences', 'Law', 'Medicine',
    'Business Administration', 'Education', 'Environmental Sciences', 'Agriculture', 'Pharmacy',
  ];

  @override
  Widget build(BuildContext context) {
    return _DropdownField<String>(
      label: 'Faculty',
      icon: Icons.account_balance_outlined,
      value: value,
      items: _faculties,
      itemLabel: (v) => v,
      onChanged: onChanged,
      isDark: isDark,
    );
  }
}

/// Searchable university picker backed by kNigerianUniversities (from the xlsx).
class _UniversityPicker extends StatelessWidget {
  final String initial;
  final ValueChanged<String> onSelected;
  final bool isDark;
  const _UniversityPicker({required this.initial, required this.onSelected, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initial),
      optionsBuilder: (TextEditingValue value) {
        if (value.text.trim().isEmpty) return kNigerianUniversities;
        final q = value.text.toLowerCase();
        return kNigerianUniversities.where((u) => u.toLowerCase().contains(q));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onSelected, // also accept free text for universities not in the list
          decoration: InputDecoration(
            labelText: 'University',
            hintText: 'Start typing to search 265 Nigerian universities…',
            prefixIcon: const Icon(Icons.school_outlined, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        );
      },
      optionsViewBuilder: (context, onSelectedCb, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, maxWidth: 400),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final opt = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(opt, style: const TextStyle(fontSize: 13)),
                    onTap: () => onSelectedCb(opt),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReadOnlyRankRow extends StatelessWidget {
  final int worldRank;
  final int campusRank;
  final Color txt;
  final Color muted;
  const _ReadOnlyRankRow({required this.worldRank, required this.campusRank, required this.txt, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: muted.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.leaderboard_outlined, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'World Rank #$worldRank · Campus Rank #$campusRank — calculated automatically from your points',
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _DobPicker extends StatelessWidget {
  final DateTime? value;
  final bool isPublic;
  final ValueChanged<DateTime?> onDateChanged;
  final ValueChanged<bool> onVisibilityChanged;
  final Color txt;
  final Color muted;
  final bool isDark;

  const _DobPicker({
    required this.value,
    required this.isPublic,
    required this.onDateChanged,
    required this.onVisibilityChanged,
    required this.txt,
    required this.muted,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? 'Date of birth'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime(2003, 1, 1),
                  firstDate: DateTime(1970),
                  lastDate: DateTime.now(),
                );
                if (picked != null) onDateChanged(picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of birth',
                  prefixIcon: const Icon(Icons.cake_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                child: Text(label, style: TextStyle(color: value == null ? muted : txt)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _VisibilityToggle(isPublic: isPublic, onChanged: onVisibilityChanged),
        ],
      ),
    );
  }
}

/// Add/remove chip editor for skills / hobbies / languages.
class _ChipEditor extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> values;
  final bool isDark;
  final ValueChanged<List<String>> onChanged;

  const _ChipEditor({required this.label, required this.icon, required this.values, required this.isDark, required this.onChanged});

  @override
  State<_ChipEditor> createState() => _ChipEditorState();
}

class _ChipEditorState extends State<_ChipEditor> {
  final _controller = TextEditingController();
  late List<String> _values = List.of(widget.values);

  void _add(String raw) {
    final v = raw.trim();
    if (v.isEmpty || _values.contains(v)) return;
    setState(() => _values.add(v));
    widget.onChanged(_values);
    _controller.clear();
  }

  void _remove(String v) {
    setState(() => _values.remove(v));
    widget.onChanged(_values);
  }

  @override
  Widget build(BuildContext context) {
    final txt = widget.isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = widget.isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 8),
          if (_values.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _values
                  .map((v) => Chip(
                        label: Text(v, style: const TextStyle(fontSize: 12)),
                        onDeleted: () => _remove(v),
                        deleteIconColor: muted,
                        backgroundColor: widget.isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onSubmitted: _add,
            decoration: InputDecoration(
              hintText: 'Type and press enter to add',
              prefixIcon: Icon(widget.icon, size: 18),
              suffixIcon: IconButton(icon: const Icon(Icons.add, size: 18), onPressed: () => _add(_controller.text)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Avatar / cover upload — pick, crop & adjust, then sync to Supabase.
// ---------------------------------------------------------------------------

/// Where to actually push the bytes. Wire this up to your Supabase Storage
/// bucket (e.g. `supabase.storage.from('avatars').uploadBinary(...)`) — kept
/// as a stand-alone function so it's easy to swap without touching the UI.
Future<String> uploadImageToSupabase({
  required Uint8List bytes,
  required String bucket,
  required String fileName,
}) async {
  // TODO: replace with a real Supabase call, e.g.:
  // final path = await Supabase.instance.client.storage
  //     .from(bucket)
  //     .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));
  // return Supabase.instance.client.storage.from(bucket).getPublicUrl(fileName);
  await Future.delayed(const Duration(milliseconds: 900)); // simulate network round-trip
  return 'https://your-project.supabase.co/storage/v1/object/public/$bucket/$fileName';
}

/// Avatar (tappable, circular) + cover photo (tappable, wide banner) picker.
/// Tapping either opens the system picker, then a crop/adjust screen, then
/// uploads the result to Supabase and reports the resulting URL back.
class _AvatarCoverPicker extends StatefulWidget {
  final UserProfile profile;
  final bool isDark;
  final ValueChanged<String> onAvatarUploaded;
  final ValueChanged<String> onCoverUploaded;
  const _AvatarCoverPicker({
    required this.profile,
    required this.isDark,
    required this.onAvatarUploaded,
    required this.onCoverUploaded,
  });

  @override
  State<_AvatarCoverPicker> createState() => _AvatarCoverPickerState();
}

class _AvatarCoverPickerState extends State<_AvatarCoverPicker> {
  bool _uploadingAvatar = false;
  bool _uploadingCover = false;
  File? _localAvatarPreview;
  File? _localCoverPreview;

  Future<void> _pickAndUpload({required bool isAvatar}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _CropAdjustScreen(imageFile: file, isCircle: isAvatar, isDark: widget.isDark),
      ),
    );
    if (cropped == null || !mounted) return;

    setState(() {
      if (isAvatar) {
        _localAvatarPreview = file;
        _uploadingAvatar = true;
      } else {
        _localCoverPreview = file;
        _uploadingCover = true;
      }
    });

    final url = await uploadImageToSupabase(
      bytes: cropped,
      bucket: isAvatar ? 'avatars' : 'covers',
      fileName: '${widget.profile.username}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    if (!mounted) return;
    setState(() {
      if (isAvatar) {
        _uploadingAvatar = false;
      } else {
        _uploadingCover = false;
      }
    });
    if (isAvatar) {
      widget.onAvatarUploaded(url);
    } else {
      widget.onCoverUploaded(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return SizedBox(
      height: 168,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _localCoverPreview != null
                    ? Image.file(_localCoverPreview!, fit: BoxFit.cover)
                    : (profile.coverPhoto.isNotEmpty
                        ? Image.network(profile.coverUrl, fit: BoxFit.cover)
                        : Container(color: BlinkColors.accent.withOpacity(0.2))),
                if (_uploadingCover) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      onPressed: _uploadingCover ? null : () => _pickAndUpload(isAvatar: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            bottom: -28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                  padding: const EdgeInsets.all(1),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _localAvatarPreview != null
                            ? Image.file(_localAvatarPreview!, fit: BoxFit.cover)
                            : (profile.avatarUrl.isNotEmpty ? Image.network(profile.avatarUrl, fit: BoxFit.cover) : Container(color: Colors.grey.shade300)),
                        if (_uploadingAvatar) Container(color: Colors.black45, child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: CircleAvatar(
                    backgroundColor: Colors.black45,
                    radius: 13,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 13),
                      onPressed: _uploadingAvatar ? null : () => _pickAndUpload(isAvatar: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple in-app crop & adjust screen: pinch/pan the picked image inside a
/// fixed frame (circle for avatar, wide rect for cover), then capture the
/// visible frame as PNG bytes to hand off to the uploader.
class _CropAdjustScreen extends StatefulWidget {
  final File imageFile;
  final bool isCircle;
  final bool isDark;
  const _CropAdjustScreen({required this.imageFile, required this.isCircle, required this.isDark});

  @override
  State<_CropAdjustScreen> createState() => _CropAdjustScreenState();
}

class _CropAdjustScreenState extends State<_CropAdjustScreen> {
  final _boundaryKey = GlobalKey();
  final _transformController = TransformationController();

  Future<void> _confirm() async {
    try {
      final renderObject = _boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final ui.Image image = await renderObject.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pop(byteData.buffer.asUint8List());
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final frameAspect = widget.isCircle ? 1.0 : 16 / 9;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.isCircle ? 'Adjust profile photo' : 'Adjust cover photo'),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: frameAspect,
                child: ClipPath(
                  clipper: widget.isCircle ? _CircleClipper() : _RectClipper(),
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.file(widget.imageFile, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: bg,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.pinch_outlined, size: 16, color: txt),
                const SizedBox(width: 8),
                Expanded(child: Text('Pinch to zoom, drag to reposition, then tap Done', style: TextStyle(fontSize: 12, color: txt))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}