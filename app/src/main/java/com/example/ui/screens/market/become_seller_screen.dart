import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blink/config/theme.dart';
import '../profile/user_profile_model.dart';
import 'market_categories.dart';
import 'paystack_service.dart';
import 'seller_service.dart';

const double kSellerRegistrationFeeNaira = 2000;

class BecomeSellerScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> onSnack;
  const BecomeSellerScreen({super.key, required this.isDark, required this.onSnack});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

enum _LoadState { loading, notEligible, form, submitting, done }

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  _LoadState _state = _LoadState.loading;
  VerificationBadge _badge = VerificationBadge.none;

  final _businessName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _bio = TextEditingController();
  String? _selectedState;
  final Set<String> _selectedCategories = {};
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    final badge = await SellerService.myVerificationBadge();
    if (!mounted) return;
    setState(() {
      _badge = badge;
      _state = badge == VerificationBadge.none ? _LoadState.notEligible : _LoadState.form;
    });
  }

  bool get _formValid =>
      _businessName.text.trim().isNotEmpty &&
      _contactPhone.text.trim().isNotEmpty &&
      _selectedState != null &&
      _city.text.trim().isNotEmpty &&
      _address.text.trim().isNotEmpty &&
      _selectedCategories.isNotEmpty &&
      _agreedToTerms;

  Future<void> _submit() async {
    if (!_formValid) {
      widget.onSnack('Please fill in every field and select at least one category.');
      return;
    }

    setState(() => _state = _LoadState.submitting);

    try {
      await SellerService.savePendingProfile(
        businessName: _businessName.text.trim(),
        contactPhone: _contactPhone.text.trim(),
        whatsappNumber: _whatsapp.text.trim(),
        stateOfResidence: _selectedState!,
        city: _city.text.trim(),
        fullAddress: _address.text.trim(),
        bio: _bio.text.trim(),
        categoriesSold: _selectedCategories.toList(),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _LoadState.form);
      widget.onSnack('Could not save your profile. Please try again.');
      return;
    }

    if (!mounted) return;

    await PaystackService.pay(
      context: context,
      amountNaira: kSellerRegistrationFeeNaira,
      purpose: 'seller_registration',
      onSuccess: () async {
        await SellerService.activateAfterPayment();
        if (!mounted) return;
        setState(() => _state = _LoadState.done);
        widget.onSnack('Welcome to ALUTA MARKET — your seller account is live!');
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => _state = _LoadState.form);
        widget.onSnack(msg);
      },
    );
  }

  @override
  void dispose() {
    _businessName.dispose();
    _contactPhone.dispose();
    _whatsapp.dispose();
    _city.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
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
        iconTheme: IconThemeData(color: txt),
        title: Text('Become a Seller', style: TextStyle(color: txt, fontWeight: FontWeight.w800, fontSize: 17)),
      ),
      body: switch (_state) {
        _LoadState.loading => const Center(child: CircularProgressIndicator()),
        _LoadState.notEligible => _buildNotEligible(txt, muted),
        _LoadState.form => _buildForm(txt, muted, isDark),
        _LoadState.submitting => _buildSubmitting(txt, muted),
        _LoadState.done => _buildDone(txt, muted),
      },
    );
  }

  Widget _buildNotEligible(Color txt, Color muted) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_outlined, size: 64, color: muted).animate().scale(duration: 400.ms),
          const SizedBox(height: 20),
          Text('Verification Required', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: txt)),
          const SizedBox(height: 10),
          Text(
            'Only Blue Tick or Gold Tick verified members can sell on ALUTA MARKET. '
            'This keeps buyers safe and every listing traceable to a real, trusted seller.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: BlinkColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Get Verified First', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitting(Color txt, Color muted) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Setting up your seller account…', style: TextStyle(color: muted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDone(Color txt, Color muted) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 72, color: BlinkColors.online).animate().scale(duration: 450.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text("You're all set!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: txt)),
          const SizedBox(height: 8),
          Text('Your seller profile is active. Head back to Market to post your first item.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: muted, height: 1.5)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: BlinkColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text('Go to Market', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Color txt, Color muted, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        _badgeRow(muted),
        const SizedBox(height: 20),
        _sectionLabel('Business details', txt),
        _field(controller: _businessName, label: 'Business / Store name', isDark: isDark, txt: txt, muted: muted),
        const SizedBox(height: 12),
        _field(controller: _contactPhone, label: 'Contact phone number', isDark: isDark, txt: txt, muted: muted, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _field(controller: _whatsapp, label: 'WhatsApp number (optional)', isDark: isDark, txt: txt, muted: muted, keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        _sectionLabel('Location', txt),
        _stateDropdown(isDark, txt, muted),
        const SizedBox(height: 12),
        _field(controller: _city, label: 'City / Town', isDark: isDark, txt: txt, muted: muted),
        const SizedBox(height: 12),
        _field(controller: _address, label: 'Full pickup/delivery address', isDark: isDark, txt: txt, muted: muted, maxLines: 2),
        const SizedBox(height: 20),
        _sectionLabel('About your store', txt),
        _field(controller: _bio, label: 'Short bio — what do you sell, why buy from you?', isDark: isDark, txt: txt, muted: muted, maxLines: 3),
        const SizedBox(height: 20),
        _sectionLabel('Categories you\'ll sell in (pick at least 1)', txt),
        const SizedBox(height: 10),
        _categoryPicker(isDark, txt, muted),
        const SizedBox(height: 24),
        _termsCheckbox(txt, muted),
        const SizedBox(height: 24),
        _feeCard(txt, muted, isDark),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _formValid ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: BlinkColors.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: muted.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              elevation: 0,
            ),
            child: Text('Pay ₦${kSellerRegistrationFeeNaira.toStringAsFixed(0)} & Activate', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _badgeRow(Color muted) {
    final label = _badge == VerificationBadge.gold ? 'Gold Tick' : 'Blue Tick';
    final color = _badge == VerificationBadge.gold ? BlinkColors.gold : BlinkColors.accentBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(Icons.verified, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$label verified — you\'re eligible to sell', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color txt) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txt)),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    required Color txt,
    required Color muted,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: txt, fontSize: 13.5),
        decoration: InputDecoration(hintText: label, hintStyle: TextStyle(color: muted, fontSize: 13), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  Widget _stateDropdown(bool isDark, Color txt, Color muted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedState,
          hint: Text('State of residence', style: TextStyle(color: muted, fontSize: 13)),
          dropdownColor: isDark ? BlinkColors.surfaceDark : Colors.white,
          style: TextStyle(color: txt, fontSize: 13.5),
          items: kNigerianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedState = v),
        ),
      ),
    );
  }

  Widget _categoryPicker(bool isDark, Color txt, Color muted) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kMarketCategories.map((c) {
        final selected = _selectedCategories.contains(c.name);
        return GestureDetector(
          onTap: () => setState(() {
            selected ? _selectedCategories.remove(c.name) : _selectedCategories.add(c.name);
          }),
          child: AnimatedContainer(
            duration: 180.ms,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? BlinkColors.accent : (isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(c.name, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : muted)),
          ),
        );
      }).toList(),
    );
  }

  Widget _termsCheckbox(Color txt, Color muted) {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: 150.ms,
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreedToTerms ? BlinkColors.accent : Colors.transparent,
              border: Border.all(color: _agreedToTerms ? BlinkColors.accent : muted, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _agreedToTerms ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'I confirm all information above is accurate and I agree to ALUTA MARKET\'s seller guidelines.',
              style: TextStyle(fontSize: 12, color: muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeCard(Color txt, Color muted, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BlinkColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BlinkColors.accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: BlinkColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('One-time registration fee', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: txt)),
                const SizedBox(height: 2),
                Text('₦${kSellerRegistrationFeeNaira.toStringAsFixed(0)} via Paystack — activates your seller account for life.',
                    style: TextStyle(fontSize: 11.5, color: muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
