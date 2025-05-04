class Prise {
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

  Prise({
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

  factory Prise.fromMap(Map<String, dynamic> map) {
    return Prise(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      pecheurId:
          map['pecheur']?.toString() ?? map['pecheurId']?.toString() ?? '',
      maryeurId:
          map['maryeur']?.toString() ?? map['maryeurId']?.toString() ?? '',
      veterinaireId:
          map['veterinaire']?.toString() ?? map['veterinaireId']?.toString(),
      date: map['date'] ?? '',
      lieu: map['lieu'] ?? '',
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      description: map['description'],
      photo: map['photo'],
      isValid: map['isValid'] ?? map['isValidated'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
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
