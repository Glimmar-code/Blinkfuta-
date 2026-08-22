import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../post_model.dart';
import '../../services/comment_service.dart';
import 'post_card.dart' show fmtNum;
import 'rich_text_highlight.dart';

/// Call this to open the comment sheet, matching Figma's `commentOpen` modal.
Future<void> showCommentSheet(
  BuildContext context, {
  required String postId,
  required bool isDark,
  required ValueChanged<String> onProfileNav,
  required ValueChanged<String> onSnack,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CommentSheetContent(postId: postId, isDark: isDark, onProfileNav: onProfileNav, onSnack: onSnack),
  );
}

class _CommentSheetContent extends StatefulWidget {
  final String postId;
  final bool isDark;
  final ValueChanged<String> onProfileNav;
  final ValueChanged<String> onSnack;

  const _CommentSheetContent({required this.postId, required this.isDark, required this.onProfileNav, required this.onSnack});

  @override
  State<_CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<_CommentSheetContent> {
  List<Comment> _comments = [];
  bool _loading = true;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final fetched = await CommentService.fetchComments(widget.postId);
    if (mounted) {
      setState(() {
        _comments = fetched;
        _loading = false;
      });
    }
  }
  final _expanded = <int>{};

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          user: 'you',
          avatar: 'photo-1529139574466-a303027c1d8b?w=80&h=80&fit=crop',
          text: text,
          time: 'now',
          likes: 0,
        ),
      );
      _input.clear();
    });
    await CommentService.postComment(widget.postId, text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFFAFAFA);
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return FractionallySizedBox(
      heightFactor: 0.65,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0x1FFFFFFF), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_comments.length} Comments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: txt)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 18, color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: _comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) => _CommentTile(
                  comment: _comments[i],
                  isDark: isDark,
                  expanded: _expanded.contains(_comments[i].id),
                  onToggleReplies: () => setState(() {
                    final id = _comments[i].id;
                    _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id);
                  }),
                  onLike: () async {
                    final c = _comments[i];
                    final currentLiked = c.liked;
                    setState(() {
                      c.liked = !currentLiked;
                      c.likes += c.liked ? 1 : -1;
                    });
                    final success = await CommentService.toggleLike(c.id, c.liked);
                    if (!success && mounted) {
                      setState(() {
                        c.liked = currentLiked;
                        c.likes += c.liked ? 1 : -1;
                      });
                    }
                  },
                  onProfile: () {
                    Navigator.of(context).pop();
                    widget.onProfileNav(_comments[i].user);
                  },
                  onCopy: () => widget.onSnack('Comment copied'),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=64&h=64&fit=crop'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _input,
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(color: txt, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_input.text.isNotEmpty)
                            GestureDetector(
                              onTap: _send,
                              child: const Icon(Icons.send, size: 18, color: BlinkColors.accent),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  final String postId;
  final bool isDark;
  final bool expanded;
  final VoidCallback onToggleReplies;
  final VoidCallback onLike;
  final VoidCallback onProfile;
  final VoidCallback onCopy;

  const _CommentTile({
    required this.comment,
    required this.isDark,
    required this.expanded,
    required this.onToggleReplies,
    required this.onLike,
    required this.onProfile,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final c = comment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onProfile,
              child: CircleAvatar(radius: 17, backgroundImage: NetworkImage(unsplash(c.avatar))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onProfile,
                        child: Text(c.user, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: txt)),
                      ),
                      const SizedBox(width: 6),
                      Text(c.time, style: TextStyle(fontSize: 10, color: muted)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  RichTextHighlight(text: c.text, color: txt, fontSize: 13, height: 1.5),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              c.liked ? Icons.favorite : Icons.favorite_border,
                              size: 14,
                              color: c.liked ? BlinkColors.accent : muted,
                            ),
                            const SizedBox(width: 4),
                            Text(fmtNum(c.likes), style: TextStyle(fontSize: 11, color: c.liked ? BlinkColors.accent : muted)),
                          ],
                        ),
                      ),
                      if (c.replies.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onToggleReplies,
                          child: Row(
                            children: [
                              const Icon(Icons.reply, size: 12, color: BlinkColors.accent),
                              const SizedBox(width: 3),
                              Text(
                                expanded ? 'Hide' : '${c.replies.length} repl${c.replies.length > 1 ? 'ies' : 'y'}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: BlinkColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      GestureDetector(onTap: onCopy, child: Icon(Icons.content_copy, size: 14, color: muted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 10),
            child: Column(
              children: c.replies
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 14, backgroundImage: NetworkImage(unsplash(r.avatar))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: '${r.user} ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: txt)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
