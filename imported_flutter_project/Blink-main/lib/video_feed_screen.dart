import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';
import 'package:blink/widgets/comment_sheet.dart';

/// Videos-only feed, swipe-to-advance like Reels/TikTok. This ships the UI
/// shell with an image placeholder standing in for the video frame — wire
/// in a real player (e.g. the `video_player` / `chewie` packages) per
/// [Post.videoUrl] when ready.
class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final _videos = [
    Post(
      id: 'v1',
      name: 'Kemi B.',
      handle: '@kemib',
      avatarInitial: 'K',
      time: '10m',
      text: 'Studio session behind the scenes 🎬',
      type: PostType.video,
      imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800',
      likes: 1204,
      comments: [
        const Comment(name: 'Sara K.', avatarInitial: 'S', text: 'This is fire', time: '5m'),
      ],
    ),
    Post(
      id: 'v2',
      name: 'Dev J.',
      handle: '@devj',
      avatarInitial: 'D',
      time: '1h',
      text: 'Quick tutorial on the new market feature.',
      type: PostType.video,
      imageUrl: 'https://images.unsplash.com/photo-1526178613658-3f1622045557?w=800',
      likes: 852,
    ),
    Post(
      id: 'v3',
      name: 'Amara L.',
      handle: '@amara',
      avatarInitial: 'A',
      time: '3h',
      text: 'Unboxing my Aluta Market order.',
      type: PostType.video,
      imageUrl: 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
      likes: 430,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _videos.length,
      itemBuilder: (context, i) => _VideoTile(post: _videos[i]),
    );
  }
}

class _VideoTile extends StatefulWidget {
  final Post post;
  const _VideoTile({required this.post});

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  Post get post => widget.post;

  void _toggleLike() => setState(() {
        post.isLiked = !post.isLiked;
        post.likes += post.isLiked ? 1 : -1;
      });

  void _toggleBookmark() => setState(() => post.isBookmarked = !post.isBookmarked);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          post.imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(color: BlinkColors.surfaceRaised),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.transparent, Colors.black87],
              stops: [0, 0.55, 1],
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Videos',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 90,
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: BlinkColors.surfaceRaised,
                child: Text(post.avatarInitial,
                    style: const TextStyle(color: BlinkColors.accent, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 20),
              _sideAction(
                icon: post.isLiked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                label: '${post.likes}',
                color: post.isLiked ? BlinkColors.accent : Colors.white,
                onTap: _toggleLike,
              ),
              const SizedBox(height: 18),
              _sideAction(
                icon: PhosphorIconsRegular.chatCircle,
                label: '${post.comments.length}',
                color: Colors.white,
                onTap: () => showCommentSheet(context, postId: 'test', isDark: true, onProfileNav: (_) {}, onSnack: (_) {}).then((_) {
                  if (mounted) setState(() {});
                }),
              ),
              const SizedBox(height: 18),
              _sideAction(
                icon: PhosphorIconsRegular.paperPlaneTilt,
                label: 'Share',
                color: Colors.white,
                onTap: () => setState(() => post.shares += 1),
              ),
              const SizedBox(height: 18),
              _sideAction(
                icon: post.isBookmarked ? PhosphorIconsFill.bookmarkSimple : PhosphorIconsRegular.bookmarkSimple,
                label: '',
                color: post.isBookmarked ? BlinkColors.accent : Colors.white,
                onTap: _toggleBookmark,
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 90,
          bottom: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${post.name}  ${post.handle}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text(post.text, style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sideAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          PhosphorIcon(icon, color: color, size: 27),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}