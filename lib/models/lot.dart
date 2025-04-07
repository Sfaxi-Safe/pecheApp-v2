class Lot {
  final String id;
  final String? rfidId;
  final String? veterinaireId;
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
  final bool? status;
  final bool? vendre;
  final String? priseId;
  final String? userId;
  final String? dateSoumettre;
  final String? poidEstimatif;
  final String? typeEnchere;
  final String? current;
  final String? online;
  final bool? isProduit;

  Lot({
    required this.id,
    this.rfidId,
    this.veterinaireId,
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

  // Convertir un objet Lot en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rfidId': rfidId,
      'veterinaireId': veterinaireId,
      'identifiant': identifiant,
      'photo': photo,
      'quantite': quantite,
      'poid': poid,
      'espece': espece,
      'temperature': temperature,
      'prixInitial': prixInitial,
      'prixMinimal': prixMinimal,
      'prixFinale': prixFinale,
      'dateTest': dateTest,
      'test': test,
      'status': status,
      'vendre': vendre,
      'priseId': priseId,
      'userId': userId,
      'dateSoumettre': dateSoumettre,
      'poidEstimatif': poidEstimatif,
      'typeEnchere': typeEnchere,
      'current': current,
      'online': online,
      'isProduit': isProduit,
    };
  }

  // Créer un objet Lot à partir d'un Map
  factory Lot.fromMap(Map<String, dynamic> map) {
    return Lot(
      id: map['id']?.toString() ?? '',
      rfidId: map['rfid_id']?.toString(),
      veterinaireId: map['vitirinaire_id']?.toString(),
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
      test: map['test'] == 1,
      status: map['status'] == 1,
      vendre: map['vendre'] == 1,
      priseId: map['prise_id']?.toString(),
      userId: map['user_id']?.toString(),
      dateSoumettre: map['datesoumettre'],
      poidEstimatif: map['poidestimatif'],
      typeEnchere: map['typeenchere'],
      current: map['current'],
      online: map['online'],
      isProduit: map['is_produit'] == 1,
    );
  }
}
