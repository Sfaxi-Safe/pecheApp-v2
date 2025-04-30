class User {
  final String? id;
  final String email;
  final String roles;
  final String password;
  final String nom;
  final String prenom;
  final int? telephone;
  final String? civilite;
  final String? service;
  final String? fonction;
  final String? mobile;
  final String? linkedin;
  final String? facebook;
  final String? tweeter;
  final String? photo;
  final String? adresse;

  User({
    this.id,
    required this.email,
    required this.roles,
    required this.password,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.civilite,
    this.service,
    this.fonction,
    this.mobile,
    this.linkedin,
    this.facebook,
    this.tweeter,
    this.photo,
    this.adresse,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id']?.toString(),
      email: map['email'],
      roles: map['roles'],
      password: map['password'],
      nom: map['nom'],
      prenom: map['prenom'],
      telephone: map['telephone'],
      civilite: map['civilite'],
      service: map['service'],
      fonction: map['fonction'],
      mobile: map['mobile'],
      linkedin: map['linkedin'],
      facebook: map['facebook'],
      tweeter: map['tweeter'],
      photo: map['photo'],
      adresse: map['adresse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'roles': roles,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'civilite': civilite,
      'service': service,
      'fonction': fonction,
      'mobile': mobile,
      'linkedin': linkedin,
      'facebook': facebook,
      'tweeter': tweeter,
      'photo': photo,
      'adresse': adresse,
    }..removeWhere((key, value) => value == null);
  }

  // Helper methods to check user role
  bool isPecheur() {
    return roles.contains('ROLE_PECHEUR');
  }

  bool isVeterinaire() {
    return roles.contains('ROLE_VETERINAIRE');
  }

  bool isMaryeur() {
    return roles.contains('ROLE_MARYEUR');
  }

  bool isClient() {
    return roles.contains('ROLE_CLIENT');
  }
}
