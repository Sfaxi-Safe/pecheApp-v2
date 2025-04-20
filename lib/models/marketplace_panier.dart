/// Représente un panier dans le système, correspondant à la table `marketplace_panier` dans la base de données.
class MarketplacePanier {
  final int? id;
  final int? userId;
  final int? produitId;
  final int quantite;
  final DateTime dateAjout;

  MarketplacePanier({
    this.id,
    this.userId,
    this.produitId,
    required this.quantite,
    required this.dateAjout,
  });

  /// Crée un nouveau panier
  factory MarketplacePanier.create({
    int? userId,
    int? produitId,
    required int quantite,
  }) {
    return MarketplacePanier(
      userId: userId,
      produitId: produitId,
      quantite: quantite,
      dateAjout: DateTime.now(),
    );
  }

  /// Convertit un panier en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (produitId != null) 'produit_id': produitId,
      'quantite': quantite,
      'date_ajout': dateAjout.toIso8601String(),
    };
  }

  /// Crée un panier à partir d'un Map de SQLite
  factory MarketplacePanier.fromMap(Map<String, dynamic> map) {
    return MarketplacePanier(
      id: map['id'],
      userId: map['user_id'],
      produitId: map['produit_id'],
      quantite: map['quantite'] ?? 0,
      dateAjout: map['date_ajout'] != null 
          ? DateTime.parse(map['date_ajout']) 
          : DateTime.now(),
    );
  }

  /// Crée une copie du panier avec des modifications
  MarketplacePanier copyWith({
    int? id,
    int? userId,
    int? produitId,
    int? quantite,
    DateTime? dateAjout,
  }) {
    return MarketplacePanier(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      produitId: produitId ?? this.produitId,
      quantite: quantite ?? this.quantite,
      dateAjout: dateAjout ?? this.dateAjout,
    );
  }

  /// Met à jour la quantité
  MarketplacePanier updateQuantite(int newQuantite) {
    return copyWith(quantite: newQuantite);
  }
}
