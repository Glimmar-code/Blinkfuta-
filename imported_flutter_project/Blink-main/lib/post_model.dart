/// Data models + mock data ported 1:1 from the Figma export's mock arrays
/// (STORIES, FEED_POSTS/GRAD_POSTS/PHOTO_POSTS, LEADERBOARD, MARKET_ITEMS,
/// CHATS, MY_GRID_IMGS, ACTIVITIES, COMMENTS_DATA).
///
/// Image fields store the Unsplash path fragment used in the Figma file
/// (e.g. "photo-xxxx?w=80&h=80&fit=crop"); [unsplash] turns that into a
/// full URL for Image.network. Swap these for real asset/network URLs
/// whenever you wire up a backend.
library models;

String unsplash(String path) => 'https://images.unsplash.com/$path';

// ─── Stories ────────────────────────────────────────────────────────────────

class Story {
  final int id;
  final String user;
  final String avatar;
  final bool isMe;
  final bool online;

  const Story({
    required this.id,
    required this.user,
    required this.avatar,
    this.isMe = false,
    required this.online,
  });
}

const stories = <Story>[
  Story(id: 0, user: 'You', avatar: 'photo-1529139574466-a303027c1d8b?w=80&h=80&fit=crop', isMe: true, online: true),
  Story(id: 1, user: 'zara.ed', avatar: 'photo-1509631179647-0177331693ae?w=80&h=80&fit=crop', online: true),
  Story(id: 2, user: 'marco_v', avatar: 'photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop', online: false),
  Story(id: 3, user: 'luna', avatar: 'photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop', online: true),
  Story(id: 4, user: 'alex_c', avatar: 'photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop', online: false),
  Story(id: 5, user: 'nadia.r', avatar: 'photo-1534528741775-53994a69daeb?w=80&h=80&fit=crop', online: true),
  Story(id: 6, user: 'kai.lens', avatar: 'photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop', online: false),
];

// ─── Feed posts (text-gradient posts + photo posts, unified) ───────────────

enum PostType { text, photo }

enum VerificationBadge { none, blue, gold }

class FeedPost {
  final String id;
  final PostType type;
  final String user;
  final String avatar;
  final String? faculty;
  final String time;
  final DateTime? createdAt;
  final String? text; // text-gradient posts
  final List<String>? gradient; // hex strings, text posts only
  final String? image; // photo posts
  final String? caption; // photo posts
  int likes;
  final int comments;
  final int shares;
  final int views;
  bool liked;
  final bool isReel;
  final VerificationBadge verificationBadge;

  FeedPost({
    required this.id,
    required this.type,
    required this.user,
    required this.avatar,
    this.faculty,
    required this.time,
    this.createdAt,
    this.text,
    this.gradient,
    this.image,
    this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
    this.views = 0,
    this.liked = false,
    this.isReel = false,
    this.verificationBadge = VerificationBadge.none,
  });
}

class Post {
  final String id;
  final String name;
  final String handle;
  final String avatarInitial;
  final String time;
  final String text;
  final PostType type;
  final String? imageUrl;
  int likes;
  int shares;
  bool isLiked;
  bool isBookmarked;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarInitial,
    required this.time,
    required this.text,
    required this.type,
    this.imageUrl,
    this.likes = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.comments = const [],
  });
}

// ─── Leaderboard ────────────────────────────────────────────────────────────

class LeaderboardUser {
  final int rank;
  final String user;
  final String? faculty;
  final int pts;
  final String badge;
  final String avatar;

  const LeaderboardUser({
    required this.rank,
    required this.user,
    this.faculty,
    required this.pts,
    required this.badge,
    required this.avatar,
  });
}

