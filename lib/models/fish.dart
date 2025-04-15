import 'package:uuid/uuid.dart';

class Fish {
  final String id;
  final String species;
  final String imageUrl;
  final double weight;
  final double length;
  final String location;
  final String fishingMethod;
  final DateTime captureDate;
  final String fishermanId;

  Fish({
    required this.id,
    required this.species,
    required this.imageUrl,
    required this.weight,
    required this.length,
    required this.location,
    required this.fishingMethod,
    required this.captureDate,
    required this.fishermanId,
  });

  // Créer un nouveau poisson avec un ID généré
  factory Fish.create({
    required String species,
    required String imageUrl,
    required double weight,
    required double length,
    required String location,
    required String fishingMethod,
    required DateTime captureDate,
    required String fishermanId,
  }) {
    return Fish(
      id: const Uuid().v4(),
      species: species,
      imageUrl: imageUrl,
      weight: weight,
      length: length,
      location: location,
      fishingMethod: fishingMethod,
      captureDate: captureDate,
      fishermanId: fishermanId,
    );
  }

  // Convertir un Fish en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species': species,
      'imageUrl': imageUrl,
      'weight': weight,
      'length': length,
      'location': location,
      'fishingMethod': fishingMethod,
      'captureDate': captureDate.toIso8601String(),
      'fishermanId': fishermanId,
    };
  }

  // Créer un Fish à partir d'un Map de SQLite
  factory Fish.fromMap(Map<String, dynamic> map) {
    return Fish(
      id: map['id'],
      species: map['species'],
      imageUrl: map['imageUrl'],
      weight: map['weight'] is int ? (map['weight'] as int).toDouble() : map['weight'],
      length: map['length'] is int ? (map['length'] as int).toDouble() : map['length'],
      location: map['location'],
      fishingMethod: map['fishingMethod'],
      captureDate: DateTime.parse(map['captureDate']),
      fishermanId: map['fishermanId'],
    );
  }

  // Créer une copie d'un Fish avec des modifications
  Fish copyWith({
    String? id,
    String? species,
    String? imageUrl,
    double? weight,
    double? length,
    String? location,
    String? fishingMethod,
    DateTime? captureDate,
    String? fishermanId,
  }) {
    return Fish(
      id: id ?? this.id,
      species: species ?? this.species,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      location: location ?? this.location,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      captureDate: captureDate ?? this.captureDate,
      fishermanId: fishermanId ?? this.fishermanId,
    );
  }
}
