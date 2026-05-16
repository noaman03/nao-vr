// ===== Save as: lib/data/models/user_model.dart =====
class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;
  final String? status;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'status': status,
    };
  }
}

// ===== Save as: lib/data/models/post_model.dart =====
class PostModel {
  final String id;
  final UserModel user;
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  final int likes;
  final int commentsCount;
  final List<CommentModel> comments;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.user,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    this.likes = 0,
    this.commentsCount = 0,
    this.comments = const [],
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      content: json['content'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      comments:
          (json['comments'] as List?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
      isLiked: json['isLiked'] ?? false,
    );
  }
}

class CommentModel {
  final String id;
  final UserModel user;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// ===== Save as: lib/data/models/message_model.dart =====
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ChatRoomModel {
  final String id;
  final UserModel otherUser;
  final MessageModel? lastMessage;
  final int unreadCount;

  ChatRoomModel({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
  });
}

// ===== Save as: lib/data/models/player_stats_model.dart =====
class PlayerStatsModel {
  final String userId;
  final int level;
  final String rank;
  final double kdaRatio;
  final int totalKills;
  final int totalDeaths;
  final int totalAssists;
  final int totalMatches;
  final int wins;
  final int losses;
  final double winRate;
  final String? mostPlayedHero;
  final List<MatchModel> recentMatches;

  PlayerStatsModel({
    required this.userId,
    required this.level,
    required this.rank,
    required this.kdaRatio,
    required this.totalKills,
    required this.totalDeaths,
    required this.totalAssists,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.winRate,
    this.mostPlayedHero,
    this.recentMatches = const [],
  });

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      userId: json['userId'],
      level: json['level'],
      rank: json['rank'],
      kdaRatio: json['kdaRatio'].toDouble(),
      totalKills: json['totalKills'],
      totalDeaths: json['totalDeaths'],
      totalAssists: json['totalAssists'],
      totalMatches: json['totalMatches'],
      wins: json['wins'],
      losses: json['losses'],
      winRate: json['winRate'].toDouble(),
      mostPlayedHero: json['mostPlayedHero'],
      recentMatches:
          (json['recentMatches'] as List?)
              ?.map((m) => MatchModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class MatchModel {
  final String id;
  final String heroName;
  final bool isVictory;
  final int kills;
  final int deaths;
  final int assists;
  final DateTime playedAt;
  final String duration;

  MatchModel({
    required this.id,
    required this.heroName,
    required this.isVictory,
    required this.kills,
    required this.deaths,
    required this.assists,
    required this.playedAt,
    required this.duration,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      heroName: json['heroName'],
      isVictory: json['isVictory'],
      kills: json['kills'],
      deaths: json['deaths'],
      assists: json['assists'],
      playedAt: DateTime.parse(json['playedAt']),
      duration: json['duration'],
    );
  }

  double get kda {
    return deaths == 0
        ? (kills + assists).toDouble()
        : (kills + assists) / deaths;
  }
}