const leaderboard = <LeaderboardUser>[
  LeaderboardUser(rank: 1, user: 'zara.editorial', faculty: null, pts: 98700, badge: '🏆', avatar: 'photo-1509631179647-0177331693ae?w=80&h=80&fit=crop'),
  LeaderboardUser(rank: 2, user: 'dr.osei', faculty: 'SBMS', pts: 84200, badge: '🥈', avatar: 'photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop'),
  LeaderboardUser(rank: 3, user: 'sophia_kim', faculty: 'SIMME', pts: 71500, badge: '🥉', avatar: 'photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop'),
  LeaderboardUser(rank: 4, user: 'luna.style', faculty: null, pts: 56100, badge: '⭐', avatar: 'photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop'),
  LeaderboardUser(rank: 5, user: 'marco_v', faculty: 'SIMME', pts: 43800, badge: '⭐', avatar: 'photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop'),
];

// ─── Market (ALUTA MARKET) ───────────────────────────────────────────────────
//
// Extended for the ALUTA MARKET feature. `MarketItem` now carries everything
// the feed, filters, product detail, and seller-onboarding screens need.
// Old call sites that only used {id, title, price, img, seller, tag} still
// compile — every new field has a default — but `price` is now a `double`
// (was `String`) so it can be filtered/sorted; use `item.priceLabel` for the
// old "₵280"-style display string.

/// Mirrors `VerificationBadge` in `features/profile/user_profile_model.dart`.
/// Duplicated here (rather than imported) to keep this file dependency-free;
/// the two enums are kept in sync by hand — if you add a tier there, add it
/// here too.
enum SellerTier { none, blue, gold }

extension SellerTierX on SellerTier {
  bool get canSell => this == SellerTier.blue || this == SellerTier.gold;
  String get label => switch (this) {
        SellerTier.blue => 'Blue Tick Verified',
        SellerTier.gold => 'Gold Tick Verified',
        SellerTier.none => 'Not Verified',
      };
}

enum ItemCondition { brandNew, used, refurbished }

extension ItemConditionX on ItemCondition {
  String get label => switch (this) {
        ItemCondition.brandNew => 'Brand New',
        ItemCondition.used => 'Used',
        ItemCondition.refurbished => 'Refurbished',
      };
}

class MarketItem {
  final int id;
  final String title;
  final String description;
  final double price;
  final bool negotiable;
  final String img; // cover image (Unsplash path fragment, same convention as elsewhere)
  final List<String> images; // gallery — falls back to [img] if empty
  final String seller;
  final String sellerAvatar;
  final SellerTier sellerTier;
  final String tag; // primary category, kept for backward compatibility
  final List<String> tags; // trending/topic tags, e.g. ['back-to-school', 'hot-deal']
  final String location; // e.g. "Lagos"
  final ItemCondition condition;
  final bool isPromoted;
  final int viewCount;
  final int chatCount;
  final DateTime? _postedAtRaw;

  /// Falls back to a fixed date if no explicit `postedAt` was supplied —
  /// none of the seed items below set one, so "Newest" sort treats them
  /// as tied until real posts (with real timestamps) come from Supabase.
  DateTime get postedAt => _postedAtRaw ?? _fallbackPostedAt;
  static final DateTime _fallbackPostedAt = DateTime(2026, 1, 1);

  MarketItem({
    required this.id,
    required this.title,
    required this.price,
    required this.img,
    required this.seller,
    required this.tag,
    this.description = '',
    this.negotiable = false,
    this.images = const [],
    this.sellerAvatar = '',
    this.sellerTier = SellerTier.none,
    this.tags = const [],
    this.location = 'Lagos',
    this.condition = ItemCondition.used,
    this.isPromoted = false,
    this.viewCount = 0,
    this.chatCount = 0,
    DateTime? postedAt,
  }) : _postedAtRaw = postedAt;

  /// Old-style display string, e.g. "₵280". Keep using ₦ elsewhere in the
  /// UI where the copy explicitly talks about Naira/Paystack fees.
  String get priceLabel => '₵${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  List<String> get gallery => images.isNotEmpty ? images : [img];

  bool get isTrending => viewCount >= 50 || chatCount >= 10;

