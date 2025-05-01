class Pecheur {
  final String? id;
  final String email;
  final String roles;
  final String password;
  final String nom;
  final String prenom;
  final String? cin;
  final String? matricule;
  final String? bateau;
  final String? pays;
  final String? port;
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
    this.bateau,
    this.pays,
    this.port,
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
      bateau: map['bateau'],
      pays: map['pays'],
      port: map['port'],
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
      'bateau': bateau,
      'pays': pays,
      'port': port,
      'telephone': telephone,
    };
    return map;
  }
}
