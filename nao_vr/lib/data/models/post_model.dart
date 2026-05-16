class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String content;
  final String? mediaUrl;
  final String? mediaType; // 'image', 'video', 'clip'
  final int likes;
  final int commentsCount;
  final DateTime createdAt;
  final List<String> likedBy;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    this.likes = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.likedBy = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userAvatar: json['userAvatar'] as String,
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      likes: json['likes'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likedBy:
          (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
    };
  }

  PostModel copyWith({int? likes, int? commentsCount, List<String>? likedBy}) {
    return PostModel(
      id: id,
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
