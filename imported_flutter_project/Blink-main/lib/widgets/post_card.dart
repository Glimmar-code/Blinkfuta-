import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../post_model.dart';
import 'faculty_badge.dart';
import 'rich_text_highlight.dart';
import 'verified_mark.dart';

String fmtNum(int n) {
  if (n >= 1000000) {
    final v = n / 1000000;
    return '${v.toStringAsFixed(1).replaceAll('.0', '')}M';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v.toStringAsFixed(1).replaceAll('.0', '')}K';
  }
  return '$n';
}

class PostCard extends StatefulWidget {
  final FeedPost post;
  final bool isDark;
  final ValueChanged<FeedPost> onComment;
  final ValueChanged<String> onProfile;
  final ValueChanged<String> onSnack;

  const PostCard({
    super.key,
    required this.post,
    required this.isDark,
    required this.onComment,
    required this.onProfile,
    required this.onSnack,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late final AnimationController _heartController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _heartScale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.95), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 40),
  ]).animate(_heartController);

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _like() async {
    setState(() {
      widget.post.liked = !widget.post.liked;
      widget.post.likes += widget.post.liked ? 1 : -1;
    });
    _heartController.forward(from: 0);
    
    // Attempt to persist to Supabase
    final success = await PostService.toggleLike(widget.post.id, widget.post.liked);
    if (!success) {
      // Revert if it fails
      if (mounted) {
        setState(() {
          widget.post.liked = !widget.post.liked;
          widget.post.likes += widget.post.liked ? 1 : -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final cardBg = isDark ? BlinkColors.surfaceDark : BlinkColors.surfaceLight;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => widget.onProfile(p.user),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: BlinkColors.accent,
                        child: CircleAvatar(
                          radius: 17,
                          backgroundImage: p.avatar.isNotEmpty ? NetworkImage(resolveImageUrl(p.avatar)) : null,
                          child: p.avatar.isEmpty ? const Icon(Icons.person, size: 16) : null,
                        ),
                      ),
                      if (p.type == PostType.photo)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: BlinkColors.online,
                              shape: BoxShape.circle,
                              border: Border.all(color: isDark ? const Color(0xFF111111) : Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => widget.onProfile(p.user),
                            child: Text(p.user, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt)),
                          ),
                          const SizedBox(width: 4),
                          VerifiedMark(badge: p.verificationBadge, size: 14),
                          if (p.faculty != null && p.faculty!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            FacultyBadge(tag: p.faculty!),
                          ],
                        ],
                      ),
                      Text('${p.time} ago', style: TextStyle(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, size: 18, color: muted),
              ],
            ),
          ),

          // Content
          if (p.type == PostType.photo) ...[
            p.image != null && p.image!.isNotEmpty
              ? AspectRatio(
                  aspectRatio: 4 / 5,
                  child: Image.network(resolveImageUrl(p.image!), width: double.infinity, fit: BoxFit.cover),
                )
              : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: RichTextHighlight(text: p.caption ?? '', color: txt, fontSize: 13, height: 1.55),
            ),
          ] else
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 140),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: (p.gradient ?? ['#CCCCCC']).map((h) => Color(int.parse('FF${h.substring(1)}', radix: 16))).toList(),
                ),
              ),
              child: RichTextHighlight(
                text: p.text ?? '',
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _like,
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _heartScale,
                        child: Icon(
                          p.liked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: p.liked ? BlinkColors.accent : muted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(fmtNum(p.likes), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.liked ? BlinkColors.accent : muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () => widget.onComment(p),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20, color: muted),
                      const SizedBox(width: 6),
                      Text(fmtNum(p.comments), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () => widget.onSnack('Link copied to clipboard'),
                  child: Row(
                    children: [
                      Icon(Icons.send_outlined, size: 20, color: muted),
                      const SizedBox(width: 6),
                      Text(fmtNum(p.shares), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18, color: muted),
                    const SizedBox(width: 5),
                    Text(fmtNum(p.views), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}