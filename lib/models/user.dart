class User {
  final String? id; // Changé de int? à String? pour Firebase
  final String email;
  final String roles;
  final String password;
  final String nom;
  final String prenom;
  final int? telephone;
  final bool isVerified;
  final bool isBlocked;
  final String? civilite;
  final String? service;
  final String? fonction;
  final String? mobile;
  final String? linkedin;
  final String? facebook;
  final String? tweeter;
  final String? photo;
  final bool? isValid;
  final String? adresse;

  User({
    this.id,
    required this.email,
    required this.roles,
    required this.password,
    required this.nom,
    required this.prenom,
    this.telephone,
    required this.isVerified,
    required this.isBlocked,
    this.civilite,
    this.service,
    this.fonction,
    this.mobile,
    this.linkedin,
    this.facebook,
    this.tweeter,
    this.photo,
    this.isValid,
    this.adresse,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      roles: map['roles'],
      password: map['password'],
      nom: map['nom'],
      prenom: map['prenom'],
      telephone: map['telephone'],
      // Gérer les booléens de Firebase
      isVerified: map['isVerified'] == true,
      isBlocked: map['isBlocked'] == true,
      civilite: map['civilite'],
      service: map['service'],
      fonction: map['fonction'],
      mobile: map['mobile'],
      linkedin: map['linkedin'],
      facebook: map['facebook'],
      tweeter: map['tweeter'],
      photo: map['photo'],
      isValid: map['isValid'] == true,
      adresse: map['adresse'],
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
      'telephone': telephone,
      // Utiliser les noms de champs Firebase
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'civilite': civilite,
      'service': service,
      'fonction': fonction,
      'mobile': mobile,
      'linkedin': linkedin,
      'facebook': facebook,
      'tweeter': tweeter,
      'photo': photo,
      'isValid': isValid,
      'adresse': adresse,
    };
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

  bool isAdmin() {
    return roles.contains('ROLE_ADMIN');
  }
}
