class Espece {
  final String id;
  final String nom;
  final String description;
  final String? photo;
  final double prixMinimal;
  final double prixMoyen;
  final bool isActive;

  Espece({
    required this.id,
    required this.nom,
    this.description = '',
    this.photo,
    this.prixMinimal = 0.0,
    this.prixMoyen = 0.0,
    this.isActive = true,
  });

  factory Espece.fromMap(Map<String, dynamic> map) {
    return Espece(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      photo: map['photo'] ?? map['image_url'],
      prixMinimal:
          _parseDouble(map['prixMinimal'] ?? map['prix_minimal']) ?? 0.0,
      prixMoyen: _parseDouble(map['prixMoyen'] ?? map['prix_moyen']) ?? 0.0,
      isActive: map['isActive'] ?? map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'photo': photo,
      'prixMinimal': prixMinimal,
      'prixMoyen': prixMoyen,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return 'Espece{id: $id, nom: $nom, description: $description, photo: $photo, prixMinimal: $prixMinimal, prixMoyen: $prixMoyen, isActive: $isActive}';
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
