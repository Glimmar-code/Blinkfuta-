// user_profile_model.dart
// Central data model for My Profile / Guest Profile / Edit Profile.
// Drop this in e.g. lib/models/user_profile_model.dart and fix the
// `post_model.dart` import path below to match your project.

import 'package:blink/post_model.dart'; // for `unsplash()` helper — adjust path as needed

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum VerificationBadge { none, blue, gold }

enum AvailabilityStatus {
  none('None'),
  openToCollabs('Open to Collabs'),
  lookingForStudyGroup('Looking for Study Group'),
  busy('Busy'),
  openToWork('Open to Work');

  final String label;
  const AvailabilityStatus(this.label);
}

enum RelationshipStatus {
  preferNotToSay('Prefer not to say'),
  single('Single'),
  taken('Taken'),
  married('Married'),
  itsComplicated("It's complicated");

  final String label;
  const RelationshipStatus(this.label);
}

enum Gender {
  preferNotToSay('Prefer not to say'),
  male('Male'),
  female('Female'),
  custom('Custom');

  final String label;
  const Gender(this.label);
}

enum ConnectStatus { none, requested, connected }

enum FieldVisibility { public, private }

/// Kind of content a profile post carries. A post can be pure text, or
/// text with one or more attached images.
enum ProfilePostKind { text, image }

/// Which strip of the profile tab bar a post belongs to.
enum ProfileTab { posts, reels, likes, saved }

// ---------------------------------------------------------------------------
// Small value types
// ---------------------------------------------------------------------------

/// A field that carries its own public/private visibility toggle
/// (used for email, phone, DOB, etc).
class PrivateField<T> {
  T value;
  FieldVisibility visibility;
  PrivateField(this.value, {this.visibility = FieldVisibility.private});

  bool get isPublic => visibility == FieldVisibility.public;
}

class SocialLinks {
  String website;
  String linkedin;
  String twitter;
  String instagram;
  String featuredLink; // Linktree-style single CTA link
  String featuredLinkLabel;

  SocialLinks({
    this.website = '',
    this.linkedin = '',
    this.twitter = '',
    this.instagram = '',
    this.featuredLink = '',
    this.featuredLinkLabel = '',
  });

  SocialLinks copy() => SocialLinks(
        website: website,
        linkedin: linkedin,
        twitter: twitter,
        instagram: instagram,
        featuredLink: featuredLink,
        featuredLinkLabel: featuredLinkLabel,
      );
}

class Achievement {
  final String label;
  final String emoji; // simple icon-as-emoji, swap for real assets later
  const Achievement(this.label, this.emoji);
}

class SkillEndorsement {
  final String skill;
  int endorsements;
  bool endorsedByMe;
  SkillEndorsement(this.skill, {this.endorsements = 0, this.endorsedByMe = false});
}

/// Lightweight stand-in for a full [UserProfile], used inside followers /
/// following lists so we don't have to hydrate every profile just to show
/// an avatar + name + tap-to-open.
class FollowPreview {
  final String username;
  final String fullName;
  final String avatar;
  final VerificationBadge verification;
  final String headline;
  bool followingBack;

  FollowPreview({
    required this.username,
    required this.fullName,
    required this.avatar,
    this.verification = VerificationBadge.none,
    this.headline = '',
    this.followingBack = false,
  });

  String get avatarUrl => avatar.startsWith('http') ? avatar : unsplash(avatar);
}

/// A single post on a profile — either plain text, or text + one/more
/// images. Reels are the same shape but flagged with [isReel]; likes/saved
/// tabs simply reference posts (possibly authored by other people).
class ProfilePost {
  final String id;
  final ProfilePostKind kind;
  String text;
  List<String> images; // unsplash ids / urls, empty for pure text posts
  final DateTime createdAt;
  final bool isReel;
  String? videoThumbnail; // used only when isReel == true

  int likeCount;
  int commentCount;
  int repostCount;
  int viewCount;
  bool likedByMe;
  bool savedByMe;
  bool repostedByMe;
  List<String> taggedUsernames;

  // Author info — mainly relevant on the "Likes" / "Saved" tabs where the
  // post may belong to someone else.
  final String authorUsername;
  final String authorFullName;
  final String authorAvatar;

  ProfilePost({
    required this.id,
    required this.kind,
    this.text = '',
    List<String>? images,
    DateTime? createdAt,
    this.isReel = false,
    this.videoThumbnail,
    this.likeCount = 0,
    this.commentCount = 0,
    this.repostCount = 0,
    this.viewCount = 0,
    this.likedByMe = false,
    this.savedByMe = false,
    this.repostedByMe = false,
    List<String>? taggedUsernames,
    this.authorUsername = '',
    this.authorFullName = '',
    this.authorAvatar = '',
  })  : images = images ?? [],
        createdAt = createdAt ?? DateTime.now(),
        taggedUsernames = taggedUsernames ?? [];

