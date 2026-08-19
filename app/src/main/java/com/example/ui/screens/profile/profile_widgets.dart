// profile_widgets.dart
// Small shared pieces used by MyProfileScreen / GuestProfileScreen.

import 'package:flutter/material.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart' show unsplash;
import 'package:blink/widgets/post_card.dart' show fmtNum;

import 'user_profile_model.dart';

/// Blue / gold / no verification checkmark.
class VerifiedMark extends StatelessWidget {
  final VerificationBadge badge;
  final double size;
  const VerifiedMark({super.key, required this.badge, this.size = 16});

  @override
  Widget build(BuildContext context) {
    if (badge == VerificationBadge.none) return const SizedBox.shrink();
    final color = badge == VerificationBadge.gold ? const Color(0xFFFFC53D) : const Color(0xFF1D9BF0);
    return Icon(Icons.verified, size: size, color: color);
  }
}

/// "#482 World" / "#7 Campus" pill.
class RankPill extends StatelessWidget {
  final String label;
  final int rank;
  const RankPill({super.key, required this.label, required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BlinkColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text('#$rank $label', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: BlinkColors.accent)),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color txt;
  final Color muted;
  final VoidCallback? onTap;
  const StatColumn({super.key, required this.label, required this.value, required this.txt, required this.muted, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: txt)),
            Text(label, style: TextStyle(fontSize: 11, color: muted)),
          ],
        ),
      ),
    );
  }
}

/// Generic small text chip, used for skills / hobbies / languages tags.
class TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isDark;
  const TagChip({super.key, required this.label, this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000);
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100), border: Border.all(color: border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: txt), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: txt)),
        ],
      ),
    );
  }
}

/// Section title used to break up the profile ("Skills", "About", ...).
class SectionHeader extends StatelessWidget {
  final String title;
  final Color txt;
  const SectionHeader({super.key, required this.title, required this.txt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: txt, letterSpacing: 0.2)),
    );
  }
}

/// Small icon+text row, e.g. "📍 Lagos, Nigeria" or "🎓 UNILAG".
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color muted;
  final Color? iconColor;
  const InfoRow({super.key, required this.icon, required this.text, required this.muted, this.iconColor});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? muted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: muted))),
        ],
      ),
    );
  }
}

/// Round social icon button, hidden if the underlying link is empty.
class SocialIconButton extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isDark;
  final VoidCallback onTap;
  const SocialIconButton({super.key, required this.icon, required this.value, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final bg = isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000);
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: txt),
        ),
      ),
    );
  }
}

/// Online / last-seen dot + label.
class PresenceLabel extends StatelessWidget {
  final bool online;
  final String label;
  final Color muted;
  const PresenceLabel({super.key, required this.online, required this.label, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: online ? const Color(0xFF2ECC71) : muted.withOpacity(0.5)),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class AchievementBadgeChip extends StatelessWidget {
  final Achievement achievement;
  final bool isDark;
  const AchievementBadgeChip({super.key, required this.achievement, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0x14FFFFFF) : const Color(0x0A000000);
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(achievement.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(achievement.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: txt)),
        ],
      ),
    );
  }
}
// ---------------------------------------------------------------------------
// New shared widgets — avatar, expandable "More Details", posts/reels tabs,
// and the followers/following list screen.
// ---------------------------------------------------------------------------

/// Full, uncropped circular avatar used at the top of a profile. Wrapped in
/// a [Hero] so opening Edit Profile (or a followers list -> profile) animates
/// smoothly. `radius` controls the on-screen size; the avatar is always
/// rendered as a complete circle, never clipped by the cover photo above it.
class ProfileAvatar extends StatelessWidget {
  final String heroTag;
  final String avatarUrl;
  final double radius;
  final Color ringColor;
  final Color backgroundColor;
  final Widget? badge;

