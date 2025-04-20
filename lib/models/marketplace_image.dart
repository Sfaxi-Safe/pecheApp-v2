/// Représente une image dans le système, correspondant à la table `marketplace_image` dans la base de données.
class MarketplaceImage {
  final int? id;
  final String url;
  final String? alt;
  final int? produitId;
  final int? priseId;
  final int? publicationId;

  MarketplaceImage({
    this.id,
    required this.url,
    this.alt,
    this.produitId,
    this.priseId,
    this.publicationId,
  });

  /// Crée une nouvelle image
  factory MarketplaceImage.create({
    required String url,
    String? alt,
    int? produitId,
    int? priseId,
    int? publicationId,
  }) {
    return MarketplaceImage(
      url: url,
      alt: alt,
      produitId: produitId,
      priseId: priseId,
      publicationId: publicationId,
    );
  }

  /// Convertit une image en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'url': url,
      if (alt != null) 'alt': alt,
      if (produitId != null) 'produit_id': produitId,
      if (priseId != null) 'prise_id': priseId,
      if (publicationId != null) 'publication_id': publicationId,
    };
  }

  /// Crée une image à partir d'un Map de SQLite
  factory MarketplaceImage.fromMap(Map<String, dynamic> map) {
    return MarketplaceImage(
      id: map['id'],
      url: map['url'] ?? '',
      alt: map['alt'],
      produitId: map['produit_id'],
      priseId: map['prise_id'],
      publicationId: map['publication_id'],
    );
  }

  /// Crée une copie de l'image avec des modifications
  MarketplaceImage copyWith({
    int? id,
    String? url,
    String? alt,
    int? produitId,
    int? priseId,
    int? publicationId,
  }) {
    return MarketplaceImage(
      id: id ?? this.id,
      url: url ?? this.url,
      alt: alt ?? this.alt,
      produitId: produitId ?? this.produitId,
      priseId: priseId ?? this.priseId,
      publicationId: publicationId ?? this.publicationId,
    );
  }
}
