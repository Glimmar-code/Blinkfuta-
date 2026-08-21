import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/features/profile/user_profile_model.dart';
import 'package:blink/widgets/faculty_badge.dart';

class MyProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final bool isDark;
  final Function(String) onSnack;

  const MyProfileScreen({
    super.key,
    required this.profile,
    required this.isDark,
    required this.onSnack,
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  int _activeTabIndex = 0; // 0: Posts, 1: Reels, 2: Saved

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _activeTabIndex == 0 
        ? widget.profile.feedPosts 
        : (_activeTabIndex == 1 ? widget.profile.reelPosts : widget.profile.posts);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(),
                _buildStats(),
                _buildActions(),
                _buildBio(),
                _buildTabs(),
              ],
            ),
          ),
          if (filteredPosts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        _activeTabIndex == 1 ? PhosphorIconsRegular.videoCamera : PhosphorIconsRegular.images,
                        size: 48,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _activeTabIndex == 1 ? 'No reels yet' : 'No posts yet',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(1),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = filteredPosts[index];
                    return GestureDetector(
                      onTap: () => widget.onSnack('View post ${post.id}'),
                      child: Container(
                        color: Colors.white.withOpacity(0.05),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (post.images.isNotEmpty)
                              Image.network(
                                post.images.first,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [BlinkColors.brandPink.withOpacity(0.3), BlinkColors.purple.withOpacity(0.3)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    post.text,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            if (post.isReel)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(PhosphorIconsFill.videoCamera, color: Colors.white, size: 16),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredPosts.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: widget.isDark ? const Color(0xFF141018) : Colors.white,
      leading: IconButton(
        icon: const Icon(PhosphorIconsRegular.caretLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.shareNetwork, color: Colors.white),
          onPressed: () => widget.onSnack('Share profile'),
        ),
        IconButton(
          icon: const Icon(PhosphorIconsRegular.dotsThreeVertical, color: Colors.white),
          onPressed: () => widget.onSnack('Settings'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.profile.coverPhoto,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Transform.translate(
      offset: const Offset(0, -50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 54,
              backgroundColor: BlinkColors.brandPink,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.profile.avatarUrl),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.profile.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: BlinkColors.accent, size: 18),
              ],
            ),
            Text(
              '@${widget.profile.username}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              widget.profile.professionalHeadline,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem('Followers', widget.profile.followerCount.toString()),
        _buildDivider(),
        _buildStatItem('Following', widget.profile.followingCount.toString()),
        _buildDivider(),
        _buildStatItem('Views', widget.profile.profileViewsThisWeek.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onSnack('Edit profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BlinkColors.brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(PhosphorIconsRegular.gear, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            widget.profile.bio,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(PhosphorIconsRegular.graduationCap, size: 16, color: Colors.white.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(widget.profile.university, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem('Posts', _activeTabIndex == 0, 0),
          _buildTabItem('Reels', _activeTabIndex == 1, 1),
          _buildTabItem('Saved', _activeTabIndex == 2, 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool active, int index) {
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? BlinkColors.brandPink : Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 40,
            color: active ? BlinkColors.brandPink : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