  bool get hasImages => images.isNotEmpty;
  String imageUrl(int i) => images[i].startsWith('http') ? images[i] : unsplash(images[i]);
}

// ---------------------------------------------------------------------------
// UserProfile — the big one
// ---------------------------------------------------------------------------

class UserProfile {
  // Core identity & visuals
  String fullName;
  String username; // without '@'
  String avatar; // unsplash path/id, run through unsplash()
  String coverPhoto; // unsplash path/id
  String pronouns;
  VerificationBadge verification;

  // Academic & professional
  String university;
  String faculty;
  String department;
  String courseOfStudy;
  String academicLevel; // 100L..500L, Alumni, Post-grad
  String graduationYear; // "Class of 2027"
  String professionalHeadline;
  String currentJobTitle;
  int worldRank;
  int campusRank;
  List<String> coreSkills;
  List<SkillEndorsement> skillEndorsements;

  // Contact & location
  PrivateField<String> email;
  PrivateField<String> phone;
  String countryOfOrigin; // free text, may include flag emoji
  String currentCityState;
  String campusHostelLocation;
  AvailabilityStatus availability;

  // Personal details & expression
  String bio;
  Gender gender;
  PrivateField<DateTime?> dob;
  RelationshipStatus relationshipStatus;
  List<String> hobbies;
  List<String> languages;
  String favoriteQuote;
  String customStatus;

  // Social links
  SocialLinks links;

  // Platform stats & gamification
  DateTime joinDate;
  int followerCount;
  int followingCount;
  int mutualConnections;
  bool onlineNow;
  DateTime lastSeen;
  int profileViewsThisWeek;
  List<Achievement> badges;

  // Interactive & content
  String? pinnedPostId;
  List<String> gridImages; // legacy media gallery, unsplash ids (kept for compatibility)
  int accentColorValue; // Color(value)
  ConnectStatus connectionState;

  // Posts / Reels / Likes / Saved — drives the swipeable tab strip.
  List<ProfilePost> posts;
  List<ProfilePost> reels;
  List<ProfilePost> likedPosts;
  List<ProfilePost> savedPosts;
  List<MarketItem> listings;

  // Followers / following previews — shown in the follower/following list screen.
  List<FollowPreview> followersPreview;
  List<FollowPreview> followingPreview;

  UserProfile({
    required this.fullName,
    required this.username,
    required this.avatar,
    required this.coverPhoto,
    this.pronouns = '',
    this.verification = VerificationBadge.none,
    this.university = '',
    this.faculty = '',
    this.department = '',
    this.courseOfStudy = '',
    this.academicLevel = '',
    this.graduationYear = '',
    this.professionalHeadline = '',
    this.currentJobTitle = '',
    this.worldRank = 0,
    this.campusRank = 0,
    List<String>? coreSkills,
    List<SkillEndorsement>? skillEndorsements,
    PrivateField<String>? email,
    PrivateField<String>? phone,
    this.countryOfOrigin = '',
    this.currentCityState = '',
    this.campusHostelLocation = '',
    this.availability = AvailabilityStatus.none,
    this.bio = '',
    this.gender = Gender.preferNotToSay,
    PrivateField<DateTime?>? dob,
    this.relationshipStatus = RelationshipStatus.preferNotToSay,
    List<String>? hobbies,
    List<String>? languages,
    this.favoriteQuote = '',
    this.customStatus = '',
    SocialLinks? links,
    DateTime? joinDate,
    this.followerCount = 0,
    this.followingCount = 0,
    this.mutualConnections = 0,
    this.onlineNow = false,
    DateTime? lastSeen,
    this.profileViewsThisWeek = 0,
    List<Achievement>? badges,
    this.pinnedPostId,
    List<String>? gridImages,
    this.accentColorValue = 0xFFFF006E,
    this.connectionState = ConnectStatus.none,
    List<ProfilePost>? posts,
    List<ProfilePost>? reels,
    List<ProfilePost>? likedPosts,
    List<ProfilePost>? savedPosts,
    List<MarketItem>? listings,
    List<FollowPreview>? followersPreview,
    List<FollowPreview>? followingPreview,
  })  : coreSkills = coreSkills ?? [],
        skillEndorsements = skillEndorsements ?? [],
        email = email ?? PrivateField(''),
        phone = phone ?? PrivateField(''),
        dob = dob ?? PrivateField(null),
        hobbies = hobbies ?? [],
        languages = languages ?? [],
        links = links ?? SocialLinks(),
        joinDate = joinDate ?? DateTime.now(),
        lastSeen = lastSeen ?? DateTime.now(),
        badges = badges ?? [],
        gridImages = gridImages ?? [],
        posts = posts ?? [],
        reels = reels ?? [],
        likedPosts = likedPosts ?? [],
        savedPosts = savedPosts ?? [],
        listings = listings ?? [],
        followersPreview = followersPreview ?? [],
        followingPreview = followingPreview ?? [];

