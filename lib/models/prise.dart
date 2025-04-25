class Prise {
  final String? id; // Changé de int? à String? pour Firebase
  final String? pecheurId; // Changé de int? à String? pour Firebase
  final String? maryeurId; // Changé de int? à String? pour Firebase
  final String? nom;
  final String? debut;
  final String? fin;
  final String? latitude;
  final String? longitude; // Corrigé l'orthographe de "langitude"
  final String? engin;
  final String? zone;
  final String? affectationdate;
  final String? datedebarquement;
  final String? createdAt;

  Prise({
    this.id,
    this.pecheurId,
    this.maryeurId,
    this.nom,
    this.debut,
    this.fin,
    this.latitude,
    this.longitude,
    this.engin,
    this.zone,
    this.affectationdate,
    this.datedebarquement,
    this.createdAt,
  });

  factory Prise.fromMap(Map<String, dynamic> map) {
    return Prise(
      id: map['id'],
      pecheurId: map['pecheur_id'],
      maryeurId: map['maryeur_id'],
      nom: map['nom'],
      debut: map['debut'],
      fin: map['fin'],
      latitude: map['latitude'],
      longitude: map['longitude'] ?? map['langitude'], // Support des deux orthographes
      engin: map['engin'],
      zone: map['zone'],
      affectationdate: map['affectationdate'],
      datedebarquement: map['datedebarquement'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pecheur_id': pecheurId,
      'maryeur_id': maryeurId,
      'nom': nom,
      'debut': debut,
      'fin': fin,
      'latitude': latitude,
      'longitude': longitude,
      'engin': engin,
      'zone': zone,
      'affectationdate': affectationdate,
      'datedebarquement': datedebarquement,
      'createdAt': createdAt,
    };
  }
}
