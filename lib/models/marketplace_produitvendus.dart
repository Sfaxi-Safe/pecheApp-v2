/// Représente un produit vendu dans une commande, correspondant à la table `marketplace_produitvendus` dans la base de données.
class MarketplaceProduitVendus {
  final int? id;
  final int? commandeId;
  final int? produitId;
  final String nom;
  final int quantite;
  final double prix;
  final double totale;

  MarketplaceProduitVendus({
    this.id,
    this.commandeId,
    this.produitId,
    required this.nom,
    required this.quantite,
    required this.prix,
    required this.totale,
  });

  /// Crée un nouveau produit vendu
  factory MarketplaceProduitVendus.create({
    int? commandeId,
    int? produitId,
    required String nom,
    required int quantite,
    required double prix,
  }) {
    return MarketplaceProduitVendus(
      commandeId: commandeId,
      produitId: produitId,
      nom: nom,
      quantite: quantite,
      prix: prix,
      totale: prix * quantite,
    );
  }

  /// Convertit un produit vendu en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'commande_id': commandeId,
      'produit_id': produitId,
      'nom': nom,
      'quantite': quantite,
      'prix': prix,
      'totale': totale,
    };
  }

  /// Crée un produit vendu à partir d'un Map de SQLite
  factory MarketplaceProduitVendus.fromMap(Map<String, dynamic> map) {
    return MarketplaceProduitVendus(
      id: map['id'],
      commandeId: map['commande_id'],
      produitId: map['produit_id'],
      nom: map['nom'],
      quantite: map['quantite'],
      prix: map['prix'] is int ? (map['prix'] as int).toDouble() : map['prix'],
      totale: map['totale'] is int ? (map['totale'] as int).toDouble() : map['totale'],
    );
  }

  /// Crée une copie du produit vendu avec des modifications
  MarketplaceProduitVendus copyWith({
    int? id,
    int? commandeId,
    int? produitId,
    String? nom,
    int? quantite,
    double? prix,
    double? totale,
  }) {
    return MarketplaceProduitVendus(
      id: id ?? this.id,
      commandeId: commandeId ?? this.commandeId,
      produitId: produitId ?? this.produitId,
      nom: nom ?? this.nom,
      quantite: quantite ?? this.quantite,
      prix: prix ?? this.prix,
      totale: totale ?? this.totale,
    );
  }
}
