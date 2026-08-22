import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../post_model.dart';
import '../features/profile/user_profile_model.dart';
import '../services/profile_service.dart';
import '../services/post_service.dart';
import '../widgets/faculty_badge.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  final bool isDark;
  final Function(String) onProfile;
  final Function(String) onSnack;

  const SearchScreen({super.key, required this.isDark, required this.onProfile, required this.onSnack});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _q = '';
  
  bool _isLoading = false;
  List<UserProfile> _users = [];
  List<FeedPost> _posts = [];

  static const _trending = ['#SIMME', '#SBMS', '#fashion', '#medlife', '#editorial', '#grind', '#Ghana'];

  @override
  void initState() {
    super.initState();
    _fetchTrending();
  }

  Future<void> _fetchTrending() async {
    setState(() => _isLoading = true);
    // Fetch some default users for 'People you may know'
    _users = await ProfileService.searchProfiles('');
    setState(() => _isLoading = false);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _q = query;
      _isLoading = true;
    });
    
    if (query.isEmpty) {
      await _fetchTrending();
      setState(() {
        _posts = [];
        _isLoading = false;
      });
      return;
    }

    final users = await ProfileService.searchProfiles(query);
    final posts = await PostService.searchPosts(query);

    if (mounted) {
      setState(() {
        _users = users;
        _posts = posts;
        _isLoading = false;
      });
    }
  }

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
                  onSubmitted: (v) => _performSearch(v),
                  style: TextStyle(color: txt, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search users, hashtags, topics...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_q.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close, color: muted, size: 20),
                  onPressed: () {
                    _controller.clear();
                    _performSearch('');
                  },
                ),
            ],
          ),
        ),
        
        if (_q.isEmpty) ...[
          const SizedBox(height: 24),
          Text('TRENDING', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending
                .map((tag) => GestureDetector(
                      onTap: () {
                        _controller.text = tag;
                        _performSearch(tag);
                      },
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
        ],

        const SizedBox(height: 24),
        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else ...[
          if (_users.isNotEmpty) ...[
            Text(_q.isEmpty ? 'PEOPLE YOU MAY KNOW' : 'USERS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted, letterSpacing: 1)),
            const SizedBox(height: 12),
            ..._users.take(5).map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    onTap: () => widget.onProfile(u.username),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 21, backgroundImage: NetworkImage(resolveImageUrl(u.avatarUrl))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.fullName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: txt)),
                              if (u.faculty.isNotEmpty) ...[const SizedBox(height: 3), FacultyBadge(tag: u.faculty)],
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => widget.onSnack('Following @${u.username}'),
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
                  ),
                )),
          ],

          if (_posts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('POSTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted, letterSpacing: 1)),
            const SizedBox(height: 12),
            ..._posts.map((post) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(
                post: post,
                isDark: widget.isDark,
                onProfileNav: widget.onProfile,
                onSnack: widget.onSnack,
              ),
            )),
          ],
        ],
      ],
    );
  }
}