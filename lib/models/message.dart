import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
  });

  // Créer un nouveau message avec un ID généré
  factory Message.create({
    required String senderId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) {
    return Message(
      id: const Uuid().v4(),
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      imageUrl: imageUrl,
    );
  }

  // Convertir un Message en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'imageUrl': imageUrl,
    };
  }

  // Créer un Message à partir d'un Map de SQLite
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] == 1,
      imageUrl: map['imageUrl'],
    );
  }

  // Créer une copie d'un Message avec des modifications
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime lastMessageTime;
  final String? lastMessageContent;
  final bool hasUnreadMessages;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessageTime,
    this.lastMessageContent,
    required this.hasUnreadMessages,
  });

  // Convertir une Conversation en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessageContent': lastMessageContent,
      'hasUnreadMessages': hasUnreadMessages ? 1 : 0,
    };
  }

  // Créer une Conversation à partir d'un Map de SQLite
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      user1Id: map['user1Id'],
      user2Id: map['user2Id'],
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
      lastMessageContent: map['lastMessageContent'],
      hasUnreadMessages: map['hasUnreadMessages'] == 1,
    );
  }

  // Créer une copie d'une Conversation avec des modifications
  Conversation copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? lastMessageTime,
    String? lastMessageContent,
    bool? hasUnreadMessages,
  }) {
    return Conversation(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }
}
