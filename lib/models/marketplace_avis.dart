/// Représente un avis dans le système, correspondant à la table `marketplace_avis` dans la base de données.
class MarketplaceAvis {
  final int? id;
  final int? produitId;
  final int? userId;
  final int etoileNb;
  final String commentaire;
  final DateTime createdAt;

  MarketplaceAvis({
    this.id,
    this.produitId,
    this.userId,
    required this.etoileNb,
    required this.commentaire,
    required this.createdAt,
  });

  /// Crée un nouvel avis
  factory MarketplaceAvis.create({
    int? produitId,
    int? userId,
    required int etoileNb,
    required String commentaire,
  }) {
    return MarketplaceAvis(
      produitId: produitId,
      userId: userId,
      etoileNb: etoileNb,
      commentaire: commentaire,
      createdAt: DateTime.now(),
    );
  }

  /// Convertit un avis en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (produitId != null) 'produit_id': produitId,
      if (userId != null) 'user_id': userId,
      'etoile_nb': etoileNb,
      'commentaire': commentaire,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crée un avis à partir d'un Map de SQLite
  factory MarketplaceAvis.fromMap(Map<String, dynamic> map) {
    return MarketplaceAvis(
      id: map['id'],
      produitId: map['produit_id'],
      userId: map['user_id'],
      etoileNb: map['etoile_nb'] ?? 0,
      commentaire: map['commentaire'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  /// Crée une copie de l'avis avec des modifications
  MarketplaceAvis copyWith({
    int? id,
    int? produitId,
    int? userId,
    int? etoileNb,
    String? commentaire,
    DateTime? createdAt,
  }) {
    return MarketplaceAvis(
      id: id ?? this.id,
      produitId: produitId ?? this.produitId,
      userId: userId ?? this.userId,
      etoileNb: etoileNb ?? this.etoileNb,
      commentaire: commentaire ?? this.commentaire,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
