import 'package:flutter/material.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/post_model.dart';
import 'package:blink/widgets/faculty_badge.dart';
import 'package:blink/widgets/post_card.dart' show fmtNum;
import 'package:blink/services/profile_service.dart';
import 'package:blink/services/follow_service.dart';

import 'user_profile_model.dart';
import 'profile_widgets.dart';

class GuestProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final bool isDark;
  final ValueChanged<String> onSnack;

  const GuestProfileScreen({super.key, required this.profile, required this.isDark, required this.onSnack});

  @override
  State<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfileScreen> {
  late ConnectStatus _connectionState = widget.profile.connectionState;
  late bool _following = false;
  bool _loading = true;

  Color get _accent => Color(widget.profile.accentColorValue);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await ProfileService.fetchByUsername(widget.profile.username);
      final followersPreview = await FollowService.fetchFollowersPreview(p.username);
      final followingPreview = await FollowService.fetchFollowingPreview(p.username);
      final followerCount = await FollowService.fetchFollowerCount(p.username);
      final followingCount = await FollowService.fetchFollowingCount(p.username);
      if (!mounted) return;
      setState(() {
        widget.profile.fullName = p.fullName;
        widget.profile.avatar = p.avatar;
        widget.profile.coverPhoto = p.coverPhoto;
        widget.profile.bio = p.bio;
        widget.profile.followerCount = followerCount;
        widget.profile.followingCount = followingCount;
        widget.profile.followersPreview = followersPreview;
        widget.profile.followingPreview = followingPreview;
        widget.profile.posts = p.posts;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onConnectTap() {
    setState(() {
      _connectionState = switch (_connectionState) {
        ConnectStatus.none => ConnectStatus.requested,
        ConnectStatus.requested => ConnectStatus.none,
        ConnectStatus.connected => ConnectStatus.connected,
      };
    });
    final msg = switch (_connectionState) {
      ConnectStatus.none => 'Request cancelled',
      ConnectStatus.requested => 'Connection request sent',
      ConnectStatus.connected => 'Already connected',
    };
    widget.onSnack(msg);
  }

  String get _connectLabel => switch (_connectionState) {
        ConnectStatus.none => 'Connect',
        ConnectStatus.requested => 'Requested',
        ConnectStatus.connected => 'Connected',
      };

  void _openFollowList({required bool followers}) {
    final p = widget.profile;
    final list = followers ? p.followersPreview : p.followingPreview;
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
    final guest = UserProfile(
      fullName: person.fullName,
      username: person.username,
      avatar: person.avatar,
      coverPhoto: '',
      verification: person.verification,
      professionalHeadline: person.headline,
      accentColorValue: widget.profile.accentColorValue,
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
    final p = widget.profile;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    final accent = _accent;
    const avatarRadius = 50.0;
    const avatarOverlap = avatarRadius;

    return Scaffold(
      backgroundColor: bg,
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
                    icon: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                    onPressed: () => widget.onSnack('Share profile'),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: p.coverPhoto.isNotEmpty
                    ? Image.network(p.coverUrl, key: ValueKey(p.coverPhoto), fit: BoxFit.cover)
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -avatarOverlap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + action buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ProfileAvatar(
                          heroTag: 'avatar_${p.username}',
                          avatarUrl: p.avatarUrl,
                          radius: avatarRadius,
                          ringColor: accent,
                          backgroundColor: bg,
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => widget.onSnack('Message ${p.fullName}'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: txt,
                                side: BorderSide(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              child: const Text('Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _following = !_following);
                                  widget.onSnack(_following ? 'Following!' : 'Unfollowed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _following ? Colors.transparent : accent,
                                  foregroundColor: _following ? muted : Colors.white,
                                  side: BorderSide(color: _following ? const Color(0x40FFFFFF) : accent, width: 1.5),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  elevation: 0,
                                ),
                                child: Text(_following ? 'Following' : 'Follow', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Flexible(child: Text(p.fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: txt))),
                        const SizedBox(width: 6),
                        VerifiedMark(badge: p.verification),
                      ],
                    ),
                    Row(
                      children: [
                        Text('@${p.username}', style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w600)),
                        if (p.pronouns.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text('· ${p.pronouns}', style: TextStyle(fontSize: 13, color: muted)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    PresenceLabel(online: p.onlineNow, label: p.lastSeenLabel, muted: muted),

                    const SizedBox(height: 10),
                    if (p.professionalHeadline.isNotEmpty)
                      Text(p.professionalHeadline, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: txt)),

                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (p.faculty.isNotEmpty) FacultyBadge(tag: p.faculty),
                        RankPill(label: 'World', rank: p.worldRank),
                        RankPill(label: 'Campus', rank: p.campusRank),
                        if (p.availability != AvailabilityStatus.none)
                          TagChip(label: p.availability.label, icon: Icons.bolt, isDark: isDark),
                      ],
                    ),

                    if (p.customStatus.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(p.customStatus, style: TextStyle(fontSize: 12, color: txt)),
                      ),
                    ],

                    const SizedBox(height: 14),
                    // Connect CTA (secondary, professional-network style)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _connectionState == ConnectStatus.connected ? null : _onConnectTap,
                        icon: Icon(
                          _connectionState == ConnectStatus.connected ? Icons.check_circle_outline : Icons.person_add_alt_1_outlined,
                          size: 16,
                        ),
                        label: Text(_connectLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _connectionState == ConnectStatus.connected ? accent : txt,
                          side: BorderSide(color: _connectionState == ConnectStatus.connected ? accent : (isDark ? BlinkColors.borderDark : BlinkColors.borderLight)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                    ),

                    if (p.mutualConnections > 0) ...[
                      const SizedBox(height: 10),
                      Text('${p.mutualConnections} mutual connections', style: TextStyle(fontSize: 12, color: muted)),
                    ],

                    const SizedBox(height: 18),
                    if (p.bio.isNotEmpty) Text(p.bio, style: TextStyle(fontSize: 13, color: muted, height: 1.4)),

                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatColumn(label: 'Posts', value: '${p.posts.length}', txt: txt, muted: muted),
                        StatColumn(label: 'Followers', value: fmtNum(p.followerCount), txt: txt, muted: muted, onTap: () => _openFollowList(followers: true)),
                        StatColumn(label: 'Following', value: fmtNum(p.followingCount), txt: txt, muted: muted, onTap: () => _openFollowList(followers: false)),
                      ],
                    ),

                    const SizedBox(height: 22),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SectionHeader(title: 'Academic', txt: txt),
                    InfoRow(icon: Icons.school_outlined, text: p.university, muted: muted),
                    InfoRow(icon: Icons.account_balance_outlined, text: [p.faculty, p.department].where((e) => e.isNotEmpty).join(' · '), muted: muted),
                    InfoRow(icon: Icons.menu_book_outlined, text: p.courseOfStudy, muted: muted),
                    InfoRow(icon: Icons.stairs_outlined, text: [p.academicLevel, p.graduationYear].where((e) => e.isNotEmpty).join(' · '), muted: muted),
                    if (p.currentJobTitle.isNotEmpty) InfoRow(icon: Icons.work_outline, text: p.currentJobTitle, muted: muted),

                    if (p.coreSkills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SectionHeader(title: 'Skills', txt: txt),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: p.coreSkills.map((s) {
                          final endorsement = p.skillEndorsements.where((e) => e.skill == s);
                          final e = endorsement.isNotEmpty ? endorsement.first : null;
                          return InkWell(
                            onTap: () => widget.onSnack('Endorsed $s'),
                            borderRadius: BorderRadius.circular(100),
                            child: TagChip(
                              label: e != null && e.endorsements > 0 ? '$s · ${e.endorsements}' : s,
                              icon: e?.endorsedByMe == true ? Icons.thumb_up : null,
                              isDark: isDark,
                            ),
                          );
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
                        // Contact & location — only fields the owner marked public are shown.
                        if (p.email.isPublic || p.phone.isPublic || p.countryOfOrigin.isNotEmpty || p.currentCityState.isNotEmpty) ...[
                          SectionHeader(title: 'Contact & Location', txt: txt),
                          if (p.email.isPublic) InfoRow(icon: Icons.mail_outline, text: p.email.value, muted: muted),
                          if (p.phone.isPublic) InfoRow(icon: Icons.call_outlined, text: p.phone.value, muted: muted),
                          InfoRow(icon: Icons.flag_outlined, text: p.countryOfOrigin, muted: muted),
                          InfoRow(icon: Icons.location_on_outlined, text: p.currentCityState, muted: muted),
                        ],

                        if (p.hobbies.isNotEmpty || p.languages.isNotEmpty || p.favoriteQuote.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          SectionHeader(title: 'About', txt: txt),
                          if (p.favoriteQuote.isNotEmpty) ...[
                            Text('"${p.favoriteQuote}"', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: txt)),
                            const SizedBox(height: 10),
                          ],
                          if (p.hobbies.isNotEmpty)
                            Wrap(spacing: 8, runSpacing: 8, children: p.hobbies.map((h) => TagChip(label: h, isDark: isDark)).toList()),
                          if (p.languages.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: p.languages.map((l) => TagChip(label: l, icon: Icons.translate, isDark: isDark)).toList(),
                            ),
                          ],
                        ],

                        if (p.links.website.isNotEmpty ||
                            p.links.linkedin.isNotEmpty ||
                            p.links.twitter.isNotEmpty ||
                            p.links.instagram.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          SectionHeader(title: 'Links', txt: txt),
                          Row(
                            children: [
                              SocialIconButton(icon: Icons.link, value: p.links.website, isDark: isDark, onTap: () => widget.onSnack('Open website')),
                              SocialIconButton(icon: Icons.business_center_outlined, value: p.links.linkedin, isDark: isDark, onTap: () => widget.onSnack('Open LinkedIn')),
                              SocialIconButton(icon: Icons.alternate_email, value: p.links.twitter, isDark: isDark, onTap: () => widget.onSnack('Open X/Twitter')),
                              SocialIconButton(icon: Icons.camera_alt_outlined, value: p.links.instagram, isDark: isDark, onTap: () => widget.onSnack('Open Instagram')),
                            ],
                          ),
                          if (p.links.featuredLink.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => widget.onSnack('Open ${p.links.featuredLink}'),
                              icon: const Icon(Icons.star_outline, size: 16),
                              label: Text(p.links.featuredLinkLabel.isNotEmpty ? p.links.featuredLinkLabel : p.links.featuredLink),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: txt,
                                side: BorderSide(color: isDark ? BlinkColors.borderDark : BlinkColors.borderLight),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                            ),
                          ],
                        ],

                        if (p.badges.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          SectionHeader(title: 'Badges & Achievements', txt: txt),
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: p.badges.map((a) => AchievementBadgeChip(achievement: a, isDark: isDark)).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(p.joinedLabel, style: TextStyle(fontSize: 11, color: muted)),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Posts / Reels / Likes / Saved — swipe between tabs.
                    ProfileContentTabs(
                      posts: p.posts,
                      reels: p.reels,
                      likedPosts: p.likedPosts,
                      savedPosts: p.savedPosts,
                      isDark: isDark,
                      txt: txt,
                      muted: muted,
                      accent: accent,
                      isOwner: false,
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
}