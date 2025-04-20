/// Représente un produit vendu dans le système, correspondant à la table `marketplace_produitvendus` dans la base de données.
class MarketplaceProduitVendus {
  final int? id;
  final int? produitId;
  final int? commandeId;
  final int quantite;
  final double prix;
  final double total;

  MarketplaceProduitVendus({
    this.id,
    this.produitId,
    this.commandeId,
    required this.quantite,
    required this.prix,
    required this.total,
  });

  /// Crée un nouveau produit vendu
  factory MarketplaceProduitVendus.create({
    int? produitId,
    int? commandeId,
    required int quantite,
    required double prix,
  }) {
    return MarketplaceProduitVendus(
      produitId: produitId,
      commandeId: commandeId,
      quantite: quantite,
      prix: prix,
      total: prix * quantite,
    );
  }

  /// Convertit un produit vendu en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (produitId != null) 'produit_id': produitId,
      if (commandeId != null) 'commande_id': commandeId,
      'quantite': quantite,
      'prix': prix,
      'total': total,
    };
  }

  /// Crée un produit vendu à partir d'un Map de SQLite
  factory MarketplaceProduitVendus.fromMap(Map<String, dynamic> map) {
    return MarketplaceProduitVendus(
      id: map['id'],
      produitId: map['produit_id'],
      commandeId: map['commande_id'],
      quantite: map['quantite'] ?? 0,
      prix: map['prix'] ?? 0.0,
      total: map['total'] ?? 0.0,
    );
  }

  /// Crée une copie du produit vendu avec des modifications
  MarketplaceProduitVendus copyWith({
    int? id,
    int? produitId,
    int? commandeId,
    int? quantite,
    double? prix,
    double? total,
  }) {
    return MarketplaceProduitVendus(
      id: id ?? this.id,
      produitId: produitId ?? this.produitId,
      commandeId: commandeId ?? this.commandeId,
      quantite: quantite ?? this.quantite,
      prix: prix ?? this.prix,
      total: total ?? (prix != null || quantite != null 
          ? (prix ?? this.prix) * (quantite ?? this.quantite) 
          : this.total),
    );
  }

  /// Met à jour la quantité et recalcule le total
  MarketplaceProduitVendus updateQuantite(int newQuantite) {
    return copyWith(
      quantite: newQuantite,
      total: prix * newQuantite,
    );
  }
}
