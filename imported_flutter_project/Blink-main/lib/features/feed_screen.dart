// feed_screen.dart  —  Bl!nk  (enhanced, 100+ features)
// Drop-in replacement for your existing feed_screen.dart.
// All original public APIs are preserved.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colour palette ──────────────────────────────────────────────────────────
class BlinkColors {
  static const brandPink  = Color(0xFFFF3B7F);
  static const accent     = Color(0xFFFF3B7F);
  static const lavender   = Color(0xFFA855F7);
  static const online     = Color(0xFF22C55E);
  static const bgDark     = Color(0xFF0A0A14);
  static const bgLight    = Color(0xFFF9FAFB);
  static const surfaceDark  = Color(0xFF0F0F1F);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textDark   = Color(0xFFFFFFFF);
  static const textLight  = Color(0xFF111827);
  static const mutedDark  = Color(0x66FFFFFF);
  static const mutedLight = Color(0xFF6B7280);
  static const borderDark  = Color(0x0DFFFFFF);
  static const borderLight = Color(0xFFE5E7EB);
}

// ─── Models ──────────────────────────────────────────────────────────────────
class FeedPost {
  final String id;
  final String user;
  final String handle;
  final String avatar;
  final bool   verified;
  final String time;
  final String? location;
  final String caption;
  final List<String> images;
  int  likes;
  bool liked;
  int  comments;
  int  shares;
  int  views;
  bool saved;
  bool following;
  String? music;
  bool isReel;
  List<PollOption>? pollOptions;

  FeedPost({
    required this.id,
    required this.user,
    required this.handle,
    required this.avatar,
    this.verified = false,
    required this.time,
    this.location,
    required this.caption,
    required this.images,
    required this.likes,
    this.liked = false,
    required this.comments,
    required this.shares,
    required this.views,
    this.saved = false,
    this.following = false,
    this.music,
    this.isReel = false,
    this.pollOptions,
  });
}

class PollOption {
  final String text;
  int votes;
  PollOption(this.text, this.votes);
}

class StoryItem {
  final String id;
  final String user;
  final String avatar;
  final bool isMe;
  final bool online;
  bool viewed;
  StoryItem({
    required this.id,
    required this.user,
    required this.avatar,
    this.isMe  = false,
    this.online = false,
    this.viewed = false,
  });
}

