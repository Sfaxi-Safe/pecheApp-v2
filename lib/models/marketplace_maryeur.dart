/// Représente un maryeur dans le système, correspondant à la table `marketplace_maryeur` dans la base de données.
class MarketplaceMaryeur {
  final int? id;
  final String nom;
  final String prenom;
  final String adresse;
  final String telephone;
  final String email;
  final int? userId;

  MarketplaceMaryeur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.telephone,
    required this.email,
    this.userId,
  });

  /// Crée un nouveau maryeur
  factory MarketplaceMaryeur.create({
    required String nom,
    required String prenom,
    required String adresse,
    required String telephone,
    required String email,
    int? userId,
  }) {
    return MarketplaceMaryeur(
      nom: nom,
      prenom: prenom,
      adresse: adresse,
      telephone: telephone,
      email: email,
      userId: userId,
    );
  }

  /// Convertit un maryeur en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      if (userId != null) 'user_id': userId,
    };
  }

  /// Crée un maryeur à partir d'un Map de SQLite
  factory MarketplaceMaryeur.fromMap(Map<String, dynamic> map) {
    return MarketplaceMaryeur(
      id: map['id'],
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      email: map['email'] ?? '',
      userId: map['user_id'],
    );
  }

  /// Crée une copie du maryeur avec des modifications
  MarketplaceMaryeur copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? adresse,
    String? telephone,
    String? email,
    int? userId,
  }) {
    return MarketplaceMaryeur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      userId: userId ?? this.userId,
    );
  }

  /// Obtient le nom complet du maryeur
  String get fullName => '$prenom $nom';
}