  const ProfileAvatar({
    super.key,
    required this.heroTag,
    required this.avatarUrl,
    required this.ringColor,
    required this.backgroundColor,
    this.radius = 48,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return Hero(
      tag: heroTag,
      child: SizedBox(
        // Extra room so the ring + badge never get clipped by a parent.
        width: size + 8,
        height: size + 8,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3),
                color: backgroundColor,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: avatarUrl.isEmpty
                    ? Container(color: backgroundColor, child: Icon(Icons.person, color: ringColor, size: radius))
                    : Image.network(avatarUrl, fit: BoxFit.cover, width: size, height: size),
              ),
            ),
            if (badge != null) Positioned(right: -4, bottom: -4, child: badge!),
          ],
        ),
      ),
    );
  }
}

/// Collapsible "More Details" block. Everything below Academic (Contact &
/// Location, About, Links, Badges) is tucked in here so the profile opens
/// clean and expands on demand, with an animated chevron + size transition.
class MoreDetailsSection extends StatefulWidget {
  final Color txt;
  final Color muted;
  final bool isDark;
  final List<Widget> children;
  final bool initiallyExpanded;

  const MoreDetailsSection({
    super.key,
    required this.txt,
    required this.muted,
    required this.isDark,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<MoreDetailsSection> createState() => _MoreDetailsSectionState();
}

class _MoreDetailsSectionState extends State<MoreDetailsSection> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('More Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: widget.txt, letterSpacing: 0.2)),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: Icon(Icons.keyboard_arrow_down, color: widget.muted),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _open ? 1 : 0,
            child: _open
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: widget.children)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Posts / Reels / Likes / Saved swipeable tab strip shown on a profile.
class ProfileContentTabs extends StatefulWidget {
  final List<ProfilePost> posts;
  final List<ProfilePost> reels;
  final List<ProfilePost> likedPosts;
  final List<ProfilePost> savedPosts;
  final bool isDark;
  final Color txt;
  final Color muted;
  final Color accent;
  final bool isOwner;
  final ValueChanged<String> onSnack;

  const ProfileContentTabs({
    super.key,
    required this.posts,
    required this.reels,
    required this.likedPosts,
    required this.savedPosts,
    required this.isDark,
    required this.txt,
    required this.muted,
    required this.accent,
    required this.onSnack,
    this.isOwner = false,
  });

  @override
  State<ProfileContentTabs> createState() => _ProfileContentTabsState();
}

class _ProfileContentTabsState extends State<ProfileContentTabs> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
          child: TabBar(
            controller: _tab,
            isScrollable: false,
            labelColor: widget.accent,
            unselectedLabelColor: widget.muted,
            indicatorColor: widget.accent,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            tabs: const [
              Tab(icon: Icon(Icons.grid_on_outlined, size: 18), text: 'Posts'),
              Tab(icon: Icon(Icons.movie_creation_outlined, size: 18), text: 'Reels'),
              Tab(icon: Icon(Icons.favorite_border, size: 18), text: 'Likes'),
              Tab(icon: Icon(Icons.bookmark_border, size: 18), text: 'Saved'),
            ],
          ),
        ),
        SizedBox(
          // TabBarView needs a bounded height inside a scroll view; grow to
          // fit the tallest tab's content and animate between tabs.
          height: 640,
          child: TabBarView(
            controller: _tab,
            children: [
              _PostsList(posts: widget.posts, isDark: widget.isDark, txt: widget.txt, muted: widget.muted, accent: widget.accent, onSnack: widget.onSnack, emptyLabel: widget.isOwner ? 'Share your first post' : 'No posts yet'),
              _ReelsGrid(reels: widget.reels, isDark: widget.isDark, muted: widget.muted, onSnack: widget.onSnack),
              _PostsList(posts: widget.likedPosts, isDark: widget.isDark, txt: widget.txt, muted: widget.muted, accent: widget.accent, onSnack: widget.onSnack, emptyLabel: 'Nothing liked yet'),
              _PostsList(posts: widget.savedPosts, isDark: widget.isDark, txt: widget.txt, muted: widget.muted, accent: widget.accent, onSnack: widget.onSnack, emptyLabel: widget.isOwner ? 'Saved posts appear here' : 'Saved is private'),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color muted;
  const _EmptyTabState({required this.icon, required this.label, required this.muted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: muted),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, color: muted)),
          ],
        ),
      ),
    );
  }
}

