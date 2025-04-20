/// Représente un vétérinaire dans le système, correspondant à la table `marketplace_vitirinaire` dans la base de données.
class MarketplaceVeterinaire {
  final int? id;
  final String nom;
  final String prenom;
  final String adresse;
  final String telephone;
  final String email;
  final String? specialite;
  final int? userId;

  MarketplaceVeterinaire({
    this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.telephone,
    required this.email,
    this.specialite,
    this.userId,
  });

  /// Crée un nouveau vétérinaire
  factory MarketplaceVeterinaire.create({
    required String nom,
    required String prenom,
    required String adresse,
    required String telephone,
    required String email,
    String? specialite,
    int? userId,
  }) {
    return MarketplaceVeterinaire(
      nom: nom,
      prenom: prenom,
      adresse: adresse,
      telephone: telephone,
      email: email,
      specialite: specialite,
      userId: userId,
    );
  }

  /// Convertit un vétérinaire en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      if (specialite != null) 'specialite': specialite,
      if (userId != null) 'user_id': userId,
    };
  }

  /// Crée un vétérinaire à partir d'un Map de SQLite
  factory MarketplaceVeterinaire.fromMap(Map<String, dynamic> map) {
    return MarketplaceVeterinaire(
      id: map['id'],
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      email: map['email'] ?? '',
      specialite: map['specialite'],
      userId: map['user_id'],
    );
  }

  /// Crée une copie du vétérinaire avec des modifications
  MarketplaceVeterinaire copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? adresse,
    String? telephone,
    String? email,
    String? specialite,
    int? userId,
  }) {
    return MarketplaceVeterinaire(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      specialite: specialite ?? this.specialite,
      userId: userId ?? this.userId,
    );
  }

  /// Obtient le nom complet du vétérinaire
  String get fullName => '$prenom $nom';
}
