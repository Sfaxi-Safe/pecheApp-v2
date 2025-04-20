/// Représente un utilisateur dans le système, correspondant à la table `marketplace_user` dans la base de données.
class MarketplaceUser {
  final int? id;
  final String email;
  final List<String> roles;
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

  MarketplaceUser({
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

  /// Crée un nouvel utilisateur
  factory MarketplaceUser.create({
    required String email,
    required List<String> roles,
    required String password,
    required String nom,
    required String prenom,
    int? telephone,
    bool isVerified = false,
    bool isBlocked = false,
    String? civilite,
    String? service,
    String? fonction,
    String? mobile,
    String? linkedin,
    String? facebook,
    String? tweeter,
    String? photo,
    bool? isValid,
    String? adresse,
  }) {
    // Validation de l'email
    if (!email.contains('@')) {
      throw ArgumentError('Email invalide');
    }
    
    return MarketplaceUser(
      email: email,
      roles: roles,
      password: password,
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      isVerified: isVerified,
      isBlocked: isBlocked,
      civilite: civilite,
      service: service,
      fonction: fonction,
      mobile: mobile,
      linkedin: linkedin,
      facebook: facebook,
      tweeter: tweeter,
      photo: photo,
      isValid: isValid,
      adresse: adresse,
    );
  }

  /// Convertit un utilisateur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'roles': rolesListToJson(roles),
      'password': password,
      'nom': nom,
      'prenom': prenom,
      if (telephone != null) 'telephone': telephone,
      'is_verified': isVerified ? 1 : 0,
      'is_blocked': isBlocked ? 1 : 0,
      if (civilite != null) 'civilite': civilite,
      if (service != null) 'service': service,
      if (fonction != null) 'fonction': fonction,
      if (mobile != null) 'mobile': mobile,
      if (linkedin != null) 'linkedin': linkedin,
      if (facebook != null) 'facebook': facebook,
      if (tweeter != null) 'tweeter': tweeter,
      if (photo != null) 'photo': photo,
      if (isValid != null) 'is_valid': isValid! ? 1 : 0,
      if (adresse != null) 'adresse': adresse,
    };
  }

  /// Crée un utilisateur à partir d'un Map de SQLite
  factory MarketplaceUser.fromMap(Map<String, dynamic> map) {
    return MarketplaceUser(
      id: map['id'],
      email: map['email'] ?? '',
      roles: jsonToRolesList(map['roles']),
      password: map['password'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      telephone: map['telephone'],
      isVerified: map['is_verified'] == 1,
      isBlocked: map['is_blocked'] == 1,
      civilite: map['civilite'],
      service: map['service'],
      fonction: map['fonction'],
      mobile: map['mobile'],
      linkedin: map['linkedin'],
      facebook: map['facebook'],
      tweeter: map['tweeter'],
      photo: map['photo'],
      isValid: map['is_valid'] == null ? null : map['is_valid'] == 1,
      adresse: map['adresse'],
    );
  }

  /// Crée une copie de l'utilisateur avec des modifications
  MarketplaceUser copyWith({
    int? id,
    String? email,
    List<String>? roles,
    String? password,
    String? nom,
    String? prenom,
    int? telephone,
    bool? isVerified,
    bool? isBlocked,
    String? civilite,
    String? service,
    String? fonction,
    String? mobile,
    String? linkedin,
    String? facebook,
    String? tweeter,
    String? photo,
    bool? isValid,
    String? adresse,
  }) {
    return MarketplaceUser(
      id: id ?? this.id,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      password: password ?? this.password,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      isVerified: isVerified ?? this.isVerified,
      isBlocked: isBlocked ?? this.isBlocked,
      civilite: civilite ?? this.civilite,
      service: service ?? this.service,
      fonction: fonction ?? this.fonction,
      mobile: mobile ?? this.mobile,
      linkedin: linkedin ?? this.linkedin,
      facebook: facebook ?? this.facebook,
      tweeter: tweeter ?? this.tweeter,
      photo: photo ?? this.photo,
      isValid: isValid ?? this.isValid,
      adresse: adresse ?? this.adresse,
    );
  }

  /// Convertit une liste de rôles en JSON
  static String rolesListToJson(List<String> roles) {
    return '["${roles.join('","')}"]';
  }

  /// Convertit un JSON en liste de rôles
  static List<String> jsonToRolesList(String? json) {
    if (json == null || json.isEmpty) {
      return [];
    }
    
    // Supprimer les crochets et les guillemets
    final cleanJson = json.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
    
    // Diviser la chaîne en liste
    if (cleanJson.isEmpty) {
      return [];
    }
    
    return cleanJson.split(',');
  }

  /// Vérifie si l'utilisateur a un rôle spécifique
  bool hasRole(String role) {
    return roles.contains(role);
  }

  /// Vérifie si l'utilisateur est un pêcheur
  bool get isPecheur => hasRole('ROLE_PECHEUR');

  /// Vérifie si l'utilisateur est un client
  bool get isClient => hasRole('ROLE_CLIENT');

  /// Vérifie si l'utilisateur est un administrateur
  bool get isAdmin => hasRole('ROLE_ADMIN');

  /// Obtient le nom complet de l'utilisateur
  String get fullName => '$prenom $nom';
}
