class Veterinaire {
  final String id;
  final String email;
  final String roles;
  final String password;
  final String nom;
  final String prenom;
  final String? cin;
  final String? matricule;
  final String? specialite;
  final String? certification;
  final String? telephone;
  final String? photo;
  final bool isValidated;
  final bool isBlocked;

  Veterinaire({
    required this.id,
    required this.email,
    required this.roles,
    required this.password,
    required this.nom,
    required this.prenom,
    this.cin,
    this.matricule,
    this.specialite,
    this.certification,
    this.telephone,
    this.photo,
    this.isValidated = false,
    this.isBlocked = false,
  });

  factory Veterinaire.fromMap(Map<String, dynamic> map) {
    return Veterinaire(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      roles: map['roles'] ?? '',
      password: map['password'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      cin: map['cin'],
      matricule: map['matricule'],
      specialite: map['specialite'],
      certification: map['certification'],
      telephone: map['telephone']?.toString(),
      photo: map['photo'],
      isValidated: map['isValidated'] ?? map['isValid'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
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
      'specialite': specialite,
      'certification': certification,
      'telephone': telephone,
      'photo': photo,
      'isValidated': isValidated,
      'isBlocked': isBlocked,
    };
  }
}
