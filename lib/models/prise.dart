class Prise {
  final String id;
  final String pecheurId;
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
    return {
      'id': id,
      'pecheur': pecheurId,
      'date': date,
      'lieu': lieu,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'photo': photo,
      'isValid': isValid,
    };
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
