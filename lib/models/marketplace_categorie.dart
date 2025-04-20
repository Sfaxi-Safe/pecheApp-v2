/// Représente une catégorie dans le système, correspondant à la table `marketplace_categorie` dans la base de données.
class MarketplaceCategorie {
  final int? id;
  final String nom;
  final String imageUrl;

  MarketplaceCategorie({
    this.id,
    required this.nom,
    required this.imageUrl,
  });

  /// Crée une nouvelle catégorie
  factory MarketplaceCategorie.create({
    required String nom,
    required String imageUrl,
  }) {
    return MarketplaceCategorie(
      nom: nom,
      imageUrl: imageUrl,
    );
  }

  /// Convertit une catégorie en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'image_url': imageUrl,
    };
  }

  /// Crée une catégorie à partir d'un Map de SQLite
  factory MarketplaceCategorie.fromMap(Map<String, dynamic> map) {
    return MarketplaceCategorie(
      id: map['id'],
      nom: map['nom'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }

  /// Crée une copie de la catégorie avec des modifications
  MarketplaceCategorie copyWith({
    int? id,
    String? nom,
    String? imageUrl,
  }) {
    return MarketplaceCategorie(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
