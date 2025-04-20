/// Représente un tag RFID dans le système, correspondant à la table `marketplace_rfid` dans la base de données.
class MarketplaceRfid {
  final int? id;
  final String code;
  final String? description;
  final int? priseId;
  final int? produitId;

  MarketplaceRfid({
    this.id,
    required this.code,
    this.description,
    this.priseId,
    this.produitId,
  });

  /// Crée un nouveau tag RFID
  factory MarketplaceRfid.create({
    required String code,
    String? description,
    int? priseId,
    int? produitId,
  }) {
    return MarketplaceRfid(
      code: code,
      description: description,
      priseId: priseId,
      produitId: produitId,
    );
  }

  /// Convertit un tag RFID en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'code': code,
      if (description != null) 'description': description,
      if (priseId != null) 'prise_id': priseId,
      if (produitId != null) 'produit_id': produitId,
    };
  }

  /// Crée un tag RFID à partir d'un Map de SQLite
  factory MarketplaceRfid.fromMap(Map<String, dynamic> map) {
    return MarketplaceRfid(
      id: map['id'],
      code: map['code'] ?? '',
      description: map['description'],
      priseId: map['prise_id'],
      produitId: map['produit_id'],
    );
  }

  /// Crée une copie du tag RFID avec des modifications
  MarketplaceRfid copyWith({
    int? id,
    String? code,
    String? description,
    int? priseId,
    int? produitId,
  }) {
    return MarketplaceRfid(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      priseId: priseId ?? this.priseId,
      produitId: produitId ?? this.produitId,
    );
  }
}
