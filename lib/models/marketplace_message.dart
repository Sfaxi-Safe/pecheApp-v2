/// Représente un message dans le système, correspondant à la table `marketplace_message` dans la base de données.
class MarketplaceMessage {
  final int? id;
  final String contenu;
  final DateTime dateEnvoi;
  final bool estLu;
  final int? expediteurId;
  final int? destinataireId;

  MarketplaceMessage({
    this.id,
    required this.contenu,
    required this.dateEnvoi,
    required this.estLu,
    this.expediteurId,
    this.destinataireId,
  });

  /// Crée un nouveau message
  factory MarketplaceMessage.create({
    required String contenu,
    int? expediteurId,
    int? destinataireId,
  }) {
    return MarketplaceMessage(
      contenu: contenu,
      dateEnvoi: DateTime.now(),
      estLu: false,
      expediteurId: expediteurId,
      destinataireId: destinataireId,
    );
  }

  /// Convertit un message en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'contenu': contenu,
      'date_envoi': dateEnvoi.toIso8601String(),
      'est_lu': estLu ? 1 : 0,
      if (expediteurId != null) 'expediteur_id': expediteurId,
      if (destinataireId != null) 'destinataire_id': destinataireId,
    };
  }

  /// Crée un message à partir d'un Map de SQLite
  factory MarketplaceMessage.fromMap(Map<String, dynamic> map) {
    return MarketplaceMessage(
      id: map['id'],
      contenu: map['contenu'] ?? '',
      dateEnvoi: map['date_envoi'] != null 
          ? DateTime.parse(map['date_envoi']) 
          : DateTime.now(),
      estLu: map['est_lu'] == 1,
      expediteurId: map['expediteur_id'],
      destinataireId: map['destinataire_id'],
    );
  }

  /// Crée une copie du message avec des modifications
  MarketplaceMessage copyWith({
    int? id,
    String? contenu,
    DateTime? dateEnvoi,
    bool? estLu,
    int? expediteurId,
    int? destinataireId,
  }) {
    return MarketplaceMessage(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      estLu: estLu ?? this.estLu,
      expediteurId: expediteurId ?? this.expediteurId,
      destinataireId: destinataireId ?? this.destinataireId,
    );
  }

  /// Marque le message comme lu
  MarketplaceMessage marquerCommeLu() {
    return copyWith(estLu: true);
  }
}
