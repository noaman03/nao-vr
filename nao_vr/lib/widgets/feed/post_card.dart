import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';

/// Modern Post Card Widget with glassmorphism and animations
/// Displays user posts with like, comment, and share functionality
class PostCard extends StatefulWidget {
  // Post data model
  final PostModel post;
  // Callback when like button is pressed
  final VoidCallback onLike;
  // Callback when comment button is pressed
  final VoidCallback onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  // Animation controller for like animation
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize like animation
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  /// Handle like button press with animation
  void _handleLike() {
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    widget.onLike();
  }

  /// Convert DateTime to relative time string (e.g., "2h ago")
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
    final isLiked = widget.post.likedBy.contains('currentUser');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Glassmorphism effect
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF1A1A1A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header with modern styling
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User avatar with gradient border
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
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(widget.post.userAvatar),
                    backgroundColor: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                // User info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username with verified badge
                      Row(
                        children: [
                          Text(
                            widget.post.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Verified badge
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C63FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Time ago with icon
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgo(widget.post.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More options button
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
                  onPressed: () {},
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          // Post Content with better typography
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Media section with modern design
          if (widget.post.mediaUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.network(
                    widget.post.mediaUrl!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    // Loading placeholder
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 250,
                        color: Colors.black,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      );
                    },
                    // Error placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey.shade900,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 50,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image unavailable',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // Stats row (likes and comments count)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Likes count with icon
                Icon(
                  Icons.favorite,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.likes}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 16),
                // Comments count with icon
                Icon(
                  Icons.comment,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.commentsCount}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              color: Colors.white.withOpacity(0.1),
              height: 1,
            ),
          ),

          // Action Buttons with modern styling and animations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Like button with animation
                Expanded(
                  child: ScaleTransition(
                    scale: _likeAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleLike,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? const Color(0xFFFF6584)
                                    : Colors.grey.shade400,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Like',
                                style: TextStyle(
                                  color: isLiked
                                      ? const Color(0xFFFF6584)
                                      : Colors.grey.shade400,
                                  fontWeight: isLiked
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Vertical divider
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                ),

                // Comment button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onComment,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              color: Colors.grey.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Comment',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Vertical divider
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.white.withOpacity(0.1),
                ),

                // Share button
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: Colors.grey.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Share',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
