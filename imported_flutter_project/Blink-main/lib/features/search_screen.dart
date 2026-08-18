import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../post_model.dart';
import '../widgets/faculty_badge.dart';

class SearchScreen extends StatefulWidget {
  final bool isDark;
  const SearchScreen({super.key, required this.isDark});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _q = '';

  static const _allSuggestions = ['#SIMME', '#SBMS', '@zara.editorial', '@dr.osei', '#fashion', '#medlife'];
  static const _trending = ['#SIMME', '#SBMS', '#fashion', '#medlife', '#editorial', '#grind', '#Ghana'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final inputBg = isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000);
    final suggestions = _q.isEmpty
        ? <String>[]
        : _allSuggestions.where((s) => s.toLowerCase().contains(_q.toLowerCase())).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text('Discover', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: txt)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: inputBg, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(Icons.search, color: muted, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _q = v),
                  style: TextStyle(color: txt, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search users, hashtags, topics...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x0DFFFFFF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
            ),
            child: Column(
              children: suggestions.map((s) {
                final tagged = s.startsWith('#') || s.startsWith('@');
                return InkWell(
                  onTap: () => setState(() {
                    _controller.text = s;
                    _q = s;
                  }),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    child: Text(s, style: TextStyle(color: tagged ? BlinkColors.accent : txt, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ),
        SizedBox(height: suggestions.isEmpty ? 20 : 16),
        Text('TRENDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted, letterSpacing: 1)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trending
              .map((tag) => GestureDetector(
                    onTap: () => setState(() {
                      _controller.text = tag;
                      _q = tag;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: BlinkColors.accent.withOpacity(isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: BlinkColors.accent.withOpacity(0.3)),
                      ),
                      child: Text(tag, style: const TextStyle(color: BlinkColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        Text('PEOPLE YOU MAY KNOW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...leaderboard.take(4).map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  CircleAvatar(radius: 21, backgroundImage: NetworkImage(unsplash(u.avatar))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.user, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt)),
                        if (u.faculty != null && u.faculty!.isNotEmpty) ...[const SizedBox(height: 3), FacultyBadge(tag: u.faculty!)],
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BlinkColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      elevation: 0,
                    ),
                    child: const Text('Follow'),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}