  MarketItem copyWith({bool? isPromoted, int? viewCount, int? chatCount}) {
    return MarketItem(
      id: id,
      title: title,
      description: description,
      price: price,
      negotiable: negotiable,
      img: img,
      images: images,
      seller: seller,
      sellerAvatar: sellerAvatar,
      sellerTier: sellerTier,
      tag: tag,
      tags: tags,
      location: location,
      condition: condition,
      isPromoted: isPromoted ?? this.isPromoted,
      viewCount: viewCount ?? this.viewCount,
      chatCount: chatCount ?? this.chatCount,
      postedAt: _postedAtRaw,
    );
  }
}

final marketItems = <MarketItem>[
  MarketItem(
    id: 1,
    title: 'Vintage Leather Jacket',
    description: 'Genuine leather, barely worn, size M. Picked up in Milan — no rips, no cracking, smells like new leather not old closet.',
    price: 280,
    negotiable: true,
    img: 'photo-1551028719-00167b16eac5?w=600&h=600&fit=crop',
    seller: 'zara.editorial',
    sellerAvatar: 'photo-1509631179647-0177331693ae?w=80&h=80&fit=crop',
    sellerTier: SellerTier.gold,
    tag: "Men's Fashion",
    tags: const ['trending', 'streetwear'],
    location: 'Lagos',
    condition: ItemCondition.used,
    isPromoted: true,
    viewCount: 212,
    chatCount: 18,
  ),
  MarketItem(
    id: 2,
    title: 'Medical Anatomy Atlas (7th Ed.)',
    description: 'Full-colour anatomy atlas, all plates intact, minor highlighter marks in chapter 3 only.',
    price: 95,
    img: 'photo-1532012197267-da84d127e765?w=600&h=600&fit=crop',
    seller: 'dr.osei',
    sellerAvatar: 'photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop',
    sellerTier: SellerTier.blue,
    tag: 'Books',
    tags: const ['medschool'],
    location: 'Accra',
    condition: ItemCondition.used,
    viewCount: 34,
    chatCount: 4,
  ),
  MarketItem(
    id: 3,
    title: 'Canon EF 50mm f/1.8 STM',
    description: 'The nifty-fifty. Comes with front/rear caps and a UV filter. No fungus, no scratches on glass.',
    price: 650,
    negotiable: true,
    img: 'photo-1516035069371-29a1b244cc32?w=600&h=600&fit=crop',
    seller: 'luna.style',
    sellerAvatar: 'photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
    sellerTier: SellerTier.gold,
    tag: 'Cameras & Photography',
    tags: const ['trending', 'hot-deal'],
    location: 'Lagos',
    condition: ItemCondition.refurbished,
    isPromoted: true,
    viewCount: 501,
    chatCount: 47,
  ),
  MarketItem(
    id: 4,
    title: 'Graphic Design Course (Full Access)',
    description: 'Lifetime access code to a 40-hour graphic design bundle. Certificate included.',
    price: 45,
    img: 'photo-1626785774573-4b799315345d?w=600&h=600&fit=crop',
    seller: 'kai.lens',
    sellerAvatar: 'photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop',
    sellerTier: SellerTier.blue,
    tag: 'Online Courses & Tutorials',
    tags: const ['back-to-school'],
    location: 'Kumasi',
    condition: ItemCondition.brandNew,
    viewCount: 61,
    chatCount: 6,
  ),
];

// ─── Chats ──────────────────────────────────────────────────────────────────

class Chat {
  final int id;
  final String user;
  final String avatar;
  final String lastMsg;
  final String time;
  final int unread;
  final bool online;

  const Chat({
    required this.id,
    required this.user,
    required this.avatar,
    required this.lastMsg,
    required this.time,
    required this.unread,
    required this.online,
  });
}

const chats = <Chat>[
  Chat(id: 1, user: 'zara.editorial', avatar: 'photo-1529139574466-a303027c1d8b?w=80&h=80&fit=crop', lastMsg: 'Dropping the collab next week 🔥', time: '2m', unread: 3, online: true),
  Chat(id: 2, user: 'marco_v', avatar: 'photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop', lastMsg: 'Bro check the new edit', time: '15m', unread: 1, online: true),
  Chat(id: 3, user: 'sophia_kim', avatar: 'photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop', lastMsg: 'Thank you!! 🙏', time: '1h', unread: 0, online: false),
  Chat(id: 4, user: 'luna.style', avatar: 'photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop', lastMsg: "Can't wait for the shoot", time: '3h', unread: 0, online: false),
];

