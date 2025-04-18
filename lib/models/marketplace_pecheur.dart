/// Représente un pêcheur dans le système, correspondant à la table `marketplace_pecheur` dans la base de données.
class MarketplacePecheur {
  final int? id;
  final String email;
  final List<String> roles;
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
  final int? telephone;
  final bool? isValid;

  MarketplacePecheur({
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
    this.isValid,
  });

  /// Crée un nouveau pêcheur
  factory MarketplacePecheur.create({
    required String email,
    required List<String> roles,
    required String password,
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
    String? wallet,
    String? mykeyss,
    int? telephone,
    bool? isValid,
  }) {
    return MarketplacePecheur(
      email: email,
      roles: roles,
      password: password,
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
      wallet: wallet,
      mykeyss: mykeyss,
      telephone: telephone,
      isValid: isValid,
    );
  }

  /// Convertit un pêcheur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'roles': rolesListToJson(roles),
      'password': password,
      'nom': nom,
      'prenom': prenom,
      if (cin != null) 'cin': cin,
      if (matricule != null) 'matricule': matricule,
      if (capacite != null) 'capacite': capacite,
      if (longeur != null) 'longeur': longeur,
      if (largeur != null) 'largeur': largeur,
      if (bateau != null) 'bateau': bateau,
      if (pays != null) 'pays': pays,
      if (proprietaire != null) 'proprietaire': proprietaire,
      if (serie != null) 'serie': serie,
      if (certification != null) 'certification': certification,
      if (port != null) 'port': port,
      if (engin != null) 'engin': engin,
      if (wallet != null) 'wallet': wallet,
      if (mykeyss != null) 'mykeyss': mykeyss,
      if (telephone != null) 'telephone': telephone,
      if (isValid != null) 'is_valid': isValid! ? 1 : 0,
    };
  }

  /// Crée un pêcheur à partir d'un Map de SQLite
  factory MarketplacePecheur.fromMap(Map<String, dynamic> map) {
    return MarketplacePecheur(
      id: map['id'],
      email: map['email'],
      roles: jsonToRolesList(map['roles']),
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
      isValid: map['is_valid'] == null ? null : map['is_valid'] == 1,
    );
  }

  /// Crée une copie du pêcheur avec des modifications
  MarketplacePecheur copyWith({
    int? id,
    String? email,
    List<String>? roles,
    String? password,
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
    String? wallet,
    String? mykeyss,
    int? telephone,
    bool? isValid,
  }) {
    return MarketplacePecheur(
      id: id ?? this.id,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      password: password ?? this.password,
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
      wallet: wallet ?? this.wallet,
      mykeyss: mykeyss ?? this.mykeyss,
      telephone: telephone ?? this.telephone,
      isValid: isValid ?? this.isValid,
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

  /// Obtient le nom complet du pêcheur
  String get fullName => '$prenom $nom';
}
