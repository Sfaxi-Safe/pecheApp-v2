/// Représente une publication dans le système, correspondant à la table `marketplace_publication` dans la base de données.
class MarketplacePublication {
  final int? id;
  final String titre;
  final String contenu;
  final DateTime datePublication;
  final int? userId;
  final String? image;

  MarketplacePublication({
    this.id,
    required this.titre,
    required this.contenu,
    required this.datePublication,
    this.userId,
    this.image,
  });

  /// Crée une nouvelle publication
  factory MarketplacePublication.create({
    required String titre,
    required String contenu,
    int? userId,
    String? image,
  }) {
    return MarketplacePublication(
      titre: titre,
      contenu: contenu,
      datePublication: DateTime.now(),
      userId: userId,
      image: image,
    );
  }

  /// Convertit une publication en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'contenu': contenu,
      'date_publication': datePublication.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (image != null) 'image': image,
    };
  }

  /// Crée une publication à partir d'un Map de SQLite
  factory MarketplacePublication.fromMap(Map<String, dynamic> map) {
    return MarketplacePublication(
      id: map['id'],
      titre: map['titre'] ?? '',
      contenu: map['contenu'] ?? '',
      datePublication: map['date_publication'] != null 
          ? DateTime.parse(map['date_publication']) 
          : DateTime.now(),
      userId: map['user_id'],
      image: map['image'],
    );
  }

  /// Crée une copie de la publication avec des modifications
  MarketplacePublication copyWith({
    int? id,
    String? titre,
    String? contenu,
    DateTime? datePublication,
    int? userId,
    String? image,
  }) {
    return MarketplacePublication(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      datePublication: datePublication ?? this.datePublication,
      userId: userId ?? this.userId,
      image: image ?? this.image,
    );
  }
}
