class Lot {
  final int? id;
  final int? rfidId;
  final int? vitirinaireId;
  final String? identifiant;
  final String? photo;
  final String? quantite;
  final String? poid;
  final String? espece;
  final String? temperature;
  final String? prixinitial;
  final String? prixminimal;
  final String? prixfinale;
  final String? datetest;
  final bool? test;
  final bool? status;
  final bool? vendre;
  final int? priseId;
  final int? userId;
  final String? datesoumettre;
  final String? poidestimatif;
  final String? typeenchere;
  final String? current;
  final String? online;
  final bool? isProduit;

  Lot({
    this.id,
    this.rfidId,
    this.vitirinaireId,
    this.identifiant,
    this.photo,
    this.quantite,
    this.poid,
    this.espece,
    this.temperature,
    this.prixinitial,
    this.prixminimal,
    this.prixfinale,
    this.datetest,
    this.test,
    this.status,
    this.vendre,
    this.priseId,
    this.userId,
    this.datesoumettre,
    this.poidestimatif,
    this.typeenchere,
    this.current,
    this.online,
    this.isProduit,
  });

  factory Lot.fromMap(Map<String, dynamic> map) {
    return Lot(
      id: map['id'],
      rfidId: map['rfid_id'],
      vitirinaireId: map['vitirinaire_id'],
      identifiant: map['identifiant'],
      photo: map['photo'],
      quantite: map['quantite'],
      poid: map['poid'],
      espece: map['espece'],
      temperature: map['temperature'],
      prixinitial: map['prixinitial'],
      prixminimal: map['prixminimal'],
      prixfinale: map['prixfinale'],
      datetest: map['datetest'],
      test: map['test'] == 1,
      status: map['status'] == 1,
      vendre: map['vendre'] == 1,
      priseId: map['prise_id'],
      userId: map['user_id'],
      datesoumettre: map['datesoumettre'],
      poidestimatif: map['poidestimatif'],
      typeenchere: map['typeenchere'],
      current: map['current'],
      online: map['online'],
      isProduit: map['is_produit'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rfid_id': rfidId,
      'vitirinaire_id': vitirinaireId,
      'identifiant': identifiant,
      'photo': photo,
      'quantite': quantite,
      'poid': poid,
      'espece': espece,
      'temperature': temperature,
      'prixinitial': prixinitial,
      'prixminimal': prixminimal,
      'prixfinale': prixfinale,
      'datetest': datetest,
      'test': test == true ? 1 : 0,
      'status': status == true ? 1 : 0,
      'vendre': vendre == true ? 1 : 0,
      'prise_id': priseId,
      'user_id': userId,
      'datesoumettre': datesoumettre,
      'poidestimatif': poidestimatif,
      'typeenchere': typeenchere,
      'current': current,
      'online': online,
      'is_produit': isProduit == true ? 1 : 0,
    };
  }
}
