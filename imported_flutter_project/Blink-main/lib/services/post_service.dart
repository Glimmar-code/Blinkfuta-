import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blink/post_model.dart';
import 'package:blink/features/profile/user_profile_model.dart';
import 'dart:io';

class PostService {
  static final _client = Supabase.instance.client;

  /// Fetch latest feed posts from Supabase. Queries the `feed_posts` table
  /// joined with `profiles` to get the author's username and avatar.
  static Future<List<FeedPost>> fetchFeed() async {
    try {
      final resp = await _client
          .from('feed_posts')
          .select('''
            id,
            type,
            faculty,
            text,
            gradient,
            image_url,
            caption,
            like_count,
            comment_count,
            share_count,
            view_count,
            created_at,
            profiles!user_id!inner (
              username,
              avatar_url
            )
          ''')
          .order('created_at', ascending: false)
          .limit(50) as List<dynamic>;
      return resp.map((r) => _mapFeedRow(r as Map<String, dynamic>)).toList();
    } catch (e, st) {
      debugPrint('PostService.fetchFeed error: $e');
      debugPrintStack(stackTrace: st);
      throw Exception('Unable to load feed from Supabase.');
    }
  }

  /// Fetch posts authored by a specific username from Supabase.
  static Future<List<FeedPost>> fetchPostsByUser(String username) async {
    try {
      final resp = await _client
          .from('feed_posts')
          .select('''
            id,
            type,
            faculty,
            text,
            gradient,
            image_url,
            caption,
            like_count,
            comment_count,
            share_count,
            view_count,
            created_at,
            profiles!user_id!inner (
              username,
              avatar_url
            )
          ''')
          .eq('profiles.username', username)
          .order('created_at', ascending: false)
          .limit(50) as List<dynamic>;
      return resp.map((r) => _mapFeedRow(r as Map<String, dynamic>)).toList();
    } catch (e, st) {
      debugPrint('PostService.fetchPostsByUser error: $e');
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  /// Subscribe to real-time changes on the `feed_posts` table. The callback
  /// receives the full updated list of feed posts whenever a row is
  /// inserted, updated, or deleted.
  static RealtimeChannel subscribeToFeed({
    required void Function(List<FeedPost> posts) onUpdate,
  }) {
    final channel = _client
        .channel('public:feed_posts')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'feed_posts',
          callback: (payload) async {
            final posts = await fetchFeed();
            onUpdate(posts);
          },
        )
        .subscribe();
    return channel;
  }

  static FeedPost _mapFeedRow(Map<String, dynamic> r) {
    final typeString = (r['type'] as String?) ?? (r['kind'] as String?);
    final hasImages = (r['image_url'] as String?)?.isNotEmpty == true || (r['images'] as List<dynamic>?)?.isNotEmpty == true;
    final type = (typeString == 'photo' || typeString == 'image' || hasImages) ? PostType.photo : PostType.text;
    final image = (r['image_url'] as String?) ??
        ((r['images'] is List<dynamic> && (r['images'] as List<dynamic>).isNotEmpty)
            ? (r['images'] as List<dynamic>).first as String
            : null);
    final caption = (r['caption'] as String?) ?? (type == PostType.photo ? r['text'] as String? : null);

    // Handle the joined profiles object (could be a map or a list of maps)
    String username = 'unknown';
    String avatar = '';
    final profiles = r['profiles'];
    if (profiles is Map<String, dynamic>) {
      username = (profiles['username'] as String?) ?? username;
      avatar = (profiles['avatar_url'] as String?) ?? avatar;
    } else if (profiles is List && profiles.isNotEmpty) {
      final first = profiles.first as Map<String, dynamic>;
      username = (first['username'] as String?) ?? username;
      avatar = (first['avatar_url'] as String?) ?? avatar;
    }

    final createdAt = DateTime.tryParse(r['created_at'] as String? ?? '');
    return FeedPost(
      id: r['id'].toString(),
      type: type,
      user: username,
      avatar: avatar,
      faculty: (r['faculty'] as String?),
      time: _formatTime(r['created_at']),
      createdAt: createdAt,
      text: type == PostType.text ? r['text'] as String? : null,
      gradient: (r['gradient'] as List<dynamic>?)?.map((e) => e as String).toList(),
      image: image,
      caption: caption,
      likes: (r['like_count'] is int)
          ? r['like_count'] as int
          : (r['like_count'] is num ? (r['like_count'] as num).toInt() : 0),
      comments: (r['comment_count'] is int) ? r['comment_count'] as int : 0,
      shares: (r['share_count'] is int) ? r['share_count'] as int : 0,
      views: (r['view_count'] is int)
          ? r['view_count'] as int
          : (r['view_count'] is num ? (r['view_count'] as num).toInt() : 0),
    );
  }

  static String _formatTime(dynamic createdAt) {
    // Keep it simple: show minutes/hours/days ago based on createdAt when available.
    try {
      final dt = DateTime.parse(createdAt as String);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) {
      return 'now';
    }
  }

  /// Create a new feed post (text or images). Returns the created
  /// `ProfilePost` mapped from the inserted row, or null on failure.
  static Future<ProfilePost?> createProfilePost({
    required String authorUsername,
    required String authorFullName,
    required String authorAvatar,
    required String text,
    List<String>? images,
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final row = {
        'user_id': user.id,
        'type': (images != null && images.isNotEmpty) ? 'photo' : 'text',
        'text': text,
        'image_url': (images != null && images.isNotEmpty) ? images.first : null,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
      final resp = await _client.from('feed_posts').insert(row).select();
      if (resp == null) return null;
      final r = resp is List ? (resp.isNotEmpty ? resp.first as Map<String, dynamic> : null) : resp as Map<String, dynamic>?;
      if (r == null) return null;
      return ProfilePost(
        id: r['id'].toString(),
        kind: (r['type'] as String?) == 'photo' ? ProfilePostKind.image : ProfilePostKind.text,
        text: r['text'] as String? ?? '',
        images: (r['image_url'] as String?) != null ? [r['image_url'] as String] : [],
        createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
        likeCount: (r['like_count'] is int) ? r['like_count'] as int : 0,
        commentCount: (r['comment_count'] is int) ? r['comment_count'] as int : 0,
        repostCount: (r['share_count'] is int) ? r['share_count'] as int : 0,
        viewCount: (r['view_count'] is int) ? r['view_count'] as int : 0,
        authorUsername: authorUsername,
        authorFullName: authorFullName,
        authorAvatar: authorAvatar,
      );
    } catch (e, st) {
      debugPrint('PostService.createProfilePost error: $e');
      debugPrintStack(stackTrace: st);
      return null;
    }
  }

  /// Upload a file to Supabase Storage and return a public URL, or null
  /// on failure. `bucket` should exist in your Supabase project.
  static Future<String?> uploadPostAsset(File file, {String bucket = 'post-media'}) async {
    try {
      final ext = file.path.contains('.') ? file.path.split('.').last : 'jpg';
      final fileName = '${DateTime.now().toUtc().millisecondsSinceEpoch}.$ext';
      final pathInBucket = 'posts/$fileName';
      // upload the File object; FileOptions allows upsert
      await _client.storage.from(bucket).upload(pathInBucket, file, fileOptions: const FileOptions(upsert: true));
      final dynamic public = _client.storage.from(bucket).getPublicUrl(pathInBucket);
      // Normalize to a plain URL string. Different SDK versions return either a
      // string or a map-like object; coerce to a sensible string safely.
      if (public == null) return null;
      if (public is String) return public;
      if (public is Map && public.containsKey('publicUrl')) return public['publicUrl']?.toString();
      // Fallback to a best-effort string representation.
      return public.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<ProfilePost?> updateProfilePost({required String postId, String? text, List<String>? images}) async {
    try {
      final updates = <String, dynamic>{};
      if (text != null) updates['text'] = text;
      if (images != null) updates['image_url'] = images.isNotEmpty ? images.first : null;
      final resp = await _client.from('feed_posts').update(updates).eq('id', postId).select().maybeSingle();
      if (resp == null) return null;
      return _mapProfileRow(resp as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> deleteProfilePost(String postId) async {
    try {
      await _client.from('feed_posts').delete().eq('id', postId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static ProfilePost _mapProfileRow(Map<String, dynamic> r) {
    return ProfilePost(
      id: r['id'].toString(),
      kind: (r['type'] as String?) == 'photo' ? ProfilePostKind.image : ProfilePostKind.text,
      text: r['text'] as String? ?? '',
      images: (r['image_url'] as String?) != null ? [r['image_url'] as String] : [],
      createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
      likeCount: (r['like_count'] is int) ? r['like_count'] as int : 0,
      commentCount: (r['comment_count'] is int) ? r['comment_count'] as int : 0,
      repostCount: (r['share_count'] is int) ? r['share_count'] as int : 0,
      viewCount: (r['view_count'] is int) ? r['view_count'] as int : 0,
      authorUsername: (r['username'] as String?) ?? '',
      authorFullName: (r['author_full_name'] as String?) ?? '',
      authorAvatar: (r['author_avatar'] as String?) ?? '',
    );
  }
}