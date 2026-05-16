import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/player_stats_model.dart';
import '../../widgets/profile/stat_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel currentUser;
  late PlayerStatsModel playerStats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Mock user data
    currentUser = UserModel(
      id: 'currentUser',
      username: 'ProPlayer',
      displayName: 'Pro Player',
      avatarUrl: 'https://i.pravatar.cc/150?img=10',
      bio:
          'VR FPS enthusiast | Competitive player | Always looking for new challenges',
      level: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    );

    playerStats = PlayerStatsModel(
      userId: currentUser.id,
      kills: 2850,
      deaths: 1240,
      assists: 980,
      wins: 145,
      losses: 98,
      gamesPlayed: 243,
      kdaRatio: 3.09,
      winRate: 59.67,
      headshots: 1205,
      accuracy: 68.5,
      rank: 'Diamond II',
      rankPoints: 2450,
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
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
              ).createShader(bounds),
              child: const Text(
                'Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Settings coming soon!'),
                      backgroundColor: const Color(0xFF6C63FF),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with modern gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF6C63FF),
                    const Color(0xFF5548E5),
                    const Color(0xFFFF6584).withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with gradient border
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFFF6584)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(currentUser.avatarUrl),
                      backgroundColor: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '@${currentUser.username}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${currentUser.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Rank Section with modern styling
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
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
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                        ).createShader(bounds),
                        child: const Text(
                          'Current Rank',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.military_tech,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playerStats.rank,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${playerStats.rankPoints} RP',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // KDA Section with modern styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
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
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                        ).createShader(bounds),
                        child: const Text(
                          'KDA Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildKDAItem(
                            'Kills',
                            playerStats.kills,
                            Colors.green,
                          ),
                          _buildKDAItem(
                            'Deaths',
                            playerStats.deaths,
                            Colors.red,
                          ),
                          _buildKDAItem(
                            'Assists',
                            playerStats.assists,
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'KDA Ratio',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              playerStats.kdaRatio.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _getKDAColor(playerStats.kdaRatio),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Performance Stats with modern styling
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                    ).createShader(bounds),
                    child: const Text(
                      'Performance Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Win Rate',
                          value: '${playerStats.winRate.toStringAsFixed(1)}%',
                          icon: Icons.emoji_events,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Games',
                          value: playerStats.gamesPlayed.toString(),
                          icon: Icons.gamepad,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Headshots',
                          value: playerStats.headshots.toString(),
                          icon: Icons.track_changes,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Accuracy',
                          value: '${playerStats.accuracy.toStringAsFixed(1)}%',
                          icon: Icons.gps_fixed,
                          color: Colors.teal,
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
    );
  }

  Widget _buildKDAItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Color _getKDAColor(double kda) {
    if (kda >= 3.0) return Colors.green;
    if (kda >= 2.0) return Colors.lightGreen;
    if (kda >= 1.5) return Colors.orange;
    return Colors.red;
  }
}
