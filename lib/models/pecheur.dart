class Pecheur {
  final String? id;
  final String email;
  final String roles;
  final String password;
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
  final String? wallet;
  final String? mykeyss;
  final String? telephone;

  Pecheur({
    this.id,
    required this.email,
    required this.roles,
    required this.password,
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
    this.wallet,
    this.mykeyss,
    this.telephone,
  });

  factory Pecheur.fromMap(Map<String, dynamic> map) {
    return Pecheur(
      id: map['_id']?.toString(),
      email: map['email'],
      roles: map['roles'],
      password: map['password'],
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
      wallet: map['wallet'],
      mykeyss: map['mykeyss'],
      telephone: map['telephone'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      '_id': id,
      'email': email,
      'roles': roles,
      'password': password,
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
      'wallet': wallet,
      'mykeyss': mykeyss,
      'telephone': telephone,
    };
    return map;
  }
}
