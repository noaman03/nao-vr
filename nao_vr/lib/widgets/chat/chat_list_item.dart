import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatListItem({super.key, required this.chat, required this.onTap});

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(chat.friendAvatar),
            radius: 28,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.friendName,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            _getTimeAgo(chat.lastMessageTime),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight:
                    chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                color: chat.unreadCount > 0
                    ? Colors.white70
                    : Colors.grey.shade500,
              ),
            ),
          ),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
