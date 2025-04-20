/// Représente un contact dans le système, correspondant à la table `marketplace_contact` dans la base de données.
class MarketplaceContact {
  final int? id;
  final String nom;
  final String email;
  final String sujet;
  final String message;
  final DateTime dateEnvoi;
  final bool estLu;

  MarketplaceContact({
    this.id,
    required this.nom,
    required this.email,
    required this.sujet,
    required this.message,
    required this.dateEnvoi,
    required this.estLu,
  });

  /// Crée un nouveau contact
  factory MarketplaceContact.create({
    required String nom,
    required String email,
    required String sujet,
    required String message,
  }) {
    return MarketplaceContact(
      nom: nom,
      email: email,
      sujet: sujet,
      message: message,
      dateEnvoi: DateTime.now(),
      estLu: false,
    );
  }

  /// Convertit un contact en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'email': email,
      'sujet': sujet,
      'message': message,
      'date_envoi': dateEnvoi.toIso8601String(),
      'est_lu': estLu ? 1 : 0,
    };
  }

  /// Crée un contact à partir d'un Map de SQLite
  factory MarketplaceContact.fromMap(Map<String, dynamic> map) {
    return MarketplaceContact(
      id: map['id'],
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      sujet: map['sujet'] ?? '',
      message: map['message'] ?? '',
      dateEnvoi: map['date_envoi'] != null 
          ? DateTime.parse(map['date_envoi']) 
          : DateTime.now(),
      estLu: map['est_lu'] == 1,
    );
  }

  /// Crée une copie du contact avec des modifications
  MarketplaceContact copyWith({
    int? id,
    String? nom,
    String? email,
    String? sujet,
    String? message,
    DateTime? dateEnvoi,
    bool? estLu,
  }) {
    return MarketplaceContact(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      sujet: sujet ?? this.sujet,
      message: message ?? this.message,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      estLu: estLu ?? this.estLu,
    );
  }

  /// Marque le contact comme lu
  MarketplaceContact marquerCommeLu() {
    return copyWith(estLu: true);
  }
}
