/// Représente un panier dans le système, correspondant à la table `marketplace_panier` dans la base de données.
class MarketplacePanier {
  final int? id;
  final int? produitId;
  final int? userId;
  final int quantite;
  final DateTime createdAt;

  MarketplacePanier({
    this.id,
    this.produitId,
    this.userId,
    required this.quantite,
    required this.createdAt,
  });

  /// Crée un nouveau panier
  factory MarketplacePanier.create({
    int? produitId,
    int? userId,
    required int quantite,
  }) {
    return MarketplacePanier(
      produitId: produitId,
      userId: userId,
      quantite: quantite,
      createdAt: DateTime.now(),
    );
  }

  /// Convertit un panier en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (produitId != null) 'produit_id': produitId,
      if (userId != null) 'user_id': userId,
      'quantite': quantite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crée un panier à partir d'un Map de SQLite
  factory MarketplacePanier.fromMap(Map<String, dynamic> map) {
    return MarketplacePanier(
      id: map['id'],
      produitId: map['produit_id'],
      userId: map['user_id'],
      quantite: map['quantite'] ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  /// Crée une copie du panier avec des modifications
  MarketplacePanier copyWith({
    int? id,
    int? produitId,
    int? userId,
    int? quantite,
    DateTime? createdAt,
  }) {
    return MarketplacePanier(
      id: id ?? this.id,
      produitId: produitId ?? this.produitId,
      userId: userId ?? this.userId,
      quantite: quantite ?? this.quantite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