  String get avatarUrl => avatar.startsWith('http') ? avatar : (avatar.isEmpty ? '' : unsplash(avatar));
  String get coverUrl => coverPhoto.startsWith('http') ? coverPhoto : (coverPhoto.isEmpty ? '' : unsplash(coverPhoto));

  /// True once the account has met whatever platform criteria unlocks a
  /// checkmark (points threshold, manual review, paid tier, etc). Verification
  /// is never something the user toggles themselves in Edit Profile — it's
  /// computed / granted by the backend and simply rendered here.
  bool get isEligibleForVerification => verification != VerificationBadge.none;

  String get joinedLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Joined ${months[joinDate.month - 1]} ${joinDate.year}';
  }

  String get lastSeenLabel {
    if (onlineNow) return 'Active now';
    final h = lastSeen.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = (h % 12 == 0) ? 12 : h % 12;
    final minute = lastSeen.minute.toString().padLeft(2, '0');
    return 'Last seen at $hour12:$minute $period';
  }

  UserProfile clone() => UserProfile(
        fullName: fullName,
        username: username,
        avatar: avatar,
        coverPhoto: coverPhoto,
        pronouns: pronouns,
        verification: verification,
        university: university,
        faculty: faculty,
        department: department,
        courseOfStudy: courseOfStudy,
        academicLevel: academicLevel,
        graduationYear: graduationYear,
        professionalHeadline: professionalHeadline,
        currentJobTitle: currentJobTitle,
        worldRank: worldRank,
        campusRank: campusRank,
        coreSkills: List.of(coreSkills),
        skillEndorsements: List.of(skillEndorsements),
        email: PrivateField(email.value, visibility: email.visibility),
        phone: PrivateField(phone.value, visibility: phone.visibility),
        countryOfOrigin: countryOfOrigin,
        currentCityState: currentCityState,
        campusHostelLocation: campusHostelLocation,
        availability: availability,
        bio: bio,
        gender: gender,
        dob: PrivateField(dob.value, visibility: dob.visibility),
        relationshipStatus: relationshipStatus,
        hobbies: List.of(hobbies),
        languages: List.of(languages),
        favoriteQuote: favoriteQuote,
        customStatus: customStatus,
        links: links.copy(),
        joinDate: joinDate,
        followerCount: followerCount,
        followingCount: followingCount,
        mutualConnections: mutualConnections,
        onlineNow: onlineNow,
        lastSeen: lastSeen,
        profileViewsThisWeek: profileViewsThisWeek,
        badges: List.of(badges),
        pinnedPostId: pinnedPostId,
        gridImages: List.of(gridImages),
        accentColorValue: accentColorValue,
        connectionState: connectionState,
        posts: List.of(posts),
        reels: List.of(reels),
        likedPosts: List.of(likedPosts),
        savedPosts: List.of(savedPosts),
        listings: List.of(listings),
        followersPreview: List.of(followersPreview),
        followingPreview: List.of(followingPreview),
      );

  /// A brand-new signup — every field starts blank/zeroed until the user
  /// fills in Edit Profile. Use this instead of [kDemoMyProfile] when
  /// provisioning a fresh account.
  factory UserProfile.blankSignup({required String username, required String fullName}) {
    return UserProfile(
      fullName: fullName,
      username: username,
      avatar: '',
      coverPhoto: '',
      joinDate: DateTime.now(),
      lastSeen: DateTime.now(),
      onlineNow: true,
    );
  }
}

// ---------------------------------------------------------------------------
// Demo data — replace with real repository/API calls
// ---------------------------------------------------------------------------

