import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blink/features/profile/user_profile_model.dart';
import 'package:blink/services/profile_service.dart';

class FollowService {
  static final _client = Supabase.instance.client;

  static Future<int> fetchFollowerCount(String username) async {
    try {
      // Some supabase client versions don't expose FetchOptions; just fetch
      // the rows and return the length which is portable across versions.
      final rows = await _client.from('follows').select('follower').eq('following', username).limit(1000) as List<dynamic>?;
      return rows?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<int> fetchFollowingCount(String username) async {
    try {
      final rows = await _client.from('follows').select('following').eq('follower', username).limit(1000) as List<dynamic>?;
      return rows?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> follow(String follower, String following) async {
    await _client.from('follows').insert({'follower': follower, 'following': following});
  }

  static Future<void> unfollow(String follower, String following) async {
    await _client.from('follows').delete().match({'follower': follower, 'following': following});
  }

  static Future<List<FollowPreview>> fetchFollowersPreview(String username, {int limit = 50}) async {
    try {
      final rows = await _client.from('follows').select('follower').eq('following', username).limit(limit) as List<dynamic>;
      final usernames = rows.map((r) => (r as Map)['follower'] as String).toList();
      final profiles = await Future.wait(usernames.map((u) => ProfileService.fetchByUsername(u)));
      return profiles.map((p) => FollowPreview(username: p.username, fullName: p.fullName, avatar: p.avatar, verification: p.verification, headline: p.professionalHeadline)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<FollowPreview>> fetchFollowingPreview(String username, {int limit = 50}) async {
    try {
      final rows = await _client.from('follows').select('following').eq('follower', username).limit(limit) as List<dynamic>;
      final usernames = rows.map((r) => (r as Map)['following'] as String).toList();
      final profiles = await Future.wait(usernames.map((u) => ProfileService.fetchByUsername(u)));
      return profiles.map((p) => FollowPreview(username: p.username, fullName: p.fullName, avatar: p.avatar, verification: p.verification, headline: p.professionalHeadline)).toList();
    } catch (_) {
      return [];
    }
  }
}