class ChatMessage {
  final int id;
  final String from; // 'me' | 'them'
  final String text;
  final String time;

  const ChatMessage({required this.id, required this.from, required this.text, required this.time});
}

List<ChatMessage> mockThreadFor(Chat chat) => [
      const ChatMessage(id: 1, from: 'them', text: 'Dropping the collab next week 🔥', time: '2:14 PM'),
      const ChatMessage(id: 2, from: 'me', text: "Can't wait!! What are we shooting?", time: '2:15 PM'),
      const ChatMessage(id: 3, from: 'them', text: 'Editorial concept — think Balenciaga meets street 🔥', time: '2:16 PM'),
    ];

// ─── Profile grid ───────────────────────────────────────────────────────────

const myGridImages = <String>[
  'photo-1509631179647-0177331693ae?w=200&h=260&fit=crop',
  'photo-1469334031218-e382a71b716b?w=200&h=180&fit=crop',
  'photo-1529139574466-a303027c1d8b?w=200&h=200&fit=crop',
  'photo-1515886657613-9f3515b0c78f?w=200&h=300&fit=crop',
  'photo-1483985988355-763728e1935b?w=200&h=180&fit=crop',
  'photo-1490481651871-ab68de25d43d?w=200&h=220&fit=crop',
];

// ─── Activity feed (menu sheet) ─────────────────────────────────────────────

class ActivityItem {
  final int id;
  final String user;
  final String action;
  final String time;
  final String avatar;

  const ActivityItem({
    required this.id,
    required this.user,
    required this.action,
    required this.time,
    required this.avatar,
  });
}

const activities = <ActivityItem>[
  ActivityItem(id: 1, user: 'sophia_kim', action: 'liked your post', time: '2m', avatar: 'photo-1438761681033-6461ffad8d80?w=60&h=60&fit=crop'),
  ActivityItem(id: 2, user: 'marco_v', action: 'started following you', time: '5m', avatar: 'photo-1507003211169-0a1dd7228f2d?w=60&h=60&fit=crop'),
  ActivityItem(id: 3, user: 'luna_style', action: 'commented on your reel', time: '12m', avatar: 'photo-1494790108377-be9c29b29330?w=60&h=60&fit=crop'),
  ActivityItem(id: 4, user: 'dr.osei', action: 'saved your post', time: '1h', avatar: 'photo-1472099645785-5658abf4ff4e?w=60&h=60&fit=crop'),
];

// ─── Comments ───────────────────────────────────────────────────────────────

class CommentReply {
  final int id;
  final String user;
  final String avatar;
  final String text;

  const CommentReply({required this.id, required this.user, required this.avatar, required this.text});
}

class Comment {
  final int id;
  final String user;
  final String avatar;
  final String text;
  final String time;
  int likes;
  bool liked;
  final List<CommentReply> replies;

  Comment({
    required this.id,
    required this.user,
    required this.avatar,
    required this.text,
    required this.time,
    required this.likes,
    this.liked = false,
    this.replies = const [],
  });
}

List<Comment> mockComments() => [
      Comment(
        id: 1,
        user: 'marco_v',
        avatar: 'photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop',
        text: 'This is fire 🔥🔥 @sophia_kim you have to see this',
        time: '10m',
        likes: 84,
        replies: const [
          CommentReply(id: 11, user: 'sophia_kim', avatar: 'photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop', text: "I'm obsessed 😍"),
        ],
      ),
      Comment(
        id: 2,
        user: 'luna.style',
        avatar: 'photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
        text: 'The lighting on this is unreal ✨ #editorial',
        time: '32m',
        likes: 46,
      ),
      Comment(
        id: 3,
        user: 'kai.lens',
        avatar: 'photo-1500648767791-00dcc994a43e?w=80&h=80&fit=crop',
        text: 'Need the BTS of this shoot please',
        time: '1h',
        likes: 12,
      ),
    ];