/// Représente une entreprise dans le système, correspondant à la table `marketplace_entreprise` dans la base de données.
class MarketplaceEntreprise {
  final int? id;
  final String nom;
  final String adresse;
  final String telephone;
  final String email;
  final String? siteWeb;
  final String? logo;
  final String? description;
  final int? userId;

  MarketplaceEntreprise({
    this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    required this.email,
    this.siteWeb,
    this.logo,
    this.description,
    this.userId,
  });

  /// Crée une nouvelle entreprise
  factory MarketplaceEntreprise.create({
    required String nom,
    required String adresse,
    required String telephone,
    required String email,
    String? siteWeb,
    String? logo,
    String? description,
    int? userId,
  }) {
    return MarketplaceEntreprise(
      nom: nom,
      adresse: adresse,
      telephone: telephone,
      email: email,
      siteWeb: siteWeb,
      logo: logo,
      description: description,
      userId: userId,
    );
  }

  /// Convertit une entreprise en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      if (siteWeb != null) 'site_web': siteWeb,
      if (logo != null) 'logo': logo,
      if (description != null) 'description': description,
      if (userId != null) 'user_id': userId,
    };
  }

  /// Crée une entreprise à partir d'un Map de SQLite
  factory MarketplaceEntreprise.fromMap(Map<String, dynamic> map) {
    return MarketplaceEntreprise(
      id: map['id'],
      nom: map['nom'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      email: map['email'] ?? '',
      siteWeb: map['site_web'],
      logo: map['logo'],
      description: map['description'],
      userId: map['user_id'],
    );
  }

  /// Crée une copie de l'entreprise avec des modifications
  MarketplaceEntreprise copyWith({
    int? id,
    String? nom,
    String? adresse,
    String? telephone,
    String? email,
    String? siteWeb,
    String? logo,
    String? description,
    int? userId,
  }) {
    return MarketplaceEntreprise(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      siteWeb: siteWeb ?? this.siteWeb,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }
}
