import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import '../../widgets/feed/comment_bubble.dart';

/// Comments Page - Chat-like UI for post comments
/// Displays comments in a conversation style similar to chat interface
class CommentsPage extends StatefulWidget {
  final PostModel post;

  const CommentsPage({super.key, required this.post});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage>
    with SingleTickerProviderStateMixin {
  // Controller for comment input text field
  final TextEditingController _commentController = TextEditingController();
  // Scroll controller for auto-scrolling to new comments
  final ScrollController _scrollController = ScrollController();
  // Animation controller for send button
  late AnimationController _animationController;

  // List to store all comments
  List<CommentModel> comments = [];
  // Track if user is typing
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMockComments();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Listen to text changes for typing indicator
    _commentController.addListener(() {
      setState(() {
        _isTyping = _commentController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Load mock comments - In production, fetch from backend
  void _loadMockComments() {
    comments = [
      CommentModel(
        id: 'c1',
        postId: widget.post.id,
        userId: 'user2',
        username: 'VRMaster',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        content: 'Amazing play! How did you get that last kill?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CommentModel(
        id: 'c2',
        postId: widget.post.id,
        userId: 'currentUser',
        username: 'You',
        userAvatar: 'https://i.pravatar.cc/150?img=10',
        content: 'Thanks! I flanked from the right side 😎',
        createdAt: DateTime.now().subtract(const Duration(minutes: 55)),
      ),
      CommentModel(
        id: 'c3',
        postId: widget.post.id,
        userId: 'user3',
        username: 'SnipeKing',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        content: 'Insane headshot accuracy! 🎯',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      CommentModel(
        id: 'c4',
        postId: widget.post.id,
        userId: 'user4',
        username: 'ProGamer123',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        content: 'Let\'s squad up later!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  /// Add new comment to the list
  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: 'currentUser',
      username: 'You',
      userAvatar: 'https://i.pravatar.cc/150?img=10',
      content: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      comments.add(newComment);
      _commentController.clear();
    });

    // Animate send button
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern app bar with post info
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                const Color(0xFF5548E5).withOpacity(0.1),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                // Post author avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(widget.post.userAvatar),
                    backgroundColor: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                // Post info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.comment_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comments.length} comments',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Post preview section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent bar
                Container(
                  width: 3,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Post content preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.content,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
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
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comments list - Chat-like interface
          Expanded(
            child: comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final isMe = comment.userId == 'currentUser';
                      return CommentBubble(
                        comment: comment,
                        isMe: isMe,
                      );
                    },
                  ),
          ),

          // Comment input section - Chat-like
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Emoji button
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: () {},
                  ),
                  // Text input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isTyping
                              ? const Color(0xFF6C63FF).withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button with animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.8).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isTyping
                            ? const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF5548E5)],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade700,
                                ],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: _isTyping
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF6C63FF).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded),
                        color: Colors.white,
                        onPressed: _isTyping ? _sendComment : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
