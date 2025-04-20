/// Représente un forum dans le système, correspondant à la table `marketplace_forum` dans la base de données.
class MarketplaceForum {
  final int? id;
  final String titre;
  final String description;
  final DateTime dateCreation;
  final int? userId;
  final String? image;

  MarketplaceForum({
    this.id,
    required this.titre,
    required this.description,
    required this.dateCreation,
    this.userId,
    this.image,
  });

  /// Crée un nouveau forum
  factory MarketplaceForum.create({
    required String titre,
    required String description,
    int? userId,
    String? image,
  }) {
    return MarketplaceForum(
      titre: titre,
      description: description,
      dateCreation: DateTime.now(),
      userId: userId,
      image: image,
    );
  }

  /// Convertit un forum en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'description': description,
      'date_creation': dateCreation.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (image != null) 'image': image,
    };
  }

  /// Crée un forum à partir d'un Map de SQLite
  factory MarketplaceForum.fromMap(Map<String, dynamic> map) {
    return MarketplaceForum(
      id: map['id'],
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      dateCreation: map['date_creation'] != null 
          ? DateTime.parse(map['date_creation']) 
          : DateTime.now(),
      userId: map['user_id'],
      image: map['image'],
    );
  }

  /// Crée une copie du forum avec des modifications
  MarketplaceForum copyWith({
    int? id,
    String? titre,
    String? description,
    DateTime? dateCreation,
    int? userId,
    String? image,
  }) {
    return MarketplaceForum(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
      userId: userId ?? this.userId,
      image: image ?? this.image,
    );
  }
}
