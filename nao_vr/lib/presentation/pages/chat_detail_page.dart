import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../widgets/chat/message_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Mock messages
    messages = [
      MessageModel(
        id: 'msg1',
        chatId: widget.chat.id,
        senderId: widget.chat.friendId,
        receiverId: 'currentUser',
        content: 'Hey! How are you doing?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      MessageModel(
        id: 'msg2',
        chatId: widget.chat.id,
        senderId: 'currentUser',
        receiverId: widget.chat.friendId,
        content: 'Good! Just finished a great match',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 55),
        ),
        isRead: true,
      ),
      MessageModel(
        id: 'msg3',
        chatId: widget.chat.id,
        senderId: widget.chat.friendId,
        receiverId: 'currentUser',
        content: 'Nice! Wanna play together?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chat.id,
      senderId: 'currentUser',
      receiverId: widget.chat.friendId,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      messages.add(newMessage);
      _messageController.clear();
    });

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.friendAvatar),
              radius: 18,
            ),
            const SizedBox(width: 12),
            Text(widget.chat.friendName),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == 'currentUser';
                return MessageBubble(message: message, isMe: isMe);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade900,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade400),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
