/// Représente un équipement dans le système, correspondant à la table `marketplace_equipement` dans la base de données.
class MarketplaceEquipement {
  final int? id;
  final String nom;
  final String description;
  final String? image;
  final int? pecheurId;

  MarketplaceEquipement({
    this.id,
    required this.nom,
    required this.description,
    this.image,
    this.pecheurId,
  });

  /// Crée un nouvel équipement
  factory MarketplaceEquipement.create({
    required String nom,
    required String description,
    String? image,
    int? pecheurId,
  }) {
    return MarketplaceEquipement(
      nom: nom,
      description: description,
      image: image,
      pecheurId: pecheurId,
    );
  }

  /// Convertit un équipement en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'description': description,
      if (image != null) 'image': image,
      if (pecheurId != null) 'pecheur_id': pecheurId,
    };
  }

  /// Crée un équipement à partir d'un Map de SQLite
  factory MarketplaceEquipement.fromMap(Map<String, dynamic> map) {
    return MarketplaceEquipement(
      id: map['id'],
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      image: map['image'],
      pecheurId: map['pecheur_id'],
    );
  }

  /// Crée une copie de l'équipement avec des modifications
  MarketplaceEquipement copyWith({
    int? id,
    String? nom,
    String? description,
    String? image,
    int? pecheurId,
  }) {
    return MarketplaceEquipement(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      image: image ?? this.image,
      pecheurId: pecheurId ?? this.pecheurId,
    );
  }
}