class CommentModel {
  final String id;
  final String user;
  final String avatar;
  final String text;
  final String time;
  int  likes;
  bool liked;
  CommentModel({
    required this.id,
    required this.user,
    required this.avatar,
    required this.text,
    required this.time,
    this.likes = 0,
    this.liked = false,
  });
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
String fmtNum(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

// ─── Mock data ────────────────────────────────────────────────────────────────
final _avatars = [
  'https://images.unsplash.com/photo-1675663359918-79997e76a357?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1675663351050-89949e051c38?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1675663404064-1768a2de14ea?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1707369757282-fa35f26b5d06?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1758102776704-8389e082e035?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1611432580340-af48bd7549ed?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1758274251847-13149798c887?w=120&h=120&fit=crop',
  'https://images.unsplash.com/photo-1758598305593-7c12d15687be?w=120&h=120&fit=crop',
];

final _postImgs = [
  'https://images.unsplash.com/photo-1488034976201-ffbaa99cbf5c?w=800&fit=crop',
  'https://images.unsplash.com/photo-1482859454392-1b5326395032?w=800&fit=crop',
  'https://images.unsplash.com/photo-1429292394373-ddbcc6bb7468?w=800&fit=crop',
  'https://images.unsplash.com/photo-1722153023306-a0618a3340c6?w=800&fit=crop',
  'https://images.unsplash.com/photo-1668720693970-f9d391f58ba8?w=800&fit=crop',
  'https://images.unsplash.com/photo-1487528001669-63c47a53fd39?w=800&fit=crop',
  'https://images.unsplash.com/photo-1605776114456-5bacd0ae7411?w=800&fit=crop',
  'https://images.unsplash.com/photo-1675663359918-79997e76a357?w=800&fit=crop',
];

List<StoryItem> get mockStories => [
  StoryItem(id: 'me',  user: 'Your Story', avatar: _avatars[0], isMe: true),
  StoryItem(id: 's1',  user: 'zara.w',     avatar: _avatars[1], online: true),
  StoryItem(id: 's2',  user: 'kai_shots',  avatar: _avatars[2], online: true),
  StoryItem(id: 's3',  user: 'nova.film',  avatar: _avatars[3], viewed: true),
  StoryItem(id: 's4',  user: 'dxlan',      avatar: _avatars[4], online: true),
  StoryItem(id: 's5',  user: 'esme.art',   avatar: _avatars[5]),
  StoryItem(id: 's6',  user: 'river.px',   avatar: _avatars[6], online: true),
  StoryItem(id: 's7',  user: 'sam.bk',     avatar: _avatars[7], viewed: true),
];

List<FeedPost> get mockPosts => [
  FeedPost(
    id: 'p1', user: 'Zara Williams', handle: 'zara.w',
    avatar: _avatars[1], verified: true, time: '2m', location: 'Tokyo, Japan',
    caption: "Lost in the neon labyrinth of Shinjuku at 2am. There's something magnetic about cities that never sleep ✨ #tokyo #nightphotography #travel #Blink",
    images: [_postImgs[3], _postImgs[6]],
    likes: 4821, comments: 217, shares: 89, views: 32400,
    music: 'Nights Like This — Kehlani', following: false,
  ),
  FeedPost(
    id: 'p2', user: 'Kai Chen', handle: 'kai_shots',
    avatar: _avatars[2], time: '14m', location: 'Brooklyn, NY',
    caption: 'Found this gem after 6 hours of shooting. The city gives when you keep walking 🎞 #streetphotography #brooklyn',
    images: [_postImgs[4]],
    likes: 2103, liked: true, comments: 94, shares: 31, views: 15800,
    music: 'MONTERO — Lil Nas X', following: true, saved: true,
    pollOptions: [PollOption('Film 📸', 612), PollOption('Digital 💻', 388)],
  ),
  FeedPost(
    id: 'p3', user: 'Nova Diaz', handle: 'nova.film',
    avatar: _avatars[3], verified: true, time: '1h', location: 'Los Angeles, CA',
    caption: "Golden hour doesn't wait. Drop everything and shoot 🌅 #goldenhr #LA #portrait",
    images: [_postImgs[7], _postImgs[0], _postImgs[2]],
    likes: 8944, comments: 441, shares: 203, views: 71200,
    music: 'Cruel Summer — Taylor Swift',
  ),
  FeedPost(
    id: 'p4', user: 'Dylan Park', handle: 'dxlan',
    avatar: _avatars[4], time: '3h', location: 'Seoul, South Korea',
    caption: 'Architecture is just vibes in concrete form. Change my mind 🏗 #seoul #architecture',
    images: [_postImgs[5]],
    likes: 1289, comments: 57, shares: 14, views: 9400, following: true,
  ),
  // Reels
  FeedPost(
    id: 'r1', user: 'Esme Torres', handle: 'esme.art',
    avatar: _avatars[5], verified: true, time: '45m', location: 'NYC',
    caption: 'Living for these moments 💫 #nyc #night #aesthetic',
    images: [_postImgs[1]],
    likes: 12400, comments: 882, shares: 340, views: 220000,
    music: 'Flowers — Miley Cyrus', isReel: true,
  ),
  FeedPost(
    id: 'r2', user: 'River Moon', handle: 'river.px',
    avatar: _avatars[6], time: '2h',
    caption: 'The jump that broke the internet 🔥 #viral #street',
    images: [_postImgs[5]],
    likes: 31800, comments: 2200, shares: 1100, views: 890000,
    music: 'Essence — WizKid', isReel: true,
  ),
  FeedPost(
    id: 'r3', user: 'Sam Blake', handle: 'sam.bk',
    avatar: _avatars[7], verified: true, time: '5h',
    caption: 'Midnight run in the rain 🌧 no filter #rain #night #moody',
    images: [_postImgs[6]],
    likes: 7300, comments: 510, shares: 198, views: 145000,
    music: 'As It Was — Harry Styles', isReel: true,
  ),
];

List<CommentModel> get mockComments => [
  CommentModel(id: 'c1', user: 'zara.w',    avatar: _avatars[1], text: 'This is absolutely stunning 🔥', time: '2m',  likes: 14),
  CommentModel(id: 'c2', user: 'kai_shots', avatar: _avatars[2], text: 'The light in this shot is insane', time: '5m',  likes: 8),
  CommentModel(id: 'c3', user: 'nova.film', avatar: _avatars[3], text: 'Teach me your ways 🙏',            time: '8m',  likes: 3,  liked: true),
  CommentModel(id: 'c4', user: 'dxlan',     avatar: _avatars[4], text: 'Already saved this 💾',           time: '12m', likes: 22),
  CommentModel(id: 'c5', user: 'esme.art',  avatar: _avatars[5], text: 'On another level fr',             time: '18m', likes: 5),
];

const _emojis = ['❤️', '😂', '😮', '😢', '😡', '👏'];

// ═══════════════════════════════════════════════════════════════════════════════
// FEED SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
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

class _FeedScreenState extends State<FeedScreen>
    with TickerProviderStateMixin {

  // ── State ──────────────────────────────────────────────────────────────────
  FeedTab _tab = FeedTab.posts;
  bool _loading = true;
  bool _refreshing = false;
  bool _searchOpen = false;
  bool _showBackToTop = false;
  bool _showNewBanner = true;

  List<FeedPost>  _posts   = [];
  List<StoryItem> _stories = [];

  final _scrollCtrl    = ScrollController();
  final _searchCtrl    = TextEditingController();
  final _searchFocus   = FocusNode();

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _headerGlowCtrl;
  late AnimationController _newBannerCtrl;
  late AnimationController _searchBarCtrl;
  late Animation<double>   _searchBarAnim;

  @override
  void initState() {
    super.initState();
    _posts   = mockPosts;
    _stories = mockStories;

    _headerGlowCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _newBannerCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();

    _searchBarCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250),
    );
    _searchBarAnim = CurvedAnimation(parent: _searchBarCtrl, curve: Curves.easeOutCubic);

    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 600;
      if (show != _showBackToTop) setState(() => _showBackToTop = show);
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _headerGlowCtrl.dispose();
    _newBannerCtrl.dispose();
    _searchBarCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> _refresh() async {
    HapticFeedback.mediumImpact();
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _refreshing = false;
      _showNewBanner = false;
    });
    widget.onSnack('Feed updated ✨');
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchBarCtrl.forward();
      Future.delayed(const Duration(milliseconds: 80), () => _searchFocus.requestFocus());
    } else {
      _searchBarCtrl.reverse();
      _searchFocus.unfocus();
      _searchCtrl.clear();
    }
  }

  void _updatePost(String id, FeedPost Function(FeedPost) fn) {
    setState(() {
      final idx = _posts.indexWhere((p) => p.id == id);
      if (idx != -1) _posts[idx] = fn(_posts[idx]);
    });
  }

  void _toggleLike(FeedPost post) {
    HapticFeedback.lightImpact();
    _updatePost(post.id, (p) {
      p.liked  = !p.liked;
      p.likes += p.liked ? 1 : -1;
      return p;
    });
    if (!post.liked) widget.onSnack('Liked ❤️');
  }

  void _toggleSave(FeedPost post) {
    HapticFeedback.selectionClick();
    _updatePost(post.id, (p) { p.saved = !p.saved; return p; });
    widget.onSnack(post.saved ? 'Removed from saved' : 'Saved 🔖');
  }

  void _toggleFollow(FeedPost post) {
    HapticFeedback.selectionClick();
    _updatePost(post.id, (p) { p.following = !p.following; return p; });
    widget.onSnack(post.following ? 'Unfollowed' : 'Following @${post.handle}');
  }

  void _hidePost(String id) {
    setState(() => _posts.removeWhere((p) => p.id == id));
    widget.onSnack('Post hidden');
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg     = isDark ? BlinkColors.bgDark   : BlinkColors.bgLight;
    final txt    = isDark ? BlinkColors.textDark  : BlinkColors.textLight;
    final muted  = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;

    final feedPosts = _posts.where((p) => !p.isReel).toList();
    final reels     = _posts.where((p) =>  p.isReel).toList();

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: _showBackToTop && _tab == FeedTab.posts
          ? _BackToTopFab(onTap: () => _scrollCtrl.animateTo(
              0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic))
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header
            _FeedHeader(
              isDark:        isDark,
              txt:           txt,
              muted:         muted,
              glowCtrl:      _headerGlowCtrl,
              notifCount:    7,
              searchOpen:    _searchOpen,
              searchCtrl:    _searchCtrl,
              searchFocus:   _searchFocus,
              searchBarAnim: _searchBarAnim,
              profileAvatar: widget.profileAvatarUrl,
              onMenu:        () => widget.onSnack('Menu coming soon'),
              onSearch:      _toggleSearch,
              onNotif:       () => widget.onSnack('7 new notifications'),
              onProfile:     () => widget.onProfile(widget.profileUsername),
            ),

            // ── Tab row
            _TabRow(
              isDark:      isDark,
              activeTab:   _tab,
              refreshing:  _refreshing,
              onPosts:     () => setState(() { _tab = FeedTab.posts; }),
              onReels:     () => setState(() { _tab = FeedTab.reels; }),
              onRefresh:   _refresh,
            ),

            // ── Body
            Expanded(
              child: _tab == FeedTab.posts
                  ? _buildPostsBody(feedPosts, isDark, txt, muted)
                  : _ReelsFeed(
                      reels:     reels,
                      isDark:    isDark,
                      onSnack:   widget.onSnack,
                      onLike:    _toggleLike,
                      onSave:    _toggleSave,
                      onFollow:  _toggleFollow,
                      onComment: (p) => _showCommentSheet(p),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsBody(
      List<FeedPost> feedPosts, bool isDark, Color txt, Color muted) {
    return RefreshIndicator(
      color:           BlinkColors.brandPink,
      backgroundColor: isDark ? BlinkColors.surfaceDark : Colors.white,
      onRefresh:       _refresh,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // New post banner
          if (_showNewBanner)
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1), end: Offset.zero,
                ).animate(_newBannerCtrl),
                child: _NewPostBanner(onTap: _refresh),
              ),
            ),

          // Stories
          SliverToBoxAdapter(
            child: _StoriesRow(
              stories:  _stories,
              isDark:   isDark,
              txt:      txt,
              muted:    muted,
              onTap:    (s) => widget.onSnack(
                  s.isMe ? 'Opening camera…' : "${s.user}'s story"),
            ),
          ),

          SliverToBoxAdapter(
            child: Divider(
              color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight,
              height: 1, thickness: 1,
              indent: 20, endIndent: 20,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Skeleton or posts
          if (_loading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _PostSkeleton(isDark: isDark),
                childCount: 3,
              ),
            )
          else ...[
            if (_refreshing)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BlinkColors.brandPink),
                    ),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final post = feedPosts[i];
                  return _PostCard(
                    key:       ValueKey(post.id),
                    post:      post,
                    isDark:    isDark,
                    index:     i,
                    onLike:    () => _toggleLike(post),
                    onSave:    () => _toggleSave(post),
                    onFollow:  () => _toggleFollow(post),
                    onHide:    () => _hidePost(post.id),
                    onComment: () => _showCommentSheet(post),
                    onShare:   () => _showShareSheet(post),
                    onSnack:   widget.onSnack,
                    onProfile: widget.onProfile,
                  );
                },
                childCount: feedPosts.length,
              ),
            ),
          ],

          // Infinite scroll footer
          const SliverToBoxAdapter(
            child: _LoadMoreIndicator(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Sheets ─────────────────────────────────────────────────────────────────
  void _showCommentSheet(FeedPost post) {
    showModalBottomSheet(
      context:     context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentSheet(
        post:      post,
        isDark:    widget.isDark,
        onSnack:   widget.onSnack,
        onProfile: widget.onProfile,
      ),
    );
  }

  void _showShareSheet(FeedPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(isDark: widget.isDark, onSnack: widget.onSnack),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEADER
// ═══════════════════════════════════════════════════════════════════════════════
class _FeedHeader extends StatelessWidget {
  final bool isDark;
  final Color txt, muted;
  final AnimationController glowCtrl;
  final int notifCount;
  final bool searchOpen;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final Animation<double> searchBarAnim;
  final String profileAvatar;
  final VoidCallback onMenu, onSearch, onNotif, onProfile;

  const _FeedHeader({
    required this.isDark, required this.txt, required this.muted,
    required this.glowCtrl, required this.notifCount,
    required this.searchOpen, required this.searchCtrl,
    required this.searchFocus, required this.searchBarAnim,
    required this.profileAvatar,
    required this.onMenu, required this.onSearch,
    required this.onNotif, required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? BlinkColors.surfaceDark : Colors.white;
    return ClipRect(
      child: BackdropFilter(
        filter: const ColorFilter.mode(Colors.transparent, BlendMode.dst),
        child: Container(
          color: surface.withOpacity(0.92),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    // Menu
                    _IconBtn(icon: Icons.menu_rounded, color: txt, onTap: onMenu),
                    const Spacer(),

                    // Logo
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: glowCtrl,
                          builder: (_, __) => Text(
                            'Bl!nk',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: BlinkColors.brandPink,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(
                                  color: BlinkColors.brandPink.withOpacity(
                                      0.4 + 0.4 * glowCtrl.value),
                                  blurRadius: 12 + 12 * glowCtrl.value,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingDot(color: BlinkColors.online),
                            const SizedBox(width: 4),
                            Text('live', style: TextStyle(
                              fontSize: 10, color: BlinkColors.online,
                              fontWeight: FontWeight.w600,
                            )),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Search
                    _IconBtn(icon: Icons.search_rounded, color: txt, onTap: onSearch),
                    const SizedBox(width: 4),

                    // Notifications
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _IconBtn(icon: Icons.notifications_none_rounded, color: txt, onTap: onNotif),
                        if (notifCount > 0)
                          Positioned(
                            top: 0, right: 0,
                            child: _PulsingBadge(count: notifCount),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    // Avatar
                    GestureDetector(
                      onTap: onProfile,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BlinkColors.brandPink, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(profileAvatar, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 10, height: 10,
                              decoration: BoxDecoration(
                                color: BlinkColors.online,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? BlinkColors.surfaceDark : Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar (animated)
              SizeTransition(
                sizeFactor: searchBarAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _SearchBar(
                    isDark:    isDark,
                    ctrl:      searchCtrl,
                    focusNode: searchFocus,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB ROW
// ═══════════════════════════════════════════════════════════════════════════════
class _TabRow extends StatelessWidget {
  final bool isDark, refreshing;
  final FeedTab activeTab;
  final VoidCallback onPosts, onReels, onRefresh;

  const _TabRow({
    required this.isDark, required this.activeTab,
    required this.refreshing,
    required this.onPosts, required this.onReels, required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final muted  = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    return Container(
      color: isDark ? BlinkColors.bgDark : BlinkColors.bgLight,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          _TabPill(
            label: 'Posts', selected: activeTab == FeedTab.posts,
            onTap: onPosts, border: border, muted: muted,
          ),
          const SizedBox(width: 8),
          _TabPill(
            label: 'Reels', selected: activeTab == FeedTab.reels,
            onTap: onReels, border: border, muted: muted,
          ),
          const Spacer(),
          if (activeTab == FeedTab.posts)
            GestureDetector(
              onTap: onRefresh,
              child: AnimatedRotation(
                turns: refreshing ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                child: Icon(Icons.refresh_rounded, color: muted, size: 22),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color border, muted;

  const _TabPill({
    required this.label, required this.selected,
    required this.onTap, required this.border, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: selected ? BlinkColors.brandPink : Colors.transparent,
          border: Border.all(
            color: selected ? BlinkColors.brandPink : border,
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: BlinkColors.brandPink.withOpacity(0.35),
                  blurRadius: 14, spreadRadius: 0,
                )]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.white : muted,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STORIES ROW
// ═══════════════════════════════════════════════════════════════════════════════
class _StoriesRow extends StatelessWidget {
  final List<StoryItem> stories;
  final bool isDark;
  final Color txt, muted;
  final ValueChanged<StoryItem> onTap;

  const _StoriesRow({
    required this.stories, required this.isDark,
    required this.txt, required this.muted, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          final s = stories[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + i * 50),
            curve: Curves.easeOutBack,
            builder: (_, v, child) =>
                Opacity(opacity: v, child: Transform.scale(scale: v, child: child)),
            child: GestureDetector(
              onTap: () => onTap(s),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StoryAvatar(story: s, isDark: isDark),
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
            ),
          );
        },
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final StoryItem story;
  final bool isDark;
  const _StoryAvatar({required this.story, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    if (story.isMe) {
      return Container(
        width: 58, height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: BlinkColors.brandPink.withOpacity(0.1),
          border: Border.all(
            color: BlinkColors.borderDark, width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: const Icon(Icons.add, color: BlinkColors.accent, size: 22),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 58, height: 58,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: story.viewed
                ? null
                : const LinearGradient(
                    colors: [BlinkColors.brandPink, BlinkColors.lavender, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: story.viewed ? Colors.white24 : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: bg, width: 2),
            ),
            child: ClipOval(
              child: Image.network(story.avatar, fit: BoxFit.cover),
            ),
          ),
        ),
        if (story.online)
          Positioned(
            bottom: 2, right: 2,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: BlinkColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: bg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// POST CARD  (feature-packed)
// ═══════════════════════════════════════════════════════════════════════════════
class _PostCard extends StatefulWidget {
  final FeedPost post;
  final bool isDark;
  final int index;
  final VoidCallback onLike, onSave, onFollow, onHide, onComment, onShare;
  final ValueChanged<String> onSnack;
  final ValueChanged<String> onProfile;

  const _PostCard({
    super.key,
    required this.post, required this.isDark, required this.index,
    required this.onLike, required this.onSave, required this.onFollow,
    required this.onHide, required this.onComment, required this.onShare,
    required this.onSnack, required this.onProfile,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with TickerProviderStateMixin {
  // ── Local state ─────────────────────────────────────────────────────────────
  int  _carouselIdx  = 0;
  bool _captionExpanded = false;
  bool _showReactions   = false;
  bool _showMenu        = false;
  String? _reaction;

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _heartCtrl;
  late AnimationController _entranceCtrl;
  late AnimationController _likeScaleCtrl;
  late AnimationController _saveCtrl;
  late Animation<double> _heartScale;
  late Animation<double> _entranceAnim;
  late Animation<double> _likeScale;
  late Animation<double> _saveScale;

  // Double-tap
  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();

    _heartCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut));

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 60),
    )..forward();
    _entranceAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic);

    _likeScaleCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0),  weight: 50),
    ]).animate(_likeScaleCtrl);

    _saveCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300),
    );
    _saveScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(_saveCtrl);
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _entranceCtrl.dispose();
    _likeScaleCtrl.dispose();
    _saveCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  void _handleDoubleTap() {
    _heartCtrl.forward(from: 0);
    if (!widget.post.liked) widget.onLike();
    HapticFeedback.mediumImpact();
  }

  void _handleLikeTap() {
    _likeScaleCtrl.forward(from: 0);
    widget.onLike();
  }

  void _handleSaveTap() {
    _saveCtrl.forward(from: 0);
    widget.onSave();
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark   = widget.isDark;
    final post     = widget.post;
    final surface  = isDark ? BlinkColors.surfaceDark : Colors.white;
    final border   = isDark ? BlinkColors.borderDark  : BlinkColors.borderLight;
    final txt      = isDark ? BlinkColors.textDark    : BlinkColors.textLight;
    final muted    = isDark ? BlinkColors.mutedDark   : BlinkColors.mutedLight;

    return FadeTransition(
      opacity: _entranceAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(_entranceAnim),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border, width: 1),
            boxShadow: isDark ? [] : [
              BoxShadow(color: Colors.black.withOpacity(0.06),
                  blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
                child: Row(
                  children: [
                    // Avatar + online
                    GestureDetector(
                      onTap: () => widget.onProfile(post.handle),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BlinkColors.brandPink, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(post.avatar, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 11, height: 11,
                              decoration: BoxDecoration(
                                color: BlinkColors.online,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: surface, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Name + meta
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onProfile(post.handle),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(post.user, style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w700,
                                  color: txt,
                                )),
                                if (post.verified) ...[
                                  const SizedBox(width: 4),
                                  const _VerifiedBadge(),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                Text(post.time, style: TextStyle(
                                  fontSize: 11, color: muted)),
                                if (post.location != null) ...[
                                  Text(' · ', style: TextStyle(color: muted)),
                                  const Icon(Icons.location_on_rounded,
                                      size: 11, color: BlinkColors.brandPink),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(post.location!, style: TextStyle(
                                      fontSize: 11, color: muted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Follow button
                    _FollowButton(following: post.following, onTap: widget.onFollow),
                    const SizedBox(width: 4),

                    // Three-dot menu
                    _ThreeDotBtn(
                      isDark: isDark,
                      post:   post,
                      onHide: widget.onHide,
                      onSnack: widget.onSnack,
                    ),
                  ],
                ),
              ),

              // ── Image carousel ──────────────────────────────────────────────
              _ImageCarousel(
                images:  post.images,
                index:   _carouselIdx,
                onIndex: (i) => setState(() => _carouselIdx = i),
                onDoubleTap: _handleDoubleTap,
                heartCtrl:   _heartCtrl,
                heartScale:  _heartScale,
                liked:       post.liked,
              ),

              // ── Music tag ───────────────────────────────────────────────────
              if (post.music != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: _MusicTag(music: post.music!, isDark: isDark),
                ),

              // ── Caption ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: GestureDetector(
                  onTap: () => setState(() => _captionExpanded = !_captionExpanded),
                  child: _CaptionText(
                    text:     post.caption,
                    handle:   post.handle,
                    expanded: _captionExpanded,
                    txt:      txt,
                    muted:    muted,
                  ),
                ),
              ),

              // ── Poll ────────────────────────────────────────────────────────
              if (post.pollOptions != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: _PollWidget(
                    options:  post.pollOptions!,
                    isDark:   isDark,
                    onSnack:  widget.onSnack,
                  ),
                ),

              // ── Top likers ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: _TopLikers(post: post, txt: txt, muted: muted, surface: surface),
              ),

              // ── Action bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 2),
                child: Row(
                  children: [
                    // Like (with reaction long-press)
                    GestureDetector(
                      onTap:       _handleLikeTap,
                      onLongPress: () => setState(() => _showReactions = true),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Row(children: [
                            AnimatedBuilder(
                              animation: _likeScale,
                              builder: (_, child) => Transform.scale(
                                scale: _likeScale.value, child: child),
                              child: Icon(
                                post.liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: post.liked
                                    ? BlinkColors.brandPink
                                    : muted,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 5),
                            _CountLabel(n: post.likes, active: post.liked, muted: muted),
                          ]),
                          if (_showReactions)
                            _ReactionPicker(
                              onSelect: (e) {
                                setState(() {
                                  _reaction = e;
                                  _showReactions = false;
                                });
                                widget.onSnack('Reacted $e');
                              },
                              onClose: () => setState(() => _showReactions = false),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Comment
                    GestureDetector(
                      onTap: widget.onComment,
                      child: Row(children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: muted, size: 22),
                        const SizedBox(width: 5),
                        _CountLabel(n: post.comments, active: false, muted: muted),
                      ]),
                    ),
                    const SizedBox(width: 20),

                    // Share
                    GestureDetector(
                      onTap: widget.onShare,
                      child: Row(children: [
                        Icon(Icons.send_outlined, color: muted, size: 22),
                        const SizedBox(width: 5),
                        _CountLabel(n: post.shares, active: false, muted: muted),
                      ]),
                    ),

                    const Spacer(),

                    // Views
                    Row(children: [
                      Icon(Icons.visibility_outlined, color: muted, size: 14),
                      const SizedBox(width: 3),
                      Text(fmtNum(post.views),
                        style: TextStyle(fontSize: 11, color: muted)),
                    ]),
                    const SizedBox(width: 12),

                    // Save
                    GestureDetector(
                      onTap: _handleSaveTap,
                      child: AnimatedBuilder(
                        animation: _saveScale,
                        builder: (_, child) =>
                            Transform.scale(scale: _saveScale.value, child: child),
                        child: Icon(
                          post.saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: post.saved ? BlinkColors.brandPink : muted,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Comment preview ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: GestureDetector(
                  onTap: widget.onComment,
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: muted),
                      children: [
                        TextSpan(
                          text: 'zara.w ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700, color: txt),
                        ),
                        const TextSpan(text: 'This is absolutely stunning 🔥'),
                      ],
                    ),
                  ),
                ),
              ),

              // ── View all comments ───────────────────────────────────────────
              GestureDetector(
                onTap: widget.onComment,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                  child: Text(
                    'View all ${fmtNum(post.comments)} comments',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// IMAGE CAROUSEL
// ═══════════════════════════════════════════════════════════════════════════════
class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final int index;
  final ValueChanged<int> onIndex;
  final VoidCallback onDoubleTap;
  final AnimationController heartCtrl;
  final Animation<double> heartScale;
  final bool liked;

  const _ImageCarousel({
    required this.images, required this.index, required this.onIndex,
    required this.onDoubleTap, required this.heartCtrl,
    required this.heartScale, required this.liked,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = PageController(initialPage: index);
    return Stack(
      children: [
        GestureDetector(
          onDoubleTap: onDoubleTap,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.zero),
            child: SizedBox(
              height: 320,
              child: PageView.builder(
                controller: ctrl,
                onPageChanged: onIndex,
                itemCount: images.length,
                itemBuilder: (_, i) => Image.network(
                  images[i], fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: Colors.white.withOpacity(0.05),
                          child: const Center(child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: BlinkColors.brandPink,
                          )),
                        ),
                ),
              ),
            ),
          ),
        ),

        // Double-tap heart
        AnimatedBuilder(
          animation: heartCtrl,
          builder: (_, __) => heartScale.value > 0.01
              ? Center(
                  child: Transform.scale(
                    scale: heartScale.value,
                    child: const Icon(Icons.favorite_rounded,
                        color: BlinkColors.brandPink, size: 80),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Carousel counter badge
        if (images.length > 1)
          Positioned(
            top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('${index + 1}/${images.length}',
                style: const TextStyle(color: Colors.white,
                    fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),

        // Dot indicators
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width:  i == index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == index
                      ? BlinkColors.brandPink
                      : Colors.white.withOpacity(0.4),
                ),
              )),
            ),
          ),

        // Arrow prev
        if (index > 0)
          Positioned(
            left: 8, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () { ctrl.previousPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic); },
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),

        // Arrow next
        if (index < images.length - 1)
          Positioned(
            right: 8, top: 0, bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () { ctrl.nextPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic); },
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MUSIC TAG
// ═══════════════════════════════════════════════════════════════════════════════
class _MusicTag extends StatefulWidget {
  final String music;
  final bool isDark;
  const _MusicTag({required this.music, required this.isDark});
  @override
  State<_MusicTag> createState() => _MusicTagState();
}

class _MusicTagState extends State<_MusicTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _diskCtrl;

  @override
  void initState() {
    super.initState();
    _diskCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _diskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spinning disk
          AnimatedBuilder(
            animation: _diskCtrl,
            builder: (_, child) => Transform.rotate(
              angle: _diskCtrl.value * 2 * math.pi, child: child),
            child: Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [BlinkColors.brandPink, BlinkColors.lavender],
                ),
              ),
              child: const Center(
                child: Icon(Icons.music_note_rounded,
                    size: 12, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Ticker text
          Flexible(
            child: Text(
              widget.music,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: widget.isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CAPTION TEXT  (hashtag + mention highlighting)
// ═══════════════════════════════════════════════════════════════════════════════
class _CaptionText extends StatelessWidget {
  final String text, handle;
  final bool expanded;
  final Color txt, muted;

  const _CaptionText({
    required this.text, required this.handle,
    required this.expanded, required this.txt, required this.muted,
  });

  List<InlineSpan> _parse(String raw) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'(#\w+|@\w+)');
    int last = 0;
    for (final m in pattern.allMatches(raw)) {
      if (m.start > last) {
        spans.add(TextSpan(text: raw.substring(last, m.start)));
      }
      final word = m.group(0)!;
      spans.add(TextSpan(
        text: word,
        style: TextStyle(
          color: word.startsWith('#')
              ? BlinkColors.brandPink
              : const Color(0xFF38BDF8),
          fontWeight: FontWeight.w600,
        ),
      ));
      last = m.end;
    }
    if (last < raw.length) spans.add(TextSpan(text: raw.substring(last)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final display = expanded ? text : (text.length > 130 ? text.substring(0, 130) : text);
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 13, color: txt, height: 1.45),
        children: [
          TextSpan(text: '$handle ',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          ..._parse(display),
          if (!expanded && text.length > 130)
            TextSpan(text: '… more',
                style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// POLL WIDGET
// ═══════════════════════════════════════════════════════════════════════════════
class _PollWidget extends StatefulWidget {
  final List<PollOption> options;
  final bool isDark;
  final ValueChanged<String> onSnack;
  const _PollWidget({required this.options, required this.isDark, required this.onSnack});

  @override
  State<_PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<_PollWidget> {
  int? _voted;

  int get _total => widget.options.fold(0, (a, o) => a + o.votes);

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    final muted  = widget.isDark ? BlinkColors.mutedDark  : BlinkColors.mutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.options.asMap().entries.map((e) {
          final i   = e.key;
          final opt = e.value;
          final pct = _voted != null && _total > 0
              ? opt.votes / _total
              : 0.0;
          return GestureDetector(
            onTap: () {
              if (_voted != null) return;
              setState(() {
                _voted = i;
                opt.votes++;
              });
              widget.onSnack('Vote cast!');
              HapticFeedback.selectionClick();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _voted == i
                      ? BlinkColors.brandPink.withOpacity(0.6)
                      : border,
                  width: 1.2,
                ),
              ),
              child: Stack(
                children: [
                  // Fill bar
                  if (_voted != null)
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      widthFactor: pct,
                      child: Container(
                        height: 40,
                        color: i == _voted
                            ? BlinkColors.brandPink.withOpacity(0.15)
                            : Colors.white.withOpacity(0.04),
                      ),
                    ),
                  SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(opt.text, style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: widget.isDark ? Colors.white : Colors.black87,
                          )),
                          if (_voted != null)
                            Text('${(pct * 100).round()}%',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: i == _voted
                                    ? BlinkColors.brandPink
                                    : muted,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        Text(
          '${fmtNum(_total)} votes · Ends in 2 days',
          style: TextStyle(fontSize: 11, color: muted),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP LIKERS
// ═══════════════════════════════════════════════════════════════════════════════
class _TopLikers extends StatelessWidget {
  final FeedPost post;
  final Color txt, muted, surface;
  const _TopLikers({required this.post, required this.txt, required this.muted, required this.surface});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 20,
          child: Stack(
            children: [
              for (int i = 0; i < 3; i++)
                Positioned(
                  left: i * 14.0,
                  child: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: surface, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.network(_avatars[i + 1], fit: BoxFit.cover),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(fontSize: 11.5, color: muted),
              children: [
                const TextSpan(text: 'Liked by '),
                TextSpan(text: 'zara.w',
                    style: TextStyle(fontWeight: FontWeight.w700, color: txt)),
                TextSpan(text: ' and ${fmtNum(post.likes - 1)} others'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REACTION PICKER
// ═══════════════════════════════════════════════════════════════════════════════
class _ReactionPicker extends StatelessWidget {
  final ValueChanged<String> onSelect;
  final VoidCallback onClose;
  const _ReactionPicker({required this.onSelect, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32, left: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white12),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 4),
            )],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _emojis.map((e) => GestureDetector(
              onTap: () => onSelect(e),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(e, style: const TextStyle(fontSize: 22)),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FOLLOW BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _FollowButton extends StatelessWidget {
  final bool following;
  final VoidCallback onTap;
  const _FollowButton({required this.following, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: following
                ? Colors.white24
                : BlinkColors.brandPink,
            width: 1.2,
          ),
          color: following ? Colors.transparent : BlinkColors.brandPink.withOpacity(0.08),
        ),
        child: Text(
          following ? 'Following' : 'Follow',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: following ? Colors.white38 : BlinkColors.brandPink,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// THREE-DOT MENU
// ═══════════════════════════════════════════════════════════════════════════════
class _ThreeDotBtn extends StatelessWidget {
  final bool isDark;
  final FeedPost post;
  final VoidCallback onHide;
  final ValueChanged<String> onSnack;

  const _ThreeDotBtn({
    required this.isDark, required this.post,
    required this.onHide, required this.onSnack,
  });

  void _show(BuildContext ctx) {
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(isDark: isDark, onHide: onHide, onSnack: onSnack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _show(context),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(Icons.more_horiz_rounded,
            color: isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight,
            size: 22),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onHide;
  final ValueChanged<String> onSnack;
  const _MenuSheet({required this.isDark, required this.onHide, required this.onSnack});

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF0D0D1A) : Colors.white;
    final txt = isDark ? Colors.white : Colors.black87;
    final items = [
      _MenuItem(icon: Icons.volume_off_rounded,   label: 'Mute @user',     onTap: () { onSnack('User muted'); Navigator.pop(context); }),
      _MenuItem(icon: Icons.hide_source_rounded,  label: 'Hide post',       onTap: () { onHide();            Navigator.pop(context); }),
      _MenuItem(icon: Icons.link_rounded,         label: 'Copy link',       onTap: () { onSnack('Link copied!'); Navigator.pop(context); }),
      _MenuItem(icon: Icons.download_rounded,     label: 'Download',        onTap: () { onSnack('Downloaded'); Navigator.pop(context); }),
      _MenuItem(icon: Icons.flag_rounded,         label: 'Report post',     onTap: () { onSnack('Post reported'); Navigator.pop(context); }, danger: true),
    ];
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          ...items.map((item) => ListTile(
            leading: Icon(item.icon,
                color: item.danger ? Colors.redAccent : txt, size: 20),
            title: Text(item.label,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: item.danger ? Colors.redAccent : txt,
                )),
            onTap: item.onTap,
            shape: const RoundedRectangleBorder(),
          )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.danger = false});
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMMENT SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _CommentSheet extends StatefulWidget {
  final FeedPost post;
  final bool isDark;
  final ValueChanged<String> onSnack;
  final ValueChanged<String> onProfile;
  const _CommentSheet({required this.post, required this.isDark, required this.onSnack, required this.onProfile});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  late List<CommentModel> _comments;
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  String? _replyTo;

  @override
  void initState() {
    super.initState();
    _comments = List.from(mockComments);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _comments.insert(0, CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: 'you', avatar: _avatars[0],
        text: _replyTo != null ? '@$_replyTo $txt' : txt,
        time: 'now',
      ));
      _ctrl.clear();
      _replyTo = null;
    });
    widget.onSnack('Comment posted ✅');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final bg   = widget.isDark ? const Color(0xFF0D0D1A) : Colors.white;
    final txt  = widget.isDark ? BlinkColors.textDark    : BlinkColors.textLight;
    final muted = widget.isDark ? BlinkColors.mutedDark  : BlinkColors.mutedLight;
    final border = widget.isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize:     0.95,
      minChildSize:     0.4,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${fmtNum(widget.post.comments)} Comments',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close_rounded, color: muted, size: 22)),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // Comments list
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _comments.length,
                itemBuilder: (_, i) {
                  final c = _comments[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => widget.onProfile(c.user),
                          child: ClipOval(child: Image.network(
                            c.avatar, width: 32, height: 32, fit: BoxFit.cover)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(c.user, style: TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w700,
                                  color: txt)),
                                const SizedBox(width: 6),
                                Text(c.time, style: TextStyle(
                                  fontSize: 11, color: muted)),
                              ]),
                              const SizedBox(height: 3),
                              Text(c.text, style: TextStyle(
                                fontSize: 13, color: txt.withOpacity(0.85),
                                height: 1.4)),
                              const SizedBox(height: 6),
                              Row(children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _replyTo = c.user);
                                    _focus.requestFocus();
                                  },
                                  child: Text('Reply',
                                    style: TextStyle(fontSize: 11.5, color: muted))),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    c.liked = !c.liked;
                                    c.likes += c.liked ? 1 : -1;
                                  }),
                                  child: Row(children: [
                                    Icon(
                                      c.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 14,
                                      color: c.liked ? BlinkColors.brandPink : muted,
                                    ),
                                    if (c.likes > 0) ...[
                                      const SizedBox(width: 3),
                                      Text('${c.likes}', style: TextStyle(
                                        fontSize: 11, color: muted)),
                                    ],
                                  ]),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Reply indicator
            if (_replyTo != null)
              Container(
                color: Colors.white.withOpacity(0.04),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text('Replying to @$_replyTo',
                      style: TextStyle(fontSize: 12, color: muted)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _replyTo = null),
                      child: Icon(Icons.close_rounded, size: 16, color: muted)),
                  ],
                ),
              ),

            // Input row
            Container(
              padding: EdgeInsets.fromLTRB(
                  12, 8, 12, 12 + MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: border, width: 0.5))),
              child: Row(
                children: [
                  ClipOval(child: Image.network(
                    _avatars[0], width: 32, height: 32, fit: BoxFit.cover)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              focusNode:  _focus,
                              onSubmitted: (_) => _send(),
                              style: TextStyle(fontSize: 13, color: txt),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                hintText: _replyTo != null
                                    ? 'Reply to @$_replyTo…'
                                    : 'Add a comment…',
                                hintStyle: TextStyle(fontSize: 13, color: muted),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _ctrl.text += '😊',
                            child: Text('😊', style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 150),
                      child: Text('Post',
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: BlinkColors.brandPink)),
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

// ═══════════════════════════════════════════════════════════════════════════════
// SHARE SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _ShareSheet extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onSnack;
  const _ShareSheet({required this.isDark, required this.onSnack});

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF0D0D1A) : Colors.white;
    final txt = isDark ? Colors.white            : Colors.black87;

    final options = [
      {'icon': Icons.link_rounded,       'label': 'Copy Link'},
      {'icon': Icons.chat_bubble_outline,'label': 'Send as DM'},
      {'icon': Icons.auto_stories,       'label': 'Share to Story'},
      {'icon': Icons.share_rounded,      'label': 'More Options'},
    ];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Share post', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: txt)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: options.map((o) => GestureDetector(
              onTap: () {
                onSnack('${o['label']}');
                Navigator.pop(context);
              },
              child: Column(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Icon(o['icon'] as IconData,
                        color: txt, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(o['label'] as String,
                    style: TextStyle(fontSize: 11, color: txt.withOpacity(0.6))),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REELS FEED
// ═══════════════════════════════════════════════════════════════════════════════
typedef _PostAction = void Function(FeedPost);

class _ReelsFeed extends StatefulWidget {
  final List<FeedPost> reels;
  final bool isDark;
  final ValueChanged<String> onSnack;
  final _PostAction onLike, onSave, onFollow;
  final _PostAction onComment;

  const _ReelsFeed({
    required this.reels, required this.isDark, required this.onSnack,
    required this.onLike, required this.onSave, required this.onFollow,
    required this.onComment,
  });

  @override
  State<_ReelsFeed> createState() => _ReelsFeedState();
}

class _ReelsFeedState extends State<_ReelsFeed> {
  int    _activeIdx = 0;
  String _mode      = 'For You';
  final  _pageCtrl  = PageController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('🎬', style: TextStyle(fontSize: 52)),
            SizedBox(height: 12),
            Text('No reels yet',
                style: TextStyle(color: Colors.white54, fontSize: 16,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Upload a reel to see it here',
                style: TextStyle(color: Colors.white30, fontSize: 13)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageCtrl,
          scrollDirection: Axis.vertical,
          itemCount: widget.reels.length,
          onPageChanged: (i) => setState(() => _activeIdx = i),
          itemBuilder: (_, i) => _ReelCard(
            reel:     widget.reels[i],
            active:   _activeIdx == i,
            isDark:   widget.isDark,
            onSnack:  widget.onSnack,
            onLike:   () => widget.onLike(widget.reels[i]),
            onSave:   () => widget.onSave(widget.reels[i]),
            onFollow: () => widget.onFollow(widget.reels[i]),
            onComment:() => widget.onComment(widget.reels[i]),
          ),
        ),

        // Friends / For You toggle
        Positioned(
          top: 16, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['Friends', 'For You'].map((m) => GestureDetector(
                  onTap: () => setState(() => _mode = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _mode == m
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(m, style: TextStyle(
                      fontSize: 13,
                      fontWeight: _mode == m
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: _mode == m
                          ? Colors.white
                          : Colors.white54,
                    )),
                  ),
                )).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REEL CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _ReelCard extends StatefulWidget {
  final FeedPost reel;
  final bool active, isDark;
  final ValueChanged<String> onSnack;
  final VoidCallback onLike, onSave, onFollow, onComment;

  const _ReelCard({
    required this.reel, required this.active, required this.isDark,
    required this.onSnack,
    required this.onLike, required this.onSave,
    required this.onFollow, required this.onComment,
  });

  @override
  State<_ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<_ReelCard>
    with SingleTickerProviderStateMixin {
  bool   _playing = true;
  bool   _muted   = false;
  double _progress = 0;

  late AnimationController _progressCtrl;
  late AnimationController _heartCtrl;

  DateTime? _lastTap;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 15),
    );
    _heartCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    );
    if (widget.active) _progressCtrl.forward();
    _progressCtrl.addListener(
      () => setState(() => _progress = _progressCtrl.value));
  }

  @override
  void didUpdateWidget(_ReelCard old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _progressCtrl.forward(from: 0);
      setState(() => _playing = true);
    } else if (!widget.active && old.active) {
      _progressCtrl.stop();
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!).inMilliseconds < 300) {
      _heartCtrl.forward(from: 0);
      if (!widget.reel.liked) widget.onLike();
      HapticFeedback.mediumImpact();
    } else {
      setState(() {
        _playing = !_playing;
        _playing ? _progressCtrl.forward() : _progressCtrl.stop();
      });
    }
    _lastTap = now;
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;

    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.network(reel.images[0], fit: BoxFit.cover),

          // Gradient overlay
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000), Colors.transparent,
                  Colors.transparent, Color(0xCC000000),
                ],
                stops: [0.0, 0.3, 0.55, 1.0],
              ),
            ),
          ),

          // Progress bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(BlinkColors.brandPink),
              minHeight: 2.5,
            ),
          ),

          // Play/pause overlay
          if (!_playing)
            Center(
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 36),
              ),
            ),

          // Double-tap heart
          AnimatedBuilder(
            animation: _heartCtrl,
            builder: (_, __) {
              final v = math.sin(_heartCtrl.value * math.pi);
              return v > 0
                  ? Center(
                      child: Transform.scale(
                        scale: v * 1.4,
                        child: Opacity(
                          opacity: v,
                          child: const Icon(Icons.favorite_rounded,
                              color: BlinkColors.brandPink, size: 90),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),

          // Mute button
          Positioned(
            top: 52, right: 14,
            child: GestureDetector(
              onTap: () => setState(() => _muted = !_muted),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.black45, shape: BoxShape.circle),
                child: Icon(
                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white, size: 18),
              ),
            ),
          ),

          // Right sidebar
          Positioned(
            right: 12, bottom: 100,
            child: Column(
              children: [
                // Creator avatar + follow
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: BlinkColors.brandPink, width: 2.5)),
                      child: ClipOval(
                        child: Image.network(reel.avatar, fit: BoxFit.cover)),
                    ),
                    Positioned(
                      bottom: -8, left: 13,
                      child: GestureDetector(
                        onTap: widget.onFollow,
                        child: Container(
                          width: 20, height: 20,
                          decoration: const BoxDecoration(
                            color: BlinkColors.accent, shape: BoxShape.circle),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _ReelAction(
                  icon:  reel.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: reel.liked ? BlinkColors.brandPink : Colors.white,
                  label: fmtNum(reel.likes),
                  onTap: widget.onLike,
                ),
                const SizedBox(height: 20),
                _ReelAction(
                  icon:  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  label: fmtNum(reel.comments),
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 20),
                _ReelAction(
                  icon:  reel.saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: reel.saved ? BlinkColors.brandPink : Colors.white,
                  label: 'Save',
                  onTap: widget.onSave,
                ),
                const SizedBox(height: 20),
                _ReelAction(
                  icon:  Icons.send_outlined,
                  color: Colors.white,
                  label: fmtNum(reel.shares),
                  onTap: () => widget.onSnack('Link copied!'),
                ),
              ],
            ),
          ),

          // Creator info + music
          Positioned(
            left: 14, right: 76, bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('@${reel.handle}',
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: Colors.white)),
                  if (reel.verified) ...[
                    const SizedBox(width: 5),
                    const _VerifiedBadge(),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(
                  reel.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13, color: Color(0xCCFFFFFF), height: 1.4),
                ),
                if (reel.music != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.music_note_rounded,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(reel.music!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12, color: Colors.white70)),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
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
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LOADING SKELETONS
// ═══════════════════════════════════════════════════════════════════════════════
class _PostSkeleton extends StatefulWidget {
  final bool isDark;
  const _PostSkeleton({required this.isDark});
  @override
  State<_PostSkeleton> createState() => _PostSkeletonState();
}

class _PostSkeletonState extends State<_PostSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween<double>(begin: -2, end: 2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final surface = widget.isDark ? BlinkColors.surfaceDark : Colors.white;
    final base    = widget.isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04);
    final shine   = widget.isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08);

    Widget bone(double w, double h, {double r = 8}) {
      return AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: w, height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              begin: const Alignment(-1, 0),
              end:   const Alignment(1, 0),
              colors: [base, shine, base],
              stops: [
                ((_anim.value + 2) / 4).clamp(0.0, 1.0) - 0.3,
                ((_anim.value + 2) / 4).clamp(0.0, 1.0),
                ((_anim.value + 2) / 4).clamp(0.0, 1.0) + 0.3,
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            bone(42, 42, r: 21),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              bone(120, 12),
              const SizedBox(height: 6),
              bone(80, 10),
            ]),
          ]),
          const SizedBox(height: 14),
          bone(double.infinity, 200, r: 14),
          const SizedBox(height: 12),
          bone(double.infinity, 12),
          const SizedBox(height: 6),
          bone(200, 12),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MISC SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.6 + 0.4 * _ctrl.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PulsingBadge extends StatefulWidget {
  final int count;
  const _PulsingBadge({required this.count});
  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: 1.0 + 0.15 * _ctrl.value,
        child: Container(
          constraints: const BoxConstraints(minWidth: 16),
          height: 16, padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: BlinkColors.brandPink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('${widget.count}',
              style: const TextStyle(
                color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15, height: 15,
      decoration: const BoxDecoration(
        color: BlinkColors.brandPink, shape: BoxShape.circle),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
    );
  }
}

class _CountLabel extends StatelessWidget {
  final int n;
  final bool active;
  final Color muted;
  const _CountLabel({required this.n, required this.active, required this.muted});
  @override
  Widget build(BuildContext context) {
    return Text(fmtNum(n), style: TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: active ? BlinkColors.brandPink : muted,
    ));
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isDark;
  final TextEditingController ctrl;
  final FocusNode focusNode;
  const _SearchBar({required this.isDark, required this.ctrl, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.05 : 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Icon(Icons.search_rounded,
            color: isDark ? Colors.white30 : Colors.black26, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            focusNode:  focusNode,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              isDense: true, contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'Search posts, people, tags…',
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white30 : Colors.black38),
            ),
          ),
        ),
      ]),
    );
  }
}

class _NewPostBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _NewPostBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [BlinkColors.brandPink, BlinkColors.lavender],
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: BlinkColors.brandPink.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text('3 new posts · Tap to refresh',
              style: TextStyle(
                color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatefulWidget {
  const _LoadMoreIndicator();
  @override
  State<_LoadMoreIndicator> createState() => _LoadMoreIndicatorState();
}

class _LoadMoreIndicatorState extends State<_LoadMoreIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Loading more…',
            style: TextStyle(
              color: Colors.white24, fontSize: 13,
              fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BackToTopFab extends StatelessWidget {
  final VoidCallback onTap;
  const _BackToTopFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onTap,
      backgroundColor: BlinkColors.brandPink,
      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
    );
  }
}