class _PostsList extends StatelessWidget {
  final List<ProfilePost> posts;
  final bool isDark;
  final Color txt;
  final Color muted;
  final Color accent;
  final ValueChanged<String> onSnack;
  final String emptyLabel;
  const _PostsList({required this.posts, required this.isDark, required this.txt, required this.muted, required this.accent, required this.onSnack, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return _EmptyTabState(icon: Icons.article_outlined, label: emptyLabel, muted: muted);
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: posts.length,
      itemBuilder: (context, i) => PostCard(post: posts[i], isDark: isDark, txt: txt, muted: muted, accent: accent, onSnack: onSnack),
    );
  }
}

class _ReelsGrid extends StatelessWidget {
  final List<ProfilePost> reels;
  final bool isDark;
  final Color muted;
  final ValueChanged<String> onSnack;
  const _ReelsGrid({required this.reels, required this.isDark, required this.muted, required this.onSnack});

  @override
  Widget build(BuildContext context) {
    if (reels.isEmpty) return _EmptyTabState(icon: Icons.movie_creation_outlined, label: 'No reels yet', muted: muted);
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: reels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 3, crossAxisSpacing: 3, childAspectRatio: 9 / 16),
      itemBuilder: (context, i) {
        final r = reels[i];
        final thumb = (r.videoThumbnail ?? (r.hasImages ? r.images.first : ''));
        final url = thumb.startsWith('http') ? thumb : (thumb.isEmpty ? '' : unsplash(thumb));
        return InkWell(
          onTap: () => onSnack('Play reel'),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url.isNotEmpty) Image.network(url, fit: BoxFit.cover) else Container(color: BlinkColors.accent.withOpacity(0.15)),
              const Positioned(left: 4, bottom: 4, child: Icon(Icons.play_arrow, color: Colors.white, size: 16)),
            ],
          ),
        );
      },
    );
  }
}

/// A single post/reel card with animated like/repost/save + view count,
/// comment sheet, tag chips, and share.
class PostCard extends StatefulWidget {
  final ProfilePost post;
  final bool isDark;
  final Color txt;
  final Color muted;
  final Color accent;
  final ValueChanged<String> onSnack;
  const PostCard({super.key, required this.post, required this.isDark, required this.txt, required this.muted, required this.accent, required this.onSnack});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _liked = widget.post.likedByMe;
  late bool _saved = widget.post.savedByMe;
  late bool _reposted = widget.post.repostedByMe;
  late int _likes = widget.post.likeCount;
  late int _reposts = widget.post.repostCount;

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  void _toggleRepost() {
    setState(() {
      _reposted = !_reposted;
      _reposts += _reposted ? 1 : -1;
    });
    widget.onSnack(_reposted ? 'Reposted' : 'Repost removed');
  }

