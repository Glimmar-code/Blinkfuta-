import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:blink/config/theme.dart';
import 'package:blink/features/profile/user_profile_model.dart';

class GuestProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final bool isDark;
  final Function(String) onSnack;

  const GuestProfileScreen({
    super.key,
    required this.profile,
    required this.isDark,
    required this.onSnack,
  });

  @override
  State<GuestProfileScreen> createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfileScreen> {
  int _activeTabIndex = 0; // 0: Posts, 1: Reels

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _activeTabIndex == 0 
        ? widget.profile.feedPosts 
        : widget.profile.reelPosts;

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
      expandedHeight: 180,
      pinned: true,
      backgroundColor: widget.isDark ? const Color(0xFF141018) : Colors.white,
      leading: IconButton(
        icon: const Icon(PhosphorIconsRegular.caretLeft, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          widget.profile.coverPhoto,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Transform.translate(
      offset: const Offset(0, -40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: BlinkColors.brandPink,
              child: CircleAvatar(
                radius: 41,
                backgroundImage: NetworkImage(widget.profile.avatarUrl),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.profile.fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '@${widget.profile.username}',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
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
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onSnack('Following @${widget.profile.username}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BlinkColors.brandPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Icon(PhosphorIconsRegular.chatCircle, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.profile.bio,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.5),
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
