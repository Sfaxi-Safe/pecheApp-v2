import 'package:uuid/uuid.dart';

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
  final int? status;
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

  // Créer un nouveau lot avec un ID généré
  factory Lot.create({
    String? rfidId,
    String? veterinaireId,
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
    String? priseId,
    String? userId,
    String? dateSoumettre,
    String? poidEstimatif,
    String? typeEnchere,
    String? current,
    String? online,
    bool? isProduit,
  }) {
    return Lot(
      id: const Uuid().v4(),
      rfidId: rfidId,
      veterinaireId: veterinaireId,
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

  // Convertir un Lot en Map pour SQLite
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
      'test': test == true ? 1 : test == false ? 0 : null,
      'status': status,
      'vendre': vendre == true ? 1 : vendre == false ? 0 : null,
      'priseId': priseId,
      'userId': userId,
      'dateSoumettre': dateSoumettre,
      'poidEstimatif': poidEstimatif,
      'typeEnchere': typeEnchere,
      'current': current,
      'online': online,
      'isProduit': isProduit == true ? 1 : isProduit == false ? 0 : null,
    };
  }

  // Créer un Lot à partir d'un Map de SQLite
  factory Lot.fromMap(Map<String, dynamic> map) {
    return Lot(
      id: map['id'],
      rfidId: map['rfidId'],
      veterinaireId: map['veterinaireId'],
      identifiant: map['identifiant'],
      photo: map['photo'],
      quantite: map['quantite'],
      poid: map['poid'],
      espece: map['espece'],
      temperature: map['temperature'],
      prixInitial: map['prixInitial'],
      prixMinimal: map['prixMinimal'],
      prixFinale: map['prixFinale'],
      dateTest: map['dateTest'],
      test: map['test'] == null ? null : map['test'] == 1,
      status: map['status'],
      vendre: map['vendre'] == null ? null : map['vendre'] == 1,
      priseId: map['priseId'],
      userId: map['userId'],
      dateSoumettre: map['dateSoumettre'],
      poidEstimatif: map['poidEstimatif'],
      typeEnchere: map['typeEnchere'],
      current: map['current'],
      online: map['online'],
      isProduit: map['isProduit'] == null ? null : map['isProduit'] == 1,
    );
  }
}
