import 'package:flutter/material.dart';
import 'presentation/pages/feed_page.dart';
import 'presentation/pages/chat_page.dart';
import 'presentation/pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAO VR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5548E5), // Darker purple
          secondary: const Color(0xFF6C63FF),
          surface: Colors.black,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Colors.grey,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  // Current selected page index
  int _currentIndex = 0;

  // Page controller for smooth page transitions
  late PageController _pageController;

  // Animation controller for navigation bar animations
  late AnimationController _animationController;

  // List of pages in the app
  final List<Widget> _pages = [
    const FeedPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize page controller
    _pageController = PageController(initialPage: _currentIndex);
    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Handle navigation item tap with smooth page transition
  void _onNavigationTap(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use PageView for smooth swipeable navigation
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      // Modern bottom navigation bar with glassmorphism effect
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Subtle border on top for depth
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          // Gradient background for modern look
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.95),
              Colors.black,
            ],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigationTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6C63FF),
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
