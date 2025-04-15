import 'package:uuid/uuid.dart';

class Review {
  final String id;
  final String fishId;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.fishId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Créer un nouvel avis avec un ID généré
  factory Review.create({
    required String fishId,
    required String userId,
    required String userName,
    String? userImageUrl,
    required double rating,
    required String comment,
  }) {
    return Review(
      id: const Uuid().v4(),
      fishId: fishId,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  // Convertir un Review en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishId': fishId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Créer un Review à partir d'un Map de SQLite
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      fishId: map['fishId'],
      userId: map['userId'],
      userName: map['userName'],
      userImageUrl: map['userImageUrl'],
      rating: map['rating'] is int ? (map['rating'] as int).toDouble() : map['rating'],
      comment: map['comment'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
