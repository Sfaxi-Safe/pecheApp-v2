import 'package:seatrace/models/lot.dart';

/// DTO (Data Transfer Object) pour le lot
/// Utilisé pour standardiser les échanges de données entre le frontend et le backend
class LotDto {
  final String id;
  final String identifiant;
  final String? photo;
  final int quantite;
  final double poids;
  final String espece;
  final double temperature;
  final String dateTest;
  final bool test;
  final bool status;
  final bool vendu;
  final String priseId;
  final String userId;
  final String dateSoumission;
  final bool isProduit;
  final double? prixInitial;
  final double? prixMinimal;
  final double? prixFinal;
  final String? acheteurId;

  LotDto({
    required this.id,
    required this.identifiant,
    this.photo,
    required this.quantite,
    required this.poids,
    required this.espece,
    required this.temperature,
    required this.dateTest,
    required this.test,
    required this.status,
    required this.vendu,
    required this.priseId,
    required this.userId,
    required this.dateSoumission,
    required this.isProduit,
    this.prixInitial,
    this.prixMinimal,
    this.prixFinal,
    this.acheteurId,
  });

  /// Crée un LotDto à partir d'un Map (JSON)
  factory LotDto.fromJson(Map<String, dynamic> json) {
    return LotDto(
      id: json['_id'] ?? json['id'] ?? '',
      identifiant: json['identifiant'] ?? '',
      photo: json['photo'],
      quantite: _parseInt(json['quantite']) ?? 0,
      poids: _parseDouble(json['poids']) ?? 0.0,
      espece: json['espece'] ?? '',
      temperature: _parseDouble(json['temperature']) ?? 0.0,
      dateTest: json['dateTest'] ?? '',
      test: _parseBool(json['test']),
      status: _parseBool(json['status']),
      vendu: _parseBool(json['vendu']),
      priseId: json['prise'] ?? json['priseId'] ?? '',
      userId: json['user'] ?? json['userId'] ?? '',
      dateSoumission: json['dateSoumission'] ?? '',
      isProduit: _parseBool(json['isProduit']),
      prixInitial: _parseDouble(json['prixInitial'] ?? json['prixinitial']),
      prixMinimal: _parseDouble(json['prixMinimal'] ?? json['prixminimal']),
      prixFinal: _parseDouble(json['prixFinal'] ?? json['prixfinale']),
      acheteurId: json['acheteur'] ?? json['acheteurId'],
    );
  }

  /// Convertit le DTO en modèle Lot
  Lot toLot() {
    return Lot(
      id: id,
      identifiant: identifiant,
      photo: photo,
      quantite: quantite,
      poids: poids,
      espece: espece,
      temperature: temperature,
      dateTest: dateTest,
      test: test,
      status: status,
      vendu: vendu,
      priseId: priseId,
      userId: userId,
      dateSoumission: dateSoumission,
      isProduit: isProduit,
      prixInitial: prixInitial,
      prixMinimal: prixMinimal,
      prixFinal: prixFinal,
      acheteurId: acheteurId,
    );
  }

  /// Convertit le DTO en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identifiant': identifiant,
      'photo': photo,
      'quantite': quantite,
      'poids': poids,
      'espece': espece,
      'temperature': temperature,
      'dateTest': dateTest,
      'test': test,
      'status': status,
      'vendu': vendu,
      'prise': priseId,
      'user': userId,
      'dateSoumission': dateSoumission,
      'isProduit': isProduit,
      'prixInitial': prixInitial,
      'prixMinimal': prixMinimal,
      'prixFinal': prixFinal,
      'acheteur': acheteurId,
    };
  }

  /// Crée une copie du DTO avec des valeurs modifiées
  LotDto copyWith({
    String? id,
    String? identifiant,
    String? photo,
    int? quantite,
    double? poids,
    String? espece,
    double? temperature,
    String? dateTest,
    bool? test,
    bool? status,
    bool? vendu,
    String? priseId,
    String? userId,
    String? dateSoumission,
    bool? isProduit,
    double? prixInitial,
    double? prixMinimal,
    double? prixFinal,
    String? acheteurId,
  }) {
    return LotDto(
      id: id ?? this.id,
      identifiant: identifiant ?? this.identifiant,
      photo: photo ?? this.photo,
      quantite: quantite ?? this.quantite,
      poids: poids ?? this.poids,
      espece: espece ?? this.espece,
      temperature: temperature ?? this.temperature,
      dateTest: dateTest ?? this.dateTest,
      test: test ?? this.test,
      status: status ?? this.status,
      vendu: vendu ?? this.vendu,
      priseId: priseId ?? this.priseId,
      userId: userId ?? this.userId,
      dateSoumission: dateSoumission ?? this.dateSoumission,
      isProduit: isProduit ?? this.isProduit,
      prixInitial: prixInitial ?? this.prixInitial,
      prixMinimal: prixMinimal ?? this.prixMinimal,
      prixFinal: prixFinal ?? this.prixFinal,
      acheteurId: acheteurId ?? this.acheteurId,
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

  /// Convertit une valeur en int
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Convertit une valeur en bool
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}