  void _toggleSave() {
    setState(() => _saved = !_saved);
    widget.onSnack(_saved ? 'Saved' : 'Removed from saved');
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark ? BlinkColors.bgDark : BlinkColors.bgLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: widget.muted.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),
            Text('Comments · ${widget.post.commentCount}', style: TextStyle(fontWeight: FontWeight.w800, color: widget.txt)),
            const Divider(height: 24),
            Expanded(
              child: widget.post.commentCount == 0
                  ? Center(child: Text('Be the first to comment', style: TextStyle(color: widget.muted)))
                  : ListView.builder(
                      controller: controller,
                      itemCount: widget.post.commentCount.clamp(0, 20),
                      itemBuilder: (_, i) => ListTile(
                        leading: const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                        title: Text('Commenter ${i + 1}', style: TextStyle(fontSize: 13, color: widget.txt)),
                        subtitle: Text('Nice one! 🔥', style: TextStyle(fontSize: 12, color: widget.muted)),
                      ),
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment…',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: const Icon(Icons.send, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTags() {
    if (widget.post.taggedUsernames.isEmpty) {
      widget.onSnack('No one tagged');
      return;
    }
    widget.onSnack('Tagged: ${widget.post.taggedUsernames.map((u) => '@$u').join(', ')}');
  }

  void _share() {
    widget.onSnack('Share sheet opened');
  }

  Widget _iconStat(IconData icon, String label, {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.elasticOut,
              child: Icon(icon, size: 17, color: active ? widget.accent : widget.muted),
            ),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, color: active ? widget.accent : widget.muted, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final border = widget.isDark ? BlinkColors.borderDark : BlinkColors.borderLight;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 16, backgroundImage: p.authorAvatar.isNotEmpty ? NetworkImage(p.authorAvatar.startsWith('http') ? p.authorAvatar : unsplash(p.authorAvatar)) : null),
              const SizedBox(width: 8),
              Expanded(
                child: Text(p.authorFullName.isNotEmpty ? p.authorFullName : '@${p.authorUsername}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.txt), overflow: TextOverflow.ellipsis),
              ),
              Text(_timeAgo(p.createdAt), style: TextStyle(fontSize: 11, color: widget.muted)),
            ],
          ),
          if (p.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(p.text, style: TextStyle(fontSize: 13.5, color: widget.txt, height: 1.35)),
          ],
          if (p.hasImages) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(aspectRatio: 4 / 3, child: Image.network(p.imageUrl(0), fit: BoxFit.cover)),
            ),
          ],
          if (p.taggedUsernames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, children: p.taggedUsernames.map((u) => TagChip(label: '@$u', icon: Icons.person_outline, isDark: widget.isDark)).toList()),
          ],
          const SizedBox(height: 6),
          Text('${fmtNum(p.viewCount)} views', style: TextStyle(fontSize: 11, color: widget.muted)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconStat(_liked ? Icons.favorite : Icons.favorite_border, fmtNum(_likes), active: _liked, onTap: _toggleLike),
              _iconStat(Icons.mode_comment_outlined, fmtNum(p.commentCount), onTap: _openComments),
              _iconStat(Icons.repeat, fmtNum(_reposts), active: _reposted, onTap: _toggleRepost),
              _iconStat(Icons.local_offer_outlined, p.taggedUsernames.isEmpty ? 'Tag' : '${p.taggedUsernames.length}', onTap: _openTags),
              _iconStat(_saved ? Icons.bookmark : Icons.bookmark_border, '', active: _saved, onTap: _toggleSave),
              _iconStat(Icons.share_outlined, '', onTap: _share),
            ],
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
  if (diff.inDays > 0) return '${diff.inDays}d';
  if (diff.inHours > 0) return '${diff.inHours}h';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m';
  return 'now';
}

/// Followers / Following list screen — tap any row's avatar or name to open
/// that person's profile via [onOpenProfile].
class FollowListScreen extends StatelessWidget {
  final String title;
  final List<FollowPreview> people;
  final bool isDark;
  final ValueChanged<FollowPreview> onOpenProfile;

  const FollowListScreen({super.key, required this.title, required this.people, required this.isDark, required this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: txt,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: people.isEmpty
          ? Center(child: Text('Nobody here yet', style: TextStyle(color: muted)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (context, i) {
                final person = people[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ListTile(
                    onTap: () => onOpenProfile(person),
                    leading: Hero(
                      tag: 'avatar_${person.username}',
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: person.avatarUrl.isNotEmpty ? NetworkImage(person.avatarUrl) : null,
                        child: person.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(child: Text(person.fullName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: txt), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 4),
                        VerifiedMark(badge: person.verification, size: 13),
                      ],
                    ),
                    subtitle: Text(
                      person.headline.isNotEmpty ? '@${person.username} · ${person.headline}' : '@${person.username}',
                      style: TextStyle(fontSize: 12, color: muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: txt,
                        side: BorderSide(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      child: Text(person.followingBack ? 'Following' : 'View', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}