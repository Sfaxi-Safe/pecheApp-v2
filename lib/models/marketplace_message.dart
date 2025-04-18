/// Représente un message dans le système, correspondant à la table `marketplace_message` dans la base de données.
class MarketplaceMessage {
  final int? id;
  final int? senderId;
  final int? receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  MarketplaceMessage({
    this.id,
    this.senderId,
    this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
  });

  /// Crée un nouveau message
  factory MarketplaceMessage.create({
    int? senderId,
    int? receiverId,
    required String content,
    String? imageUrl,
  }) {
    return MarketplaceMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      imageUrl: imageUrl,
    );
  }

  /// Convertit un message en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (senderId != null) 'sender_id': senderId,
      if (receiverId != null) 'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead ? 1 : 0,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// Crée un message à partir d'un Map de SQLite
  factory MarketplaceMessage.fromMap(Map<String, dynamic> map) {
    return MarketplaceMessage(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isRead: map['is_read'] == 1,
      imageUrl: map['image_url'],
    );
  }

  /// Crée une copie du message avec des modifications
  MarketplaceMessage copyWith({
    int? id,
    int? senderId,
    int? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return MarketplaceMessage(
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
