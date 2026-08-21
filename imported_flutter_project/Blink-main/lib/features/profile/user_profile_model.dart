class UserProfile {
  String id;
  String fullName;
  String username;
  String avatarUrl;
  String coverPhoto;
  String professionalHeadline;
  String currentJobTitle;
  String university;
  String faculty;
  String countryOfOrigin;
  String currentCityState;
  String bio;
  int followerCount;
  int followingCount;
  int profileViewsThisWeek;
  bool onlineNow;
  List<ProfilePost> posts;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
    required this.coverPhoto,
    required this.professionalHeadline,
    required this.currentJobTitle,
    required this.university,
    required this.faculty,
    required this.countryOfOrigin,
    required this.currentCityState,
    required this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.profileViewsThisWeek,
    required this.onlineNow,
    this.posts = const [],
  });

  UserProfile clone() {
    return UserProfile(
      id: id,
      fullName: fullName,
      username: username,
      avatarUrl: avatarUrl,
      coverPhoto: coverPhoto,
      professionalHeadline: professionalHeadline,
      currentJobTitle: currentJobTitle,
      university: university,
      faculty: faculty,
      countryOfOrigin: countryOfOrigin,
      currentCityState: currentCityState,
      bio: bio,
      followerCount: followerCount,
      followingCount: followingCount,
      profileViewsThisWeek: profileViewsThisWeek,
      onlineNow: onlineNow,
      posts: List.from(posts),
    );
  }

  List<ProfilePost> get feedPosts => posts.where((p) => !p.isReel).toList();
  List<ProfilePost> get reelPosts => posts.where((p) => p.isReel).toList();
}

enum ProfilePostKind { text, image, video }

class ProfilePost {
  final String id;
  final ProfilePostKind kind;
  final String text;
  final List<String> images;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int repostCount;
  final int viewCount;
  final bool isReel;
  final String authorUsername;
  final String authorFullName;
  final String authorAvatar;

  const ProfilePost({
    required this.id,
    required this.kind,
    required this.text,
    required this.images,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount,
    required this.viewCount,
    this.isReel = false,
    required this.authorUsername,
    required this.authorFullName,
    required this.authorAvatar,
  });
}

final kDemoMyProfile = UserProfile(
  id: 'user_me',
  fullName: 'Gbolahan Olowosile',
  username: 'golowosile',
  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop',
  coverPhoto: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1000&h=400&fit=crop',
  professionalHeadline: 'Product Lead • Creative Technologist',
  currentJobTitle: 'Founder at Blink',
  university: 'University of Lagos (UNILAG)',
  faculty: 'Engineering',
  countryOfOrigin: '🇳🇬 Nigeria',
  currentCityState: 'Lagos, Nigeria',
  bio: 'Building the future of campus connection 🚀✨',
  followerCount: 2450,
  followingCount: 380,
  profileViewsThisWeek: 312,
  onlineNow: true,
);
