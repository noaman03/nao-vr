class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final int level;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.bio = '',
    this.level = 1,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
