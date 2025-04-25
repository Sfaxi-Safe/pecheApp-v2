class Vitirinaire {
  final int? id;
  final String email;
  final String roles;
  final String password;
  final String nom;
  final String prenom;
  final String? cin;
  final String? matricule;
  final String? port;
  final String? pays;
  final String? wallet;
  final String? mykeyss;
  final int? telephone;
  final bool isValid;

  Vitirinaire({
    this.id,
    required this.email,
    required this.roles,
    required this.password,
    required this.nom,
    required this.prenom,
    this.cin,
    this.matricule,
    this.port,
    this.pays,
    this.wallet,
    this.mykeyss,
    this.telephone,
    required this.isValid,
  });

  factory Vitirinaire.fromMap(Map<String, dynamic> map) {
    return Vitirinaire(
      id: map['id'],
      email: map['email'],
      roles: map['roles'],
      password: map['password'],
      nom: map['nom'],
      prenom: map['prenom'],
      cin: map['cin'],
      matricule: map['matricule'],
      port: map['port'],
      pays: map['pays'],
      wallet: map['wallet'],
      mykeyss: map['mykeyss'],
      telephone: map['telephone'],
      isValid: map['is_valid'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'roles': roles,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'matricule': matricule,
      'port': port,
      'pays': pays,
      'wallet': wallet,
      'mykeyss': mykeyss,
      'telephone': telephone,
      'is_valid': isValid ? 1 : 0,
    };
  }
}
