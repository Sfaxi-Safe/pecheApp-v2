class Catch {
  final String id;
  final String fishermanId;
  final String? maryeurId;
  final String nom;
  final String debut;
  final String? fin;
  final String latitude;
  final String longitude;
  final String engin;
  final String? zone;
  final String? affectationDate;
  final String? dateDebarquement;

  Catch({
    required this.id,
    required this.fishermanId,
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

  // Convertir un objet Catch en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishermanId': fishermanId,
      'maryeurId': maryeurId,
      'nom': nom,
      'debut': debut,
      'fin': fin,
      'latitude': latitude,
      'longitude': longitude,
      'engin': engin,
      'zone': zone,
      'affectationDate': affectationDate,
      'dateDebarquement': dateDebarquement,
    };
  }

  // Créer un objet Catch à partir d'un Map
  factory Catch.fromMap(Map<String, dynamic> map) {
    return Catch(
      id: map['id']?.toString() ?? '',
      fishermanId: map['pecheur_id']?.toString() ?? '',
      maryeurId: map['maryeur_id']?.toString(),
      nom: map['nom'] ?? '',
      debut: map['debut'] ?? '',
      fin: map['fin'],
      latitude: map['latitude'] ?? '',
      longitude: map['langitude'] ?? '',
      engin: map['engin'] ?? '',
      zone: map['zone'],
      affectationDate: map['affectationdate'],
      dateDebarquement: map['datedebarquement'],
    );
  }
}
