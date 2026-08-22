import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../post_model.dart';
import '../services/chat_service.dart';

class MessagesScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<String> onSnack;
  final String? openWithUsername;
  final ValueChanged<bool>? onConversationChanged;

  const MessagesScreen({
    super.key,
    required this.isDark,
    required this.onSnack,
    this.openWithUsername,
    this.onConversationChanged,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  Chat? _active;
  List<ChatMessage> _msgs = [];
  List<Chat> _chats = [];
  bool _loadingChats = true;
  bool _loadingMessages = false;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _loadingChats = true);
    final fetched = await ChatService.fetchChats();
    setState(() {
      _chats = fetched;
      _loadingChats = false;
    });

    final username = widget.openWithUsername;
    if (username != null) {
      final existing = _chats.where((c) => c.user == username);
      final chat = existing.isNotEmpty
          ? existing.first
          : Chat(
              id: username.hashCode,
              user: username,
              avatar: 'photo-1607746882042-944635dfe10e?w=80&h=80&fit=crop',
              lastMsg: 'Say hello 👋',
              time: 'now',
              unread: 0,
              online: true,
            );
      _active = chat;
      _loadMessages(chat.id);
      widget.onConversationChanged?.call(true);
    }
  }

  Future<void> _loadMessages(int chatId) async {
    setState(() => _loadingMessages = true);
    final msgs = await ChatService.fetchMessages(chatId);
    if (mounted) {
      setState(() {
        _msgs = msgs;
        _loadingMessages = false;
      });
    }
  }

  void _openChat(Chat chat) {
    setState(() {
      _active = chat;
      _msgs = [];
    });
    widget.onConversationChanged?.call(true);
    _loadMessages(chat.id);
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _active == null) return;
    
    // Optimistic UI
    setState(() {
      _msgs.add(ChatMessage(id: DateTime.now().millisecondsSinceEpoch, from: 'me', text: text, time: 'now'));
      _input.clear();
    });
    
    // Save to DB
    await ChatService.sendMessage(_active!.id, text);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _active == null ? _buildChatList() : _buildConversation();
  }

  Widget _buildChatList() {
    final isDark = widget.isDark;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;

    if (_loadingChats) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: txt)),
        const SizedBox(height: 16),
        ..._chats.map((chat) => InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openChat(chat),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(radius: 24, backgroundImage: NetworkImage(resolveImageUrl(chat.avatar))),
                        if (chat.online)
                          Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(color: BlinkColors.online, shape: BoxShape.circle, border: Border.all(color: bg, width: 2)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chat.user, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                          Text(chat.lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: muted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(chat.time, style: TextStyle(fontSize: 10, color: muted)),
                        const SizedBox(height: 4),
                        if (chat.unread > 0)
                          Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: BlinkColors.accent, shape: BoxShape.circle),
                            child: Text('${chat.unread}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildConversation() {
    final isDark = widget.isDark;
    final active = _active!;
    final txt = isDark ? BlinkColors.textDark : BlinkColors.textLight;
    final muted = isDark ? BlinkColors.mutedDark : BlinkColors.mutedLight;
    final bg = isDark ? BlinkColors.bgDark : BlinkColors.bgLight;
    final border = isDark ? BlinkColors.borderDark : BlinkColors.borderLight;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _active = null);
                  widget.onConversationChanged?.call(false);
                },
                icon: Icon(Icons.arrow_back_ios_new, size: 18, color: txt),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(resolveImageUrl(active.avatar))),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(active.user, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: txt)),
                  Text(active.online ? '● Online' : 'Offline', style: TextStyle(fontSize: 11, color: active.online ? BlinkColors.online : muted)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingMessages 
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _msgs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final m = _msgs[i];
                  final me = m.from == 'me';
                  return Align(
                    alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: me ? BlinkColors.accent : (isDark ? const Color(0x17FFFFFF) : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(me ? 18 : 4),
                          bottomRight: Radius.circular(me ? 4 : 18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(m.text, style: TextStyle(fontSize: 13, color: me ? Colors.white : txt, height: 1.45)),
                          const SizedBox(height: 4),
                          Text(m.time, style: TextStyle(fontSize: 10, color: me ? Colors.white70 : muted)),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x12FFFFFF) : const Color(0x0F000000),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: TextField(
                    controller: _input,
                    style: TextStyle(color: txt, fontSize: 13),
                    decoration: const InputDecoration(hintText: 'Message...', border: InputBorder.none, isDense: true),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: BlinkColors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.send, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}