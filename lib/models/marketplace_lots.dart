/// Représente un lot de produits dans le système, correspondant à la table `marketplace_lots` dans la base de données.
class MarketplaceLots {
  final int? id;
  final int? rfidId;
  final int? vitirinaireId;
  final String? identifiant;
  final String photo;
  final String quantite;
  final String? poid;
  final String espece;
  final String? temperature;
  final String? prixInitial;
  final String? prixMinimal;
  final String? prixFinale;
  final String? dateTest;
  final bool? test;
  final int? status;
  final bool? vendre;
  final int? priseId;
  final int? userId;
  final String? dateSoumettre;
  final String? poidEstimatif;
  final String? typeEnchere;
  final String? current;
  final String? online;
  final bool? isProduit;

  MarketplaceLots({
    this.id,
    this.rfidId,
    this.vitirinaireId,
    this.identifiant,
    required this.photo,
    required this.quantite,
    this.poid,
    required this.espece,
    this.temperature,
    this.prixInitial,
    this.prixMinimal,
    this.prixFinale,
    this.dateTest,
    this.test,
    this.status,
    this.vendre,
    this.priseId,
    this.userId,
    this.dateSoumettre,
    this.poidEstimatif,
    this.typeEnchere,
    this.current,
    this.online,
    this.isProduit,
  });

  /// Crée un nouveau lot
  factory MarketplaceLots.create({
    int? rfidId,
    int? vitirinaireId,
    String? identifiant,
    required String photo,
    required String quantite,
    String? poid,
    required String espece,
    String? temperature,
    String? prixInitial,
    String? prixMinimal,
    String? prixFinale,
    String? dateTest,
    bool? test,
    int? status,
    bool? vendre,
    int? priseId,
    int? userId,
    String? dateSoumettre,
    String? poidEstimatif,
    String? typeEnchere,
    String? current,
    String? online,
    bool? isProduit,
  }) {
    return MarketplaceLots(
      rfidId: rfidId,
      vitirinaireId: vitirinaireId,
      identifiant: identifiant,
      photo: photo,
      quantite: quantite,
      poid: poid,
      espece: espece,
      temperature: temperature,
      prixInitial: prixInitial,
      prixMinimal: prixMinimal,
      prixFinale: prixFinale,
      dateTest: dateTest,
      test: test,
      status: status,
      vendre: vendre,
      priseId: priseId,
      userId: userId,
      dateSoumettre: dateSoumettre,
      poidEstimatif: poidEstimatif,
      typeEnchere: typeEnchere,
      current: current,
      online: online,
      isProduit: isProduit,
    );
  }

  /// Convertit un lot en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (rfidId != null) 'rfid_id': rfidId,
      if (vitirinaireId != null) 'vitirinaire_id': vitirinaireId,
      if (identifiant != null) 'identifiant': identifiant,
      'photo': photo,
      'quantite': quantite,
      if (poid != null) 'poid': poid,
      'espece': espece,
      if (temperature != null) 'temperature': temperature,
      if (prixInitial != null) 'prixinitial': prixInitial,
      if (prixMinimal != null) 'prixminimal': prixMinimal,
      if (prixFinale != null) 'prixfinale': prixFinale,
      if (dateTest != null) 'datetest': dateTest,
      if (test != null) 'test': test! ? 1 : 0,
      if (status != null) 'status': status,
      if (vendre != null) 'vendre': vendre! ? 1 : 0,
      if (priseId != null) 'prise_id': priseId,
      if (userId != null) 'user_id': userId,
      if (dateSoumettre != null) 'datesoumettre': dateSoumettre,
      if (poidEstimatif != null) 'poidestimatif': poidEstimatif,
      if (typeEnchere != null) 'typeenchere': typeEnchere,
      if (current != null) 'current': current,
      if (online != null) 'online': online,
      if (isProduit != null) 'is_produit': isProduit! ? 1 : 0,
    };
  }

  /// Crée un lot à partir d'un Map de SQLite
  factory MarketplaceLots.fromMap(Map<String, dynamic> map) {
    return MarketplaceLots(
      id: map['id'],
      rfidId: map['rfid_id'],
      vitirinaireId: map['vitirinaire_id'],
      identifiant: map['identifiant'],
      photo: map['photo'] ?? '',
      quantite: map['quantite'] ?? '',
      poid: map['poid'],
      espece: map['espece'] ?? '',
      temperature: map['temperature'],
      prixInitial: map['prixinitial'],
      prixMinimal: map['prixminimal'],
      prixFinale: map['prixfinale'],
      dateTest: map['datetest'],
      test: map['test'] == null ? null : map['test'] == 1,
      status: map['status'],
      vendre: map['vendre'] == null ? null : map['vendre'] == 1,
      priseId: map['prise_id'],
      userId: map['user_id'],
      dateSoumettre: map['datesoumettre'],
      poidEstimatif: map['poidestimatif'],
      typeEnchere: map['typeenchere'],
      current: map['current'],
      online: map['online'],
      isProduit: map['is_produit'] == null ? null : map['is_produit'] == 1,
    );
  }

  /// Crée une copie du lot avec des modifications
  MarketplaceLots copyWith({
    int? id,
    int? rfidId,
    int? vitirinaireId,
    String? identifiant,
    String? photo,
    String? quantite,
    String? poid,
    String? espece,
    String? temperature,
    String? prixInitial,
    String? prixMinimal,
    String? prixFinale,
    String? dateTest,
    bool? test,
    int? status,
    bool? vendre,
    int? priseId,
    int? userId,
    String? dateSoumettre,
    String? poidEstimatif,
    String? typeEnchere,
    String? current,
    String? online,
    bool? isProduit,
  }) {
    return MarketplaceLots(
      id: id ?? this.id,
      rfidId: rfidId ?? this.rfidId,
      vitirinaireId: vitirinaireId ?? this.vitirinaireId,
      identifiant: identifiant ?? this.identifiant,
      photo: photo ?? this.photo,
      quantite: quantite ?? this.quantite,
      poid: poid ?? this.poid,
      espece: espece ?? this.espece,
      temperature: temperature ?? this.temperature,
      prixInitial: prixInitial ?? this.prixInitial,
      prixMinimal: prixMinimal ?? this.prixMinimal,
      prixFinale: prixFinale ?? this.prixFinale,
      dateTest: dateTest ?? this.dateTest,
      test: test ?? this.test,
      status: status ?? this.status,
      vendre: vendre ?? this.vendre,
      priseId: priseId ?? this.priseId,
      userId: userId ?? this.userId,
      dateSoumettre: dateSoumettre ?? this.dateSoumettre,
      poidEstimatif: poidEstimatif ?? this.poidEstimatif,
      typeEnchere: typeEnchere ?? this.typeEnchere,
      current: current ?? this.current,
      online: online ?? this.online,
      isProduit: isProduit ?? this.isProduit,
    );
  }
}