final UserProfile kDemoMyProfile = UserProfile(
  fullName: 'Ada Eze',
  username: 'adaeze',
  avatar: 'photo-1529139574466-a303027c1d8b?w=176&h=176&fit=crop',
  coverPhoto: 'photo-1519389950473-47ba0277781c?w=800&h=300&fit=crop',
  pronouns: 'She/Her',
  verification: VerificationBadge.blue,
  university: 'University of Lagos',
  faculty: 'Engineering',
  department: 'Computer Science',
  courseOfStudy: 'B.Sc. Computer Science',
  academicLevel: '400L',
  graduationYear: 'Class of 2027',
  professionalHeadline: 'Software Engineering Student · UI/UX Designer',
  currentJobTitle: 'Frontend Intern @ Flutterwave',
  worldRank: 482,
  campusRank: 7,
  coreSkills: ['Flutter', 'React', 'Figma', 'Firebase'],
  skillEndorsements: [
    SkillEndorsement('Flutter', endorsements: 34),
    SkillEndorsement('Figma', endorsements: 21),
  ],
  email: PrivateField('ada.eze@example.com', visibility: FieldVisibility.private),
  phone: PrivateField('+234 801 234 5678', visibility: FieldVisibility.private),
  countryOfOrigin: '🇳🇬 Nigeria',
  currentCityState: 'Lagos, Nigeria',
  campusHostelLocation: 'Moremi Hall',
  availability: AvailabilityStatus.openToCollabs,
  bio: 'Creative director · Photographer · Building in public.',
  gender: Gender.female,
  dob: PrivateField(DateTime(2003, 6, 12), visibility: FieldVisibility.private),
  relationshipStatus: RelationshipStatus.single,
  hobbies: ['Gaming', 'Coding', 'Football'],
  languages: ['English', 'Igbo', 'French'],
  favoriteQuote: 'Ship it, then perfect it.',
  customStatus: 'Studying for exams 📚',
  links: SocialLinks(
    website: 'adaeze.dev',
    linkedin: 'linkedin.com/in/adaeze',
    twitter: '@adaeze',
    instagram: '@ada.codes',
    featuredLink: 'linktr.ee/adaeze',
    featuredLinkLabel: 'All my links',
  ),
  joinDate: DateTime(2026, 6, 1),
  followerCount: 2400,
  followingCount: 312,
  mutualConnections: 0,
  onlineNow: true,
  profileViewsThisWeek: 148,
  badges: const [
    Achievement('Top Contributor', '🏆'),
    Achievement('Beta Tester', '🧪'),
  ],
  gridImages: const [
    'photo-1519389950473-47ba0277781c?w=400&h=400&fit=crop',
    'photo-1522199755839-a2bacb67c546?w=400&h=400&fit=crop',
    'photo-1517841905240-472988babdf9?w=400&h=400&fit=crop',
    'photo-1524504388940-b1c1722653e1?w=400&h=400&fit=crop',
  ],
  accentColorValue: 0xFFFF006E,
  posts: [
    ProfilePost(
      id: 'p1',
      kind: ProfilePostKind.image,
      text: 'Shipped the new onboarding flow today 🚀',
      images: const ['photo-1519389950473-47ba0277781c?w=600&h=600&fit=crop'],
      createdAt: DateTime(2026, 7, 28),
      likeCount: 312,
      commentCount: 24,
      repostCount: 9,
      viewCount: 4210,
      authorUsername: 'adaeze',
      authorFullName: 'Ada Eze',
      authorAvatar: 'photo-1529139574466-a303027c1d8b?w=176&h=176&fit=crop',
    ),
    ProfilePost(
      id: 'p2',
      kind: ProfilePostKind.text,
      text: 'Reminder: campus hackathon signups close Friday. Team up now!',
      createdAt: DateTime(2026, 7, 20),
      likeCount: 88,
      commentCount: 6,
      repostCount: 3,
      viewCount: 1520,
      authorUsername: 'adaeze',
      authorFullName: 'Ada Eze',
      authorAvatar: 'photo-1529139574466-a303027c1d8b?w=176&h=176&fit=crop',
    ),
  ],
  reels: [
    ProfilePost(
      id: 'r1',
      kind: ProfilePostKind.image,
      isReel: true,
      text: 'Day in my life as a CS student 🎬',
      videoThumbnail: 'photo-1522199755839-a2bacb67c546?w=400&h=700&fit=crop',
      images: const ['photo-1522199755839-a2bacb67c546?w=400&h=700&fit=crop'],
      createdAt: DateTime(2026, 7, 15),
      likeCount: 1900,
      commentCount: 140,
      repostCount: 55,
      viewCount: 32000,
      authorUsername: 'adaeze',
      authorFullName: 'Ada Eze',
      authorAvatar: 'photo-1529139574466-a303027c1d8b?w=176&h=176&fit=crop',
    ),
  ],
  likedPosts: const [],
  savedPosts: const [],
  followersPreview: [
    FollowPreview(username: 'tomiwa', fullName: 'Tomiwa Alade', avatar: 'photo-1517841905240-472988babdf9?w=176&h=176&fit=crop', verification: VerificationBadge.blue, headline: 'UNILAG · Mech Eng'),
    FollowPreview(username: 'zainab', fullName: 'Zainab Bello', avatar: 'photo-1524504388940-b1c1722653e1?w=176&h=176&fit=crop', headline: 'UI Designer'),
  ],
  followingPreview: [
    FollowPreview(username: 'chuka', fullName: 'Chuka Obi', avatar: 'photo-1522199755839-a2bacb67c546?w=176&h=176&fit=crop', verification: VerificationBadge.gold, headline: 'Product @ Paystack'),
  ],
);