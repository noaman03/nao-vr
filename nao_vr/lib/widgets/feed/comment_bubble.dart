import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';

/// Comment Bubble Widget - Chat-like comment display
/// Shows comments in a conversation style with user avatar and timestamp
class CommentBubble extends StatelessWidget {
  final CommentModel comment;
  final bool isMe;

  const CommentBubble({
    super.key,
    required this.comment,
    required this.isMe,
  });

  /// Convert DateTime to time string (e.g., "14:30")
  String _getTimeString(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get relative time (e.g., "2h ago")
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Show avatar for other users (left side)
          if (!isMe) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.5),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.userAvatar),
                backgroundColor: Colors.grey.shade800,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Comment bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Username (only for other users)
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      comment.username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Comment content bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // Different colors for own vs others' comments
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF5548E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMe ? null : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? const Color(0xFF6C63FF).withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Comment text
                      Text(
                        comment.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Timestamp
                      Text(
                        _getTimeAgo(comment.createdAt),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Show avatar for current user (right side)
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.5),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.userAvatar),
                backgroundColor: Colors.grey.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
