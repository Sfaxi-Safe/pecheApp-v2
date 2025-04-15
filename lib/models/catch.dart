import 'package:uuid/uuid.dart';

class Catch {
  final String id;
  final String fishermanId;
  final String? maryeurId;
  final String nom;
  final DateTime debut;
  final DateTime? fin;
  final String latitude;
  final String longitude;
  final String engin;
  final String? zone;
  final DateTime? affectationDate;
  final DateTime? dateDebarquement;

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

  // Créer une nouvelle capture avec un ID généré
  factory Catch.create({
    required String fishermanId,
    String? maryeurId,
    required String nom,
    required DateTime debut,
    DateTime? fin,
    required String latitude,
    required String longitude,
    required String engin,
    String? zone,
    DateTime? affectationDate,
    DateTime? dateDebarquement,
  }) {
    return Catch(
      id: const Uuid().v4(),
      fishermanId: fishermanId,
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

  // Convertir un Catch en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishermanId': fishermanId,
      'maryeurId': maryeurId,
      'nom': nom,
      'debut': debut.toIso8601String(),
      'fin': fin?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'engin': engin,
      'zone': zone,
      'affectationDate': affectationDate?.toIso8601String(),
      'dateDebarquement': dateDebarquement?.toIso8601String(),
    };
  }

  // Créer un Catch à partir d'un Map de SQLite
  factory Catch.fromMap(Map<String, dynamic> map) {
    return Catch(
      id: map['id'],
      fishermanId: map['fishermanId'],
      maryeurId: map['maryeurId'],
      nom: map['nom'],
      debut: DateTime.parse(map['debut']),
      fin: map['fin'] != null ? DateTime.parse(map['fin']) : null,
      latitude: map['latitude'],
      longitude: map['longitude'],
      engin: map['engin'],
      zone: map['zone'],
      affectationDate: map['affectationDate'] != null ? DateTime.parse(map['affectationDate']) : null,
      dateDebarquement: map['dateDebarquement'] != null ? DateTime.parse(map['dateDebarquement']) : null,
    );
  }
}
