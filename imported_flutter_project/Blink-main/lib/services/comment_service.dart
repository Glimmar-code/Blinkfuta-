import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../post_model.dart';

class CommentService {
  static final _client = Supabase.instance.client;

  static Future<List<Comment>> fetchComments(String postId) async {
    try {
      final resp = await _client.from('comments').select('''
        id, text, created_at, likes, 
        profiles!inner (username, avatar_url)
      ''').eq('post_id', postId).order('created_at', ascending: false) as List<dynamic>;

      return resp.map((r) {
        final profile = r['profiles'] ?? {};
        return Comment(
          id: r['id'] ?? 0,
          user: profile['username'] ?? 'Unknown',
          avatar: profile['avatar_url'] ?? '',
          text: r['text'] ?? '',
          time: r['created_at'] ?? 'now',
          likes: r['likes'] ?? 0,
          liked: false,
        );
      }).toList();
    } catch (e) {
      debugPrint('CommentService.fetchComments error: $e');
      return mockComments();
    }
  }

  static Future<bool> postComment(String postId, String text) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('CommentService.postComment error: $e');
      return false;
    }
  }

  static Future<bool> toggleLike(int commentId, bool isLiked) async {
    try {
      final resp = await _client.from('comments').select('likes').eq('id', commentId).maybeSingle();
      if (resp != null) {
        int current = (resp['likes'] as num?)?.toInt() ?? 0;
        current += isLiked ? 1 : -1;
        if (current < 0) current = 0;
        await _client.from('comments').update({'likes': current}).eq('id', commentId);
      }
      return true;
    } catch (e) {
      debugPrint('CommentService.toggleLike error: $e');
      return false;
    }
  }
}
