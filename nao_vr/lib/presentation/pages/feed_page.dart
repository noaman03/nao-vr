import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../widgets/feed/post_card.dart';
import 'comments_page.dart';

/// Main Feed Page - Displays user posts and gaming content
/// Features: Pull to refresh, create posts, like/comment functionality
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  // Controller for post input text field
  final TextEditingController _postController = TextEditingController();

  // List to store all posts
  List<PostModel> posts = [];

  // Loading state for pull to refresh
  bool _isRefreshing = false;

  // Keep the state alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMockPosts();
  }

  /// Load mock posts data - In production, this would fetch from backend
  void _loadMockPosts() {
    // Mock data for demonstration
    posts = [
      PostModel(
        id: '1',
        userId: 'user1',
        username: 'ProGamer123',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        content: 'Just got my first pentakill! Check out this insane clip! 🔥',
        mediaUrl: 'https://picsum.photos/600/400',
        mediaType: 'image',
        likes: 45,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likedBy: [],
      ),
      PostModel(
        id: '2',
        userId: 'user2',
        username: 'VRMaster',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        content:
            'New personal record: 25 kills in one match! Who wants to squad up? 🎮',
        likes: 32,
        commentsCount: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likedBy: [],
      ),
      PostModel(
        id: '3',
        userId: 'user3',
        username: 'SnipeKing',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        content: 'Updated my KDA to 3.5! Time to rank up 💪',
        mediaUrl: 'https://picsum.photos/600/400?random=2',
        mediaType: 'image',
        likes: 67,
        commentsCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likedBy: [],
      ),
    ];
  }

  /// Create a new post and add it to the feed
  void _createPost() {
    // Validate post content
    if (_postController.text.trim().isEmpty) return;

    // Create new post model
    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'currentUser',
      username: 'You',
      userAvatar: 'https://i.pravatar.cc/150?img=10',
      content: _postController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      posts.insert(0, newPost);
      _postController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post created successfully!')));
  }

  /// Show modern create post dialog with advanced styling
  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header with gradient
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
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
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Text field with modern styling
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _postController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share your epic gaming moments... 🎮',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Action buttons row
              Row(
                children: [
                  // Media buttons
                  IconButton(
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.videocam_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  const Spacer(),
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Post button with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF5548E5)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _createPost();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle post like/unlike action
  void _onLike(PostModel post) {
    setState(() {
      final index = posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        final currentUserId = 'currentUser';
        final isLiked = post.likedBy.contains(currentUserId);

        posts[index] = post.copyWith(
          likes: isLiked ? post.likes - 1 : post.likes + 1,
          likedBy: isLiked
              ? post.likedBy.where((id) => id != currentUserId).toList()
              : [...post.likedBy, currentUserId],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      // Modern app bar with gradient and glassmorphism
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
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
            title: Row(
              children: [
                // App logo with gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ).createShader(bounds),
                  child: const Text(
                    'NAO VR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Gaming badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF5548E5)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            actions: [
              // Notification bell with indicator
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6584),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        // Custom colors for refresh indicator
        color: const Color(0xFF6C63FF),
        backgroundColor: const Color(0xFF1A1A1A),
        onRefresh: () async {
          setState(() => _isRefreshing = true);
          // Simulate network delay
          await Future.delayed(const Duration(milliseconds: 1500));
          setState(() {
            _loadMockPosts();
            _isRefreshing = false;
          });
        },
        // ListView with modern post cards
        child: ListView.builder(
          physics: const BouncingScrollPhysics(), // Smooth scrolling
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            // Animate posts as they appear
            return AnimatedOpacity(
              opacity: _isRefreshing ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: PostCard(
                post: posts[index],
                onLike: () => _onLike(posts[index]),
                onComment: () {
                  // Navigate to comments page with chat-like UI
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(post: posts[index]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      // Modern floating action button with gradient
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF5548E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showCreatePostDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
