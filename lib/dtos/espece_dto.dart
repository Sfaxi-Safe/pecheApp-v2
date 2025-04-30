import 'package:seatrace/models/espece.dart';

/// DTO (Data Transfer Object) pour l'espèce
/// Utilisé pour standardiser les échanges de données entre le frontend et le backend
class EspeceDto {
  final String id;
  final String nom;
  final String? description;
  final String? photo;
  final double? prixMinimal;
  final double? prixMoyen;
  final bool isActive;

  EspeceDto({
    required this.id,
    required this.nom,
    this.description,
    this.photo,
    this.prixMinimal,
    this.prixMoyen,
    this.isActive = true,
  });

  /// Crée un EspeceDto à partir d'un Map (JSON)
  factory EspeceDto.fromJson(Map<String, dynamic> json) {
    return EspeceDto(
      id: json['_id'] ?? json['id'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'],
      photo: json['photo'],
      prixMinimal: _parseDouble(json['prixMinimal'] ?? json['prixminimal']),
      prixMoyen: _parseDouble(json['prixMoyen'] ?? json['prixmoyen']),
      isActive: json['isActive'] ?? json['isValid'] ?? true,
    );
  }

  /// Convertit le DTO en modèle Espece
  Espece toEspece() {
    return Espece(
      id: id,
      nom: nom,
      description: description ?? '',
      photo: photo,
      prixMinimal: prixMinimal ?? 0.0,
      prixMoyen: prixMoyen ?? 0.0,
      isActive: isActive,
    );
  }

  /// Convertit le DTO en Map (JSON)
  Map<String, dynamic> toJson() {
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

  /// Crée une copie du DTO avec des valeurs modifiées
  EspeceDto copyWith({
    String? id,
    String? nom,
    String? description,
    String? photo,
    double? prixMinimal,
    double? prixMoyen,
    bool? isActive,
  }) {
    return EspeceDto(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      prixMinimal: prixMinimal ?? this.prixMinimal,
      prixMoyen: prixMoyen ?? this.prixMoyen,
      isActive: isActive ?? this.isActive,
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
