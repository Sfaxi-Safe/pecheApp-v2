class Prise {
  final int? id;
  final int? pecheurId;
  final int? maryeurId;
  final String? nom;
  final String? debut;
  final String? fin;
  final String? latitude;
  final String? langitude;
  final String? engin;
  final String? zone;
  final String? affectationdate;
  final String? datedebarquement;

  Prise({
    this.id,
    this.pecheurId,
    this.maryeurId,
    this.nom,
    this.debut,
    this.fin,
    this.latitude,
    this.langitude,
    this.engin,
    this.zone,
    this.affectationdate,
    this.datedebarquement,
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
      langitude: map['langitude'],
      engin: map['engin'],
      zone: map['zone'],
      affectationdate: map['affectationdate'],
      datedebarquement: map['datedebarquement'],
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
      'langitude': langitude,
      'engin': engin,
      'zone': zone,
      'affectationdate': affectationdate,
      'datedebarquement': datedebarquement,
    };
  }
}
