import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/theme.dart';
import '../post_model.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_box.dart';
import 'package:blink/services/post_service.dart';

enum FeedTab { posts, reels }

class FeedScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> onSnack;
  final ValueChanged<String> onProfile;
  final String profileAvatarUrl;
  final String profileUsername;

  const FeedScreen({
    super.key,
    required this.isDark,
    required this.onSnack,
    required this.onProfile,
    required this.profileAvatarUrl,
    required this.profileUsername,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  FeedTab _tab = FeedTab.posts;
  bool _loading = true;
  bool _refreshing = false;
  bool _immersive = false;
  String _reelMode = 'Friends'; // 'Friends' | 'For You'
  bool _liked = false;
  bool _saved = false;
  List<FeedPost> _posts = [];
  RealtimeChannel? _feedChannel;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _subscribeToFeed();
  }

  @override
  void dispose() {
    _feedChannel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToFeed() {
    _feedChannel = PostService.subscribeToFeed(
      onUpdate: (posts) {
        if (!mounted) return;
        setState(() {
          _posts = posts;
          _loading = false;
        });
      },
    );
  }

  Future<void> _loadPosts() async {
    final posts = await PostService.fetchFeed();
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await _loadPosts();
    if (!mounted) return;
    setState(() => _refreshing = false);
    widget.onSnack('Feed updated');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => widget.onSnack('Menu tapped'),
                  child: Icon(Icons.more_horiz_rounded, color: txt, size: 26),
                ),
                const Text(
                  'Bl!nk',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: BlinkColors.brandPink,
                    letterSpacing: 0.2,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => widget.onSnack('Notifications tapped'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_none_rounded, color: txt, size: 24),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: BlinkColors.brandPink, shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => widget.onProfile(widget.profileUsername),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(widget.profileAvatarUrl),
                          ),
                          Positioned(
                            bottom: -1,
                            right: -1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: BlinkColors.online,
                                shape: BoxShape.circle,
                                border: Border.all(color: widget.isDark ? BlinkColors.bgDark : BlinkColors.bgLight, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                _TabPill(
                  label: 'Posts',
                  selected: _tab == FeedTab.posts,
                  onTap: () => setState(() {
                    _tab = FeedTab.posts;
                    _immersive = false;
                  }),
                  border: border,
                  muted: muted,
                ),
                const SizedBox(width: 8),
                _TabPill(
                  label: 'Reels',
                  selected: _tab == FeedTab.reels,
                  onTap: () => setState(() => _tab = FeedTab.reels),
                  border: border,
                  muted: muted,
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == FeedTab.posts ? _buildPostsTab(txt, muted) : _buildReelsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(Color txt, Color muted) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: BlinkColors.accent))),
            ),
          // Stories row
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final s = stories[i];
                return GestureDetector(
                  onTap: () => widget.onSnack(s.isMe ? 'Your story' : "${s.user}'s story"),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          s.isMe
                              ? Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isDark ? const Color(0x14FFFFFF) : const Color(0x0F000000),
                                    border: Border.all(color: const Color(0x1FFFFFFF), width: 2, style: BorderStyle.solid),
                                  ),
                                  child: const Icon(Icons.add, color: BlinkColors.accent, size: 20),
                                )
                              : Container(
                                  width: 58,
                                  height: 58,
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: BlinkColors.accent, width: 2.5))),
                                  child: ClipOval(child: Image.network(unsplash(s.avatar), fit: BoxFit.cover)),
                                ),
                          if (s.online && !s.isMe)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: BlinkColors.online,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: widget.isDark ? BlinkColors.bgDark : BlinkColors.bgLight, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 58,
                        child: Text(
                          s.isMe ? 'Add' : s.user,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: muted),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            Column(
              children: List.generate(
                2,
                (i) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: widget.isDark ? BlinkColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ShimmerBox(width: 40, height: 40, radius: 20),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              ShimmerBox(width: 100, height: 12),
                              SizedBox(height: 6),
                              ShimmerBox(width: 60, height: 10),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const ShimmerBox(width: double.infinity, height: 180, radius: 14),
                    ],
                  ),
                ),
              ),
            )
            else
            Column(
              children: _posts
                  .map((post) => PostCard(
                        post: post,
                        isDark: widget.isDark,
                        onComment: (p) => showCommentSheet(
                          context,
                          isDark: widget.isDark,
                          onProfileNav: widget.onProfile,
                          onSnack: widget.onSnack,
                        ),
                        onProfile: widget.onProfile,
                        onSnack: widget.onSnack,
                      ))
                  .toList(),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReelsTab() {
    // Mobile equivalent of the Figma wheel-triggered immersive layout:
    // swipe up to go immersive (hide chrome), swipe down to exit.
    return GestureDetector(
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -200 && !_immersive) setState(() => _immersive = true);
        if (v > 200 && _immersive) setState(() => _immersive = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(horizontal: _immersive ? 0 : 12, vertical: _immersive ? 0 : 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(_immersive ? 0 : 36)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=400&h=700&fit=crop&auto=format&q=85',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x59000000), Colors.transparent, Colors.transparent, Color(0xBF000000)],
                  stops: [0.0, 0.3, 0.5, 1.0],
                ),
              ),
            ),

            // Friends / For You toggle
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _immersive ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0x73000000),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['Friends', 'For You'].map((o) {
                        final selected = _reelMode == o;
                        return GestureDetector(
                          onTap: () => setState(() => _reelMode = o),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0x2EFFFFFF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              o,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected ? Colors.white : const Color(0x8CFFFFFF),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            // Right engagement sidebar
            Positioned(
              right: 12,
              bottom: 24,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=80&h=80&fit=crop'),
                      ),
                      Positioned(
                        bottom: -6,
                        left: 13,
                        child: Container(
                          width: 18,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: BlinkColors.accent, shape: BoxShape.circle),
                          child: const Text('+', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ReelAction(
                    icon: _liked ? Icons.favorite : Icons.favorite_border,
                    color: _liked ? BlinkColors.accent : Colors.white,
                    label: _liked ? '12.0M' : '12M',
                    onTap: () {
                      setState(() => _liked = !_liked);
                      widget.onSnack(_liked ? '❤️ Liked!' : 'Removed like');
                    },
                  ),
                  const SizedBox(height: 20),
                  _ReelAction(
                    icon: Icons.chat_bubble_outline,
                    color: Colors.white,
                    label: '561',
                    onTap: () => showCommentSheet(context, isDark: widget.isDark, onProfileNav: widget.onProfile, onSnack: widget.onSnack),
                  ),
                  const SizedBox(height: 20),
                  _ReelAction(
                    icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                    color: _saved ? BlinkColors.purple : Colors.white,
                    label: '16K',
                    onTap: () => setState(() => _saved = !_saved),
                  ),
                  const SizedBox(height: 20),
                  _ReelAction(
                    icon: Icons.send_outlined,
                    color: Colors.white,
                    label: '24K',
                    onTap: () => widget.onSnack('Link copied!'),
                  ),
                ],
              ),
            ),

            // Creator info
            Positioned(
              left: 14,
              right: 76,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('@zara.editorial', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4),
                  Text(
                    'Autumn collection drops tonight ✦ #fashion @luna',
                    style: TextStyle(fontSize: 12, color: Color(0xBFFFFFFF), height: 1.4),
                  ),
                ],
              ),
            ),

            if (!_immersive)
              const Center(
                child: Text(
                  'swipe up ↑ for immersive',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0x33FFFFFF), fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color border;
  final Color muted;

  const _TabPill({required this.label, required this.selected, required this.onTap, required this.border, required this.muted});

  @override
  Widget build(BuildContext context) {
   return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? BlinkColors.lavender : border, width: 1.5),
          color: selected ? Colors.white : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.black : muted,
          ),
        ),
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ReelAction({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}