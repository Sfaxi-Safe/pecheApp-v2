/// Représente une prise de pêche dans le système, correspondant à la table `marketplace_prise` dans la base de données.
class MarketplacePrise {
  final int? id;
  final int? pecheurId;
  final int? maryeurId;
  final String nom;
  final String debut;
  final String? fin;
  final String latitude;
  final String longitude;
  final String engin;
  final String? zone;
  final String? affectationDate;
  final String? dateDebarquement;

  MarketplacePrise({
    this.id,
    this.pecheurId,
    this.maryeurId,
    required this.nom,
    required this.debut,
    this.fin,
    required this.latitude,
    required this.longitude,
    required this.engin,
    this.zone,
    this.affectationDate,
    this.dateDebarquement,
  });

  /// Crée une nouvelle prise
  factory MarketplacePrise.create({
    int? pecheurId,
    int? maryeurId,
    required String nom,
    required String debut,
    String? fin,
    required String latitude,
    required String longitude,
    required String engin,
    String? zone,
    String? affectationDate,
    String? dateDebarquement,
  }) {
    return MarketplacePrise(
      pecheurId: pecheurId,
      maryeurId: maryeurId,
      nom: nom,
      debut: debut,
      fin: fin,
      latitude: latitude,
      longitude: longitude,
      engin: engin,
      zone: zone,
      affectationDate: affectationDate,
      dateDebarquement: dateDebarquement,
    );
  }

  /// Convertit une prise en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (pecheurId != null) 'pecheur_id': pecheurId,
      if (maryeurId != null) 'maryeur_id': maryeurId,
      'nom': nom,
      'debut': debut,
      if (fin != null) 'fin': fin,
      'latitude': latitude,
      'langitude': longitude, // Note: la colonne s'appelle 'langitude' dans la base de données
      'engin': engin,
      if (zone != null) 'zone': zone,
      if (affectationDate != null) 'affectationdate': affectationDate,
      if (dateDebarquement != null) 'datedebarquement': dateDebarquement,
    };
  }

  /// Crée une prise à partir d'un Map de SQLite
  factory MarketplacePrise.fromMap(Map<String, dynamic> map) {
    return MarketplacePrise(
      id: map['id'],
      pecheurId: map['pecheur_id'],
      maryeurId: map['maryeur_id'],
      nom: map['nom'] ?? '',
      debut: map['debut'] ?? '',
      fin: map['fin'],
      latitude: map['latitude'] ?? '0',
      longitude: map['langitude'] ?? '0', // Note: la colonne s'appelle 'langitude' dans la base de données
      engin: map['engin'] ?? '',
      zone: map['zone'],
      affectationDate: map['affectationdate'],
      dateDebarquement: map['datedebarquement'],
    );
  }

  /// Crée une copie de la prise avec des modifications
  MarketplacePrise copyWith({
    int? id,
    int? pecheurId,
    int? maryeurId,
    String? nom,
    String? debut,
    String? fin,
    String? latitude,
    String? longitude,
    String? engin,
    String? zone,
    String? affectationDate,
    String? dateDebarquement,
  }) {
    return MarketplacePrise(
      id: id ?? this.id,
      pecheurId: pecheurId ?? this.pecheurId,
      maryeurId: maryeurId ?? this.maryeurId,
      nom: nom ?? this.nom,
      debut: debut ?? this.debut,
      fin: fin ?? this.fin,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      engin: engin ?? this.engin,
      zone: zone ?? this.zone,
      affectationDate: affectationDate ?? this.affectationDate,
      dateDebarquement: dateDebarquement ?? this.dateDebarquement,
    );
  }
}
