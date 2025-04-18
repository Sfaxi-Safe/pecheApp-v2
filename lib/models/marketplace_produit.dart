/// Représente un produit dans le système, correspondant à la table `marketplace_produit` dans la base de données.
class MarketplaceProduit {
  final int? id;
  final int? categorieId;
  final int? userId;
  final String nom;
  final String description;
  final int stock;
  final double prix;
  final int min;
  final int max;
  final double? discount;
  final int vu;
  final bool visibilite;
  final String? typologie;
  final String? dateDeConsomation;
  final String? dateDePeche;
  final String? methodeDeCapture;
  final String? zoneDePeche;
  final String? transformation;
  final String? conservation;
  final String? congelation;
  final String? glazing;
  final String? taille;
  final String? certification;
  final String? emballage;
  final String? poidEmballage;
  final bool? imported;
  final bool? certifie;

  MarketplaceProduit({
    this.id,
    this.categorieId,
    this.userId,
    required this.nom,
    required this.description,
    required this.stock,
    required this.prix,
    required this.min,
    required this.max,
    this.discount,
    required this.vu,
    required this.visibilite,
    this.typologie,
    this.dateDeConsomation,
    this.dateDePeche,
    this.methodeDeCapture,
    this.zoneDePeche,
    this.transformation,
    this.conservation,
    this.congelation,
    this.glazing,
    this.taille,
    this.certification,
    this.emballage,
    this.poidEmballage,
    this.imported,
    this.certifie,
  });

  /// Crée un nouveau produit
  factory MarketplaceProduit.create({
    int? categorieId,
    int? userId,
    required String nom,
    required String description,
    required int stock,
    required double prix,
    required int min,
    required int max,
    double? discount,
    int vu = 0,
    bool visibilite = true,
    String? typologie,
    String? dateDeConsomation,
    String? dateDePeche,
    String? methodeDeCapture,
    String? zoneDePeche,
    String? transformation,
    String? conservation,
    String? congelation,
    String? glazing,
    String? taille,
    String? certification,
    String? emballage,
    String? poidEmballage,
    bool? imported,
    bool? certifie,
  }) {
    return MarketplaceProduit(
      categorieId: categorieId,
      userId: userId,
      nom: nom,
      description: description,
      stock: stock,
      prix: prix,
      min: min,
      max: max,
      discount: discount,
      vu: vu,
      visibilite: visibilite,
      typologie: typologie,
      dateDeConsomation: dateDeConsomation,
      dateDePeche: dateDePeche,
      methodeDeCapture: methodeDeCapture,
      zoneDePeche: zoneDePeche,
      transformation: transformation,
      conservation: conservation,
      congelation: congelation,
      glazing: glazing,
      taille: taille,
      certification: certification,
      emballage: emballage,
      poidEmballage: poidEmballage,
      imported: imported,
      certifie: certifie,
    );
  }

  /// Convertit un produit en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (categorieId != null) 'categorie_id': categorieId,
      if (userId != null) 'user_id': userId,
      'nom': nom,
      'description': description,
      'stock': stock,
      'prix': prix,
      'min': min,
      'max': max,
      if (discount != null) 'discount': discount,
      'vu': vu,
      'visibilite': visibilite ? 1 : 0,
      if (typologie != null) 'typologie': typologie,
      if (dateDeConsomation != null) 'datedeconsomation': dateDeConsomation,
      if (dateDePeche != null) 'datedepeche': dateDePeche,
      if (methodeDeCapture != null) 'methodedecapture': methodeDeCapture,
      if (zoneDePeche != null) 'zonedepeche': zoneDePeche,
      if (transformation != null) 'transformation': transformation,
      if (conservation != null) 'conservation': conservation,
      if (congelation != null) 'congelation': congelation,
      if (glazing != null) 'glazing': glazing,
      if (taille != null) 'taille': taille,
      if (certification != null) 'certification': certification,
      if (emballage != null) 'emballage': emballage,
      if (poidEmballage != null) 'poidemballage': poidEmballage,
      if (imported != null) 'imported': imported! ? 1 : 0,
      if (certifie != null) 'certifie': certifie! ? 1 : 0,
    };
  }

  /// Crée un produit à partir d'un Map de SQLite
  factory MarketplaceProduit.fromMap(Map<String, dynamic> map) {
    return MarketplaceProduit(
      id: map['id'],
      categorieId: map['categorie_id'],
      userId: map['user_id'],
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      stock: map['stock'] ?? 0,
      prix: map['prix'] is int ? (map['prix'] as int).toDouble() : (map['prix'] ?? 0.0),
      min: map['min'] ?? 0,
      max: map['max'] ?? 0,
      discount: map['discount'] is int ? (map['discount'] as int).toDouble() : map['discount'],
      vu: map['vu'] ?? 0,
      visibilite: map['visibilite'] == 1,
      typologie: map['typologie'],
      dateDeConsomation: map['datedeconsomation'],
      dateDePeche: map['datedepeche'],
      methodeDeCapture: map['methodedecapture'],
      zoneDePeche: map['zonedepeche'],
      transformation: map['transformation'],
      conservation: map['conservation'],
      congelation: map['congelation'],
      glazing: map['glazing'],
      taille: map['taille'],
      certification: map['certification'],
      emballage: map['emballage'],
      poidEmballage: map['poidemballage'],
      imported: map['imported'] == null ? null : map['imported'] == 1,
      certifie: map['certifie'] == null ? null : map['certifie'] == 1,
    );
  }

  /// Crée une copie du produit avec des modifications
  MarketplaceProduit copyWith({
    int? id,
    int? categorieId,
    int? userId,
    String? nom,
    String? description,
    int? stock,
    double? prix,
    int? min,
    int? max,
    double? discount,
    int? vu,
    bool? visibilite,
    String? typologie,
    String? dateDeConsomation,
    String? dateDePeche,
    String? methodeDeCapture,
    String? zoneDePeche,
    String? transformation,
    String? conservation,
    String? congelation,
    String? glazing,
    String? taille,
    String? certification,
    String? emballage,
    String? poidEmballage,
    bool? imported,
    bool? certifie,
  }) {
    return MarketplaceProduit(
      id: id ?? this.id,
      categorieId: categorieId ?? this.categorieId,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      prix: prix ?? this.prix,
      min: min ?? this.min,
      max: max ?? this.max,
      discount: discount ?? this.discount,
      vu: vu ?? this.vu,
      visibilite: visibilite ?? this.visibilite,
      typologie: typologie ?? this.typologie,
      dateDeConsomation: dateDeConsomation ?? this.dateDeConsomation,
      dateDePeche: dateDePeche ?? this.dateDePeche,
      methodeDeCapture: methodeDeCapture ?? this.methodeDeCapture,
      zoneDePeche: zoneDePeche ?? this.zoneDePeche,
      transformation: transformation ?? this.transformation,
      conservation: conservation ?? this.conservation,
      congelation: congelation ?? this.congelation,
      glazing: glazing ?? this.glazing,
      taille: taille ?? this.taille,
      certification: certification ?? this.certification,
      emballage: emballage ?? this.emballage,
      poidEmballage: poidEmballage ?? this.poidEmballage,
      imported: imported ?? this.imported,
      certifie: certifie ?? this.certifie,
    );
  }
}
