import 'package:uuid/uuid.dart';

class Fisherman {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String? cin;
  final String? matricule;
  final String? capacite;
  final String? longeur;
  final String? largeur;
  final String? bateau;
  final String? pays;
  final String? proprietaire;
  final String? serie;
  final String? certification;
  final String? port;
  final String? engin;
  final String telephone;
  final bool isValid;

  Fisherman({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.cin,
    this.matricule,
    this.capacite,
    this.longeur,
    this.largeur,
    this.bateau,
    this.pays,
    this.proprietaire,
    this.serie,
    this.certification,
    this.port,
    this.engin,
    required this.telephone,
    this.isValid = false,
  });

  // Créer un nouveau pêcheur avec un ID généré
  factory Fisherman.create({
    required String email,
    required String nom,
    required String prenom,
    String? cin,
    String? matricule,
    String? capacite,
    String? longeur,
    String? largeur,
    String? bateau,
    String? pays,
    String? proprietaire,
    String? serie,
    String? certification,
    String? port,
    String? engin,
    required String telephone,
    bool isValid = false,
  }) {
    return Fisherman(
      id: const Uuid().v4(),
      email: email,
      nom: nom,
      prenom: prenom,
      cin: cin,
      matricule: matricule,
      capacite: capacite,
      longeur: longeur,
      largeur: largeur,
      bateau: bateau,
      pays: pays,
      proprietaire: proprietaire,
      serie: serie,
      certification: certification,
      port: port,
      engin: engin,
      telephone: telephone,
      isValid: isValid,
    );
  }

  // Convertir un Fisherman en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'matricule': matricule,
      'capacite': capacite,
      'longeur': longeur,
      'largeur': largeur,
      'bateau': bateau,
      'pays': pays,
      'proprietaire': proprietaire,
      'serie': serie,
      'certification': certification,
      'port': port,
      'engin': engin,
      'telephone': telephone,
      'isValid': isValid ? 1 : 0,
    };
  }

  // Créer un Fisherman à partir d'un Map de SQLite
  factory Fisherman.fromMap(Map<String, dynamic> map) {
    return Fisherman(
      id: map['id'],
      email: map['email'],
      nom: map['nom'],
      prenom: map['prenom'],
      cin: map['cin'],
      matricule: map['matricule'],
      capacite: map['capacite'],
      longeur: map['longeur'],
      largeur: map['largeur'],
      bateau: map['bateau'],
      pays: map['pays'],
      proprietaire: map['proprietaire'],
      serie: map['serie'],
      certification: map['certification'],
      port: map['port'],
      engin: map['engin'],
      telephone: map['telephone'],
      isValid: map['isValid'] == 1,
    );
  }

  // Créer une copie d'un Fisherman avec des modifications
  Fisherman copyWith({
    String? id,
    String? email,
    String? nom,
    String? prenom,
    String? cin,
    String? matricule,
    String? capacite,
    String? longeur,
    String? largeur,
    String? bateau,
    String? pays,
    String? proprietaire,
    String? serie,
    String? certification,
    String? port,
    String? engin,
    String? telephone,
    bool? isValid,
  }) {
    return Fisherman(
      id: id ?? this.id,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      cin: cin ?? this.cin,
      matricule: matricule ?? this.matricule,
      capacite: capacite ?? this.capacite,
      longeur: longeur ?? this.longeur,
      largeur: largeur ?? this.largeur,
      bateau: bateau ?? this.bateau,
      pays: pays ?? this.pays,
      proprietaire: proprietaire ?? this.proprietaire,
      serie: serie ?? this.serie,
      certification: certification ?? this.certification,
      port: port ?? this.port,
      engin: engin ?? this.engin,
      telephone: telephone ?? this.telephone,
      isValid: isValid ?? this.isValid,
    );
  }
}
