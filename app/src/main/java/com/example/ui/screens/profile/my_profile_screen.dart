import 'package:flutter/material.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';
import 'package:blink/widgets/faculty_badge.dart';
import 'package:blink/widgets/post_card.dart' show fmtNum;
import 'package:blink/services/profile_service.dart';
import 'package:blink/services/follow_service.dart';
import 'package:blink/services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'user_profile_model.dart';
import 'profile_widgets.dart';
import 'edit_profile_screen.dart';
import 'guest_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final bool isDark;
  final ValueChanged<String> onSnack;

  const MyProfileScreen({super.key, required this.profile, required this.isDark, required this.onSnack});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late UserProfile profile = widget.profile;
  bool _loading = true;

  Color get _accent => Color(profile.accentColorValue);

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile.clone(), isDark: widget.isDark),
      ),
    );
    if (updated != null) {
      setState(() => profile = updated);
      widget.onSnack('Profile updated');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await ProfileService.fetchCurrent();
      final followersPreview = await FollowService.fetchFollowersPreview(p.username);
      final followingPreview = await FollowService.fetchFollowingPreview(p.username);
      final followerCount = await FollowService.fetchFollowerCount(p.username);
      final followingCount = await FollowService.fetchFollowingCount(p.username);
      if (!mounted) return;
      setState(() {
        profile = p
          ..followersPreview = followersPreview
          ..followingPreview = followingPreview
          ..followerCount = followerCount
          ..followingCount = followingCount;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openFollowList({required bool followers}) {
    final list = followers ? profile.followersPreview : profile.followingPreview;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FollowListScreen(
          title: followers ? 'Followers' : 'Following',
          people: list,
          isDark: widget.isDark,
          onOpenProfile: _openPersonProfile,
        ),
      ),
    );
  }

  void _openPersonProfile(FollowPreview person) {
    // Build a lightweight guest profile from the preview so tapping an
    // avatar in the followers/following list routes somewhere real. Swap
    // this for a proper repository lookup by username in production.
    final guest = UserProfile(
      fullName: person.fullName,
      username: person.username,
      avatar: person.avatar,
      coverPhoto: '',
      verification: person.verification,
      professionalHeadline: person.headline,
      accentColorValue: profile.accentColorValue,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GuestProfileScreen(profile: guest, isDark: widget.isDark, onSnack: widget.onSnack),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    final accent = _accent;
    const avatarRadius = 50.0;
    const avatarOverlap = avatarRadius; // pull the avatar up by exactly its radius so the full circle clears the cover cleanly

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton(
        onPressed: _openComposer,
        backgroundColor: BlinkColors.brandPink,
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bg,
            pinned: false,
            expandedHeight: 180,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 18),
                    onPressed: () => widget.onSnack('Settings'),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: profile.coverPhoto.isNotEmpty
                    ? Image.network(profile.coverUrl, key: ValueKey(profile.coverPhoto), fit: BoxFit.cover)
                    : DecoratedBox(
                        key: const ValueKey('cover_gradient'),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [const Color(0xFF1A0033), const Color(0xFF4A0080), accent],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverToBoxAdapter(
              child: Transform.translate(
                // Push content up by exactly the avatar's radius so the
                // whole circle sits half-on-cover / half-on-body — never
                // clipped or hidden behind the cover photo.
                offset: const Offset(0, -avatarOverlap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar row + Edit Profile button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ProfileAvatar(
                          heroTag: 'avatar_${profile.username}',
                          avatarUrl: profile.avatarUrl,
                          radius: avatarRadius,
                          ringColor: accent,
                          backgroundColor: bg,
                          badge: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: bg, shape: BoxShape.circle, border: Border.all(color: accent, width: 1.5)),
                            child: const Icon(Icons.camera_alt, size: 13),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _openEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: txt,
                            side: BorderSide(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          child: const Text('Edit Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Name + pronouns + verified badge
                    Row(
                      children: [
                        Flexible(child: Text(profile.fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: txt))),
                        const SizedBox(width: 6),
                        VerifiedMark(badge: profile.verification),
                      ],
                    ),
                    Row(
                      children: [
                        Text('@${profile.username}', style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w600)),
                        if (profile.pronouns.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text('· ${profile.pronouns}', style: TextStyle(fontSize: 13, color: muted)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    PresenceLabel(online: profile.onlineNow, label: profile.lastSeenLabel, muted: muted),

                    const SizedBox(height: 10),
                    if (profile.professionalHeadline.isNotEmpty)
                      Text(profile.professionalHeadline, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txt)),

                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (profile.faculty.isNotEmpty) FacultyBadge(tag: profile.faculty),
                        RankPill(label: 'World', rank: profile.worldRank),
                        RankPill(label: 'Campus', rank: profile.campusRank),
                        if (profile.availability != AvailabilityStatus.none)
                          TagChip(label: profile.availability.label, icon: Icons.bolt, isDark: isDark),
                      ],
                    ),

                    if (profile.customStatus.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(profile.customStatus, style: TextStyle(fontSize: 12, color: txt)),
                      ),
                    ],

                    const SizedBox(height: 18),
                    if (profile.bio.isNotEmpty) Text(profile.bio, style: TextStyle(fontSize: 13, color: muted, height: 1.4)),

                    const SizedBox(height: 18),
                    // Stats — tap Followers / Following to open the list.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatColumn(label: 'Posts', value: '${profile.posts.length}', txt: txt, muted: muted),
                        StatColumn(label: 'Followers', value: fmtNum(profile.followerCount), txt: txt, muted: muted, onTap: () => _openFollowList(followers: true)),
                        StatColumn(label: 'Following', value: fmtNum(profile.followingCount), txt: txt, muted: muted, onTap: () => _openFollowList(followers: false)),
                        StatColumn(label: 'Views', value: fmtNum(profile.profileViewsThisWeek), txt: txt, muted: muted),
                      ],
                    ),

                    const SizedBox(height: 22),
                    // Academic details — always visible.
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SectionHeader(title: 'Academic', txt: txt),
                    InfoRow(icon: Icons.school_outlined, text: profile.university, muted: muted),
                    InfoRow(icon: Icons.account_balance_outlined, text: [profile.faculty, profile.department].where((e) => e.isNotEmpty).join(' · '), muted: muted),
                    InfoRow(icon: Icons.menu_book_outlined, text: profile.courseOfStudy, muted: muted),
                    InfoRow(icon: Icons.stairs_outlined, text: [profile.academicLevel, profile.graduationYear].where((e) => e.isNotEmpty).join(' · '), muted: muted),
                    if (profile.currentJobTitle.isNotEmpty) InfoRow(icon: Icons.work_outline, text: profile.currentJobTitle, muted: muted),

                    if (profile.coreSkills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SectionHeader(title: 'Skills', txt: txt),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.coreSkills.map((s) {
                          final endorsement = profile.skillEndorsements.where((e) => e.skill == s);
                          final count = endorsement.isNotEmpty ? endorsement.first.endorsements : 0;
                          return TagChip(label: count > 0 ? '$s · $count' : s, isDark: isDark);
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    // Everything else lives inside "More Details".
                    MoreDetailsSection(
                      txt: txt,
                      muted: muted,
                      isDark: isDark,
                      children: [
                        const SizedBox(height: 4),
                        SectionHeader(title: 'Contact & Location', txt: txt),
                        InfoRow(icon: Icons.mail_outline, text: profile.email.value, muted: muted),
                        InfoRow(icon: Icons.call_outlined, text: profile.phone.value, muted: muted),
                        InfoRow(icon: Icons.flag_outlined, text: profile.countryOfOrigin, muted: muted),
                        InfoRow(icon: Icons.location_on_outlined, text: profile.currentCityState, muted: muted),
                        InfoRow(icon: Icons.other_houses_outlined, text: profile.campusHostelLocation, muted: muted),

                        if (profile.hobbies.isNotEmpty || profile.languages.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          SectionHeader(title: 'About Me', txt: txt),
                          if (profile.favoriteQuote.isNotEmpty) ...[
                            Text('"${profile.favoriteQuote}"', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: txt)),
                            const SizedBox(height: 10),
                          ],
                          if (profile.hobbies.isNotEmpty)
                            Wrap(spacing: 8, runSpacing: 8, children: profile.hobbies.map((h) => TagChip(label: h, isDark: isDark)).toList()),
                          if (profile.languages.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.languages.map((l) => TagChip(label: l, icon: Icons.translate, isDark: isDark)).toList(),
                            ),
                          ],
                        ],

                        if (profile.links.website.isNotEmpty ||
                            profile.links.linkedin.isNotEmpty ||
                            profile.links.twitter.isNotEmpty ||
                            profile.links.instagram.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          SectionHeader(title: 'Links', txt: txt),
                          Row(
                            children: [
                              SocialIconButton(icon: Icons.link, value: profile.links.website, isDark: isDark, onTap: () => widget.onSnack('Open website')),
                              SocialIconButton(icon: Icons.business_center_outlined, value: profile.links.linkedin, isDark: isDark, onTap: () => widget.onSnack('Open LinkedIn')),
                              SocialIconButton(icon: Icons.alternate_email, value: profile.links.twitter, isDark: isDark, onTap: () => widget.onSnack('Open X/Twitter')),
                              SocialIconButton(icon: Icons.camera_alt_outlined, value: profile.links.instagram, isDark: isDark, onTap: () => widget.onSnack('Open Instagram')),
                            ],
                          ),
                          if (profile.links.featuredLink.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => widget.onSnack('Open ${profile.links.featuredLink}'),
                              icon: const Icon(Icons.star_outline, size: 16),
                              label: Text(profile.links.featuredLinkLabel.isNotEmpty ? profile.links.featuredLinkLabel : profile.links.featuredLink),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: txt,
                                side: BorderSide(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          ],
                        ],

                        if (profile.badges.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          SectionHeader(title: 'Badges & Achievements', txt: txt),
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: profile.badges.map((a) => AchievementBadgeChip(achievement: a, isDark: isDark)).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(profile.joinedLabel, style: TextStyle(fontSize: 11, color: muted)),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Posts / Reels / Likes / Saved — swipe between tabs.
                    ProfileContentTabs(
                      posts: profile.posts,
                      reels: profile.reels,
                      likedPosts: profile.likedPosts,
                      savedPosts: profile.savedPosts,
                      isDark: isDark,
                      txt: txt,
                      muted: muted,
                      accent: accent,
                      isOwner: true,
                      onSnack: widget.onSnack,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openComposer() {
    final _controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? BlinkColors.bgDark : BlinkColors.bgLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheetState) {
        File? _picked;
        bool _uploading = false;
        bool _posting = false;
        final busy = _uploading || _posting;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: widget.isDark ? BlinkColors.textDark : BlinkColors.textLight)),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: InputDecoration(hintText: 'Share something with your followers', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  IconButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                            if (picked == null) return;
                            setSheetState(() => _picked = File(picked.path));
                          },
                    icon: const Icon(Icons.image),
                  ),
                  if (_picked != null) ...[
                    Expanded(child: Text('Image selected', style: TextStyle(color: widget.isDark ? BlinkColors.textDark : BlinkColors.textLight))),
                    IconButton(
                      onPressed: busy ? null : () => setSheetState(() => _picked = null),
                      icon: const Icon(Icons.close),
                    ),
                  ]
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        // This used to call Navigator.pop() BEFORE the
                        // Supabase upload/insert calls even ran, then tried
                        // to setState on the (now-closed) sheet — so the
                        // insert either raced against a dead widget or its
                        // result silently vanished, and the profile screen
                        // never showed the new post even when the row did
                        // make it into Supabase. Now we wait for the real
                        // result and only close once we have it.
                        onPressed: busy
                            ? null
                            : () async {
                                final text = _controller.text.trim();
                                if (text.isEmpty && _picked == null) return;

                                String? uploadedUrl;
                                if (_picked != null) {
                                  setSheetState(() => _uploading = true);
                                  uploadedUrl = await PostService.uploadPostAsset(_picked!, bucket: 'post-media');
                                  setSheetState(() => _uploading = false);
                                  if (uploadedUrl == null) {
                                    widget.onSnack('Image upload failed — check your Supabase storage bucket');
                                    return;
                                  }
                                }

                                setSheetState(() => _posting = true);
                                final created = await PostService.createProfilePost(
                                  authorUsername: profile.username,
                                  authorFullName: profile.fullName,
                                  authorAvatar: profile.avatarUrl,
                                  text: text,
                                  images: uploadedUrl != null ? [uploadedUrl] : null,
                                );
                                setSheetState(() => _posting = false);

                                if (created != null) {
                                  if (mounted) setState(() => profile.posts.insert(0, created));
                                  Navigator.of(sheetContext).pop();
                                  widget.onSnack('Post shared');
                                } else {
                                  widget.onSnack('Could not save to Supabase — check your connection and try again');
                                }
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: BlinkColors.accent),
                        child: busy
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Post'),
                      ),
                    ),
                  ],
                ),
                if (_uploading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
              ],
            ),
          ),
        );
      }),
    );
  }
}