class Lot {
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

  Lot({
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

  factory Lot.fromMap(Map<String, dynamic> map) {
    return Lot(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      identifiant: map['identifiant'] ?? '',
      photo: map['photo'],
      quantite: _parseInt(map['quantite']) ?? 0,
      poids: _parseDouble(map['poids'] ?? map['poid']) ?? 0.0,
      espece: map['espece'] ?? '',
      temperature: _parseDouble(map['temperature']) ?? 0.0,
      dateTest: map['dateTest'] ?? map['datetest'] ?? '',
      test: _parseBool(map['test']),
      status: _parseBool(map['status']),
      vendu: _parseBool(map['vendu'] ?? map['vendre']),
      priseId:
          map['prise']?.toString() ??
          map['priseId']?.toString() ??
          map['prise_id']?.toString() ??
          '',
      userId:
          map['user']?.toString() ??
          map['userId']?.toString() ??
          map['user_id']?.toString() ??
          '',
      dateSoumission: map['dateSoumission'] ?? map['datesoumettre'] ?? '',
      isProduit: _parseBool(map['isProduit'] ?? map['is_produit']),
      prixInitial: _parseDouble(map['prixInitial'] ?? map['prixinitial']),
      prixMinimal: _parseDouble(map['prixMinimal'] ?? map['prixminimal']),
      prixFinal: _parseDouble(map['prixFinal'] ?? map['prixfinale']),
      acheteurId: map['acheteur']?.toString() ?? map['acheteurId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
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
