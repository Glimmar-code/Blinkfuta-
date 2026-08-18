import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';
import 'market_categories.dart';
import 'paystack_service.dart';
import 'seller_service.dart';

const double kPromotionFeeNaira = 1500;

class PostItemScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> onSnack;
  const PostItemScreen({super.key, required this.isDark, required this.onSnack});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _picker = ImagePicker();
  final List<XFile> _images = [];

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _tagInput = TextEditingController();

  String? _category;
  ItemCondition _condition = ItemCondition.used;
  bool _negotiable = false;
  bool _promote = false;
  bool _submitting = false;
  final Set<String> _tags = {};

  bool get _formValid =>
      _images.isNotEmpty &&
      _title.text.trim().isNotEmpty &&
      _description.text.trim().isNotEmpty &&
      _price.text.trim().isNotEmpty &&
      double.tryParse(_price.text.trim()) != null &&
      _category != null;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      _images.addAll(picked);
      if (_images.length > 8) _images.removeRange(8, _images.length);
    });
  }

  void _addTag(String raw) {
    final tag = raw.trim().replaceAll(' ', '-').toLowerCase();
    if (tag.isEmpty) return;
    setState(() {
      _tags.add(tag);
      _tagInput.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formValid) {
      widget.onSnack('Add at least one photo and fill in every required field.');
      return;
    }

    setState(() => _submitting = true);

    final draft = MarketItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _title.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      negotiable: _negotiable,
      img: _images.first.path,
      images: _images.map((f) => f.path).toList(),
      seller: 'you',
      tag: _category!,
      tags: _tags.toList(),
      condition: _condition,
      isPromoted: false,
    );

    try {
      await SellerService.createListing(draft);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.onSnack('Could not post your item. Please try again.');
      return;
    }

    if (!_promote) {
      if (!mounted) return;
      setState(() => _submitting = false);
      widget.onSnack('Your item is live on ALUTA MARKET!');
      Navigator.of(context).pop(true);
      return;
    }

    if (!mounted) return;
    await PaystackService.pay(
      context: context,
      amountNaira: kPromotionFeeNaira,
      purpose: 'promote_listing',
      onSuccess: () {
        if (!mounted) return;
        setState(() => _submitting = false);
        widget.onSnack('Posted and promoted — your item is now trending!');
        Navigator.of(context).pop(true);
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => _submitting = false);
        widget.onSnack('Item posted, but promotion failed: $msg');
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _tagInput.dispose();
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
        title: Text('Post an Item', style: TextStyle(color: txt, fontWeight: FontWeight.w800, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          _imagePicker(isDark, txt, muted),
          const SizedBox(height: 20),
          _field(controller: _title, label: 'Title', isDark: isDark, txt: txt, muted: muted),
          const SizedBox(height: 12),
          _field(controller: _description, label: 'Description', isDark: isDark, txt: txt, muted: muted, maxLines: 4),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(controller: _price, label: 'Price (₵)', isDark: isDark, txt: txt, muted: muted, keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _negotiable = !_negotiable),
                child: AnimatedContainer(
                  duration: 180.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: _negotiable ? BlinkColors.accent : (isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Negotiable', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _negotiable ? Colors.white : muted)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txt)),
          const SizedBox(height: 10),
          _categoryDropdown(isDark, txt, muted),
          const SizedBox(height: 16),
          Text('Condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txt)),
          const SizedBox(height: 10),
          _conditionPicker(isDark, muted),
          const SizedBox(height: 16),
          Text('Tags', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txt)),
          const SizedBox(height: 10),
          _tagsField(isDark, txt, muted),
          const SizedBox(height: 24),
          _promoteCard(txt, muted, isDark),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_formValid && !_submitting) ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: BlinkColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: muted.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : Text(_promote ? 'Pay & Post with Promotion' : 'Post to Market', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePicker(bool isDark, Color txt, Color muted) {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: muted.withOpacity(0.3), width: 1.2),
              ),
              child: Icon(Icons.add_a_photo_outlined, color: muted),
            ),
          ),
          ..._images.map((f) => Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(f.path), width: 92, height: 92, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.remove(f)),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9))),
        ],
      ),
    );
  }

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

  Widget _categoryDropdown(bool isDark, Color txt, Color muted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _category,
          hint: Text('Select a category', style: TextStyle(color: muted, fontSize: 13)),
          dropdownColor: isDark ? BlinkColors.surfaceDark : Colors.white,
          style: TextStyle(color: txt, fontSize: 13.5),
          items: kMarketCategories
              .map((c) => DropdownMenuItem(value: c.name, child: Row(children: [
                    Icon(c.icon, size: 16, color: muted),
                    const SizedBox(width: 8),
                    Text(c.name),
                  ])))
              .toList(),
          onChanged: (v) => setState(() => _category = v),
        ),
      ),
    );
  }

  Widget _conditionPicker(bool isDark, Color muted) {
    return Row(
      children: ItemCondition.values.map((c) {
        final selected = _condition == c;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _condition = c),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? BlinkColors.accent : (isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(c.label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : muted)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _tagsField(bool isDark, Color txt, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _tagInput,
            onSubmitted: _addTag,
            style: TextStyle(color: txt, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'e.g. back-to-school, hot-deal (press enter)',
              hintStyle: TextStyle(color: muted, fontSize: 12.5),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags
                .map((t) => Chip(
                      label: Text('#$t', style: const TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: BlinkColors.accent,
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                      onDeleted: () => setState(() => _tags.remove(t)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _promoteCard(Color txt, Color muted, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _promote = !_promote),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _promote ? BlinkColors.accent.withOpacity(0.1) : (isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _promote ? BlinkColors.accent.withOpacity(0.4) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.trending_up, color: _promote ? BlinkColors.accent : muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Promote this listing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt)),
                  const SizedBox(height: 2),
                  Text('₦${kPromotionFeeNaira.toStringAsFixed(0)} to feature at the top of the feed for 7 days.',
                      style: TextStyle(fontSize: 11.5, color: muted, height: 1.4)),
                ],
              ),
            ),
            Switch(value: _promote, onChanged: (v) => setState(() => _promote = v), activeColor: BlinkColors.accent),
          ],
        ),
      ),
    );
  }
}