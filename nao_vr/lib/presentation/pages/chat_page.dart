import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';
import '../../widgets/chat/chat_list_item.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatModel> chats = [];
  List<ChatModel> filteredChats = [];

  @override
  void initState() {
    super.initState();
    _loadMockChats();
    filteredChats = chats;
  }

  void _loadMockChats() {
    chats = [
      ChatModel(
        id: 'chat1',
        friendId: 'friend1',
        friendName: 'ProGamer123',
        friendAvatar: 'https://i.pravatar.cc/150?img=1',
        lastMessage: 'Hey, wanna play some matches?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
      ),
      ChatModel(
        id: 'chat2',
        friendId: 'friend2',
        friendName: 'VRMaster',
        friendAvatar: 'https://i.pravatar.cc/150?img=2',
        lastMessage: 'GG! That was an awesome game',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
      ),
      ChatModel(
        id: 'chat3',
        friendId: 'friend3',
        friendName: 'SnipeKing',
        friendAvatar: 'https://i.pravatar.cc/150?img=3',
        lastMessage: 'Check out my new clip!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 1,
      ),
      ChatModel(
        id: 'chat4',
        friendId: 'friend4',
        friendName: 'RushMaster',
        friendAvatar: 'https://i.pravatar.cc/150?img=4',
        lastMessage: 'Let\'s practice together tomorrow',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];
    filteredChats = chats;
  }

  void _filterChats(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredChats = chats;
      } else {
        filteredChats = chats
            .where(
              (chat) => chat.friendName.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  void _openChat(ChatModel chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailPage(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ).createShader(bounds),
                  child: const Text(
                    'Messages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                  child: Text(
                    '${chats.where((c) => c.unreadCount > 0).length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.group_add_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Add friends coming soon!'),
                          backgroundColor: const Color(0xFF6C63FF),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  if (chats.where((c) => c.unreadCount > 0).length > 0)
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChats,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search friends...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade800),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey.shade800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Expanded(
            child: filteredChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF5548E5)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No chats yet'
                              : 'No friends found',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Start chatting with your friends!'
                              : 'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      return ChatListItem(
                        chat: filteredChats[index],
                        onTap: () => _openChat(filteredChats[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
