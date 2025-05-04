import 'package:seatrace/models/prise.dart';

/// DTO (Data Transfer Object) pour la prise
/// Utilisé pour standardiser les échanges de données entre le frontend et le backend
class PriseDto {
  final String id;
  final String pecheurId;
  final String maryeurId;
  final String? veterinaireId;
  final String date;
  final String lieu;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? photo;
  final bool isValid;

  PriseDto({
    required this.id,
    required this.pecheurId,
    required this.maryeurId,
    this.veterinaireId,
    required this.date,
    required this.lieu,
    this.latitude,
    this.longitude,
    this.description,
    this.photo,
    this.isValid = false,
  });

  /// Crée un PriseDto à partir d'un Map (JSON)
  factory PriseDto.fromJson(Map<String, dynamic> json) {
    return PriseDto(
      id: json['_id'] ?? json['id'] ?? '',
      pecheurId: json['pecheur'] ?? json['pecheurId'] ?? '',
      maryeurId: json['maryeur'] ?? json['maryeurId'] ?? '',
      veterinaireId: json['veterinaire'] ?? json['veterinaireId'],
      date: json['date'] ?? '',
      lieu: json['lieu'] ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      description: json['description'],
      photo: json['photo'],
      isValid: json['isValid'] ?? json['isValidated'] ?? false,
    );
  }

  /// Convertit le DTO en modèle Prise
  Prise toPrise() {
    return Prise(
      id: id,
      pecheurId: pecheurId,
      maryeurId: maryeurId,
      veterinaireId: veterinaireId,
      date: date,
      lieu: lieu,
      latitude: latitude,
      longitude: longitude,
      description: description,
      photo: photo,
      isValid: isValid,
    );
  }

  /// Convertit le DTO en Map (JSON)
  Map<String, dynamic> toJson() {
    final map = {
      'id': id,
      'pecheur': pecheurId,
      'maryeur': maryeurId,
      'date': date,
      'lieu': lieu,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'photo': photo,
      'isValid': isValid,
    };

    // Ajouter le vétérinaire seulement s'il est défini
    if (veterinaireId != null) {
      map['veterinaire'] = veterinaireId;
    }

    return map;
  }

  /// Crée une copie du DTO avec des valeurs modifiées
  PriseDto copyWith({
    String? id,
    String? pecheurId,
    String? maryeurId,
    String? veterinaireId,
    String? date,
    String? lieu,
    double? latitude,
    double? longitude,
    String? description,
    String? photo,
    bool? isValid,
  }) {
    return PriseDto(
      id: id ?? this.id,
      pecheurId: pecheurId ?? this.pecheurId,
      maryeurId: maryeurId ?? this.maryeurId,
      veterinaireId: veterinaireId ?? this.veterinaireId,
      date: date ?? this.date,
      lieu: lieu ?? this.lieu,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      isValid: isValid ?? this.isValid,
    );
  }

  /// Convertit une valeur en double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
