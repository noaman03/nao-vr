class ChatModel {
  final String id;
  final String friendId;
  final String friendName;
  final String friendAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.friendAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      friendId: json['friendId'] as String,
      friendName: json['friendName'] as String,
      friendAvatar: json['friendAvatar'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: DateTime.parse(json['lastMessageTime'] as String),
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatar': friendAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
