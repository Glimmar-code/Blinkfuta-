import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../post_model.dart';

class ChatService {
  static final _client = Supabase.instance.client;

  static Future<List<Chat>> fetchChats() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return chats; // Fallback to mock

      // Try fetching from a hypothetical 'chats' table
      final resp = await _client.from('chats').select().order('updated_at', ascending: false).limit(20) as List<dynamic>;
      // If it succeeds, map it
      return resp.map((r) {
        return Chat(
          id: r['id'] ?? 0,
          user: r['other_user'] ?? 'Unknown',
          avatar: r['avatar'] ?? 'photo-1529139574466-a303027c1d8b?w=80&h=80&fit=crop',
          lastMsg: r['last_msg'] ?? '',
          time: r['updated_at'] ?? 'now',
          unread: r['unread'] ?? 0,
          online: false,
        );
      }).toList();
    } catch (e) {
      debugPrint('ChatService.fetchChats error: $e');
      return chats; // Fallback to mock
    }
  }

  static Future<List<ChatMessage>> fetchMessages(int chatId) async {
    try {
      // Try fetching from a hypothetical 'messages' table
      final resp = await _client.from('messages').select().eq('chat_id', chatId).order('created_at', ascending: true) as List<dynamic>;
      return resp.map((r) {
        return ChatMessage(
          id: r['id'] ?? 0,
          from: r['sender_id'] == _client.auth.currentUser?.id ? 'me' : 'them',
          text: r['text'] ?? '',
          time: r['created_at'] ?? 'now',
        );
      }).toList();
    } catch (e) {
      debugPrint('ChatService.fetchMessages error: $e');
      // Find the chat for fallback
      final chat = chats.firstWhere((c) => c.id == chatId, orElse: () => chats.first);
      return mockThreadFor(chat);
    }
  }

  static Future<bool> sendMessage(int chatId, String text) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': user.id,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('ChatService.sendMessage error: $e');
      return false; // Fallback will just show it locally via state
    }
  }
}
