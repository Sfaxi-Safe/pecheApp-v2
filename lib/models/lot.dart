class Lot {
  final String? id; // Changé de int? à String? pour Firebase
  final String? rfidId; // Changé de int? à String? pour Firebase
  final String? vitirinaireId; // Changé de int? à String? pour Firebase
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
  final String? priseId; // Changé de int? à String? pour Firebase
  final String? userId; // Changé de int? à String? pour Firebase
  final String? datesoumettre;
  final String? poidestimatif;
  final String? typeenchere;
  final String? current;
  final String? online;
  final bool? isProduit;
  final String? devise;
  final String? maryeurId;
  final String? pecheurId;
  final String? dateEnchere;
  final String? createdAt;

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
    this.devise,
    this.maryeurId,
    this.pecheurId,
    this.dateEnchere,
    this.createdAt,
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
      test: map['test'] == true,
      status: map['status'] == true,
      vendre: map['vendre'] == true,
      priseId: map['prise_id'],
      userId: map['user_id'],
      datesoumettre: map['datesoumettre'],
      poidestimatif: map['poidestimatif'],
      typeenchere: map['typeenchere'],
      current: map['current'],
      online: map['online'],
      isProduit: map['isProduit'] == true,
      devise: map['devise'],
      maryeurId: map['maryeur_id'],
      pecheurId: map['pecheur_id'],
      dateEnchere: map['dateEnchere'],
      createdAt: map['createdAt'],
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
      'test': test,
      'status': status,
      'vendre': vendre,
      'prise_id': priseId,
      'user_id': userId,
      'datesoumettre': datesoumettre,
      'poidestimatif': poidestimatif,
      'typeenchere': typeenchere,
      'current': current,
      'online': online,
      'isProduit': isProduit,
      'devise': devise,
      'maryeur_id': maryeurId,
      'pecheur_id': pecheurId,
      'dateEnchere': dateEnchere,
      'createdAt': createdAt,
    };
  }
}
