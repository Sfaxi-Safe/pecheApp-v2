/// Représente un commentaire dans le système, correspondant à la table `marketplace_comments` dans la base de données.
class MarketplaceComments {
  final int? id;
  final String contenu;
  final DateTime dateCreation;
  final int? userId;
  final int? publicationId;
  final int? forumId;

  MarketplaceComments({
    this.id,
    required this.contenu,
    required this.dateCreation,
    this.userId,
    this.publicationId,
    this.forumId,
  });

  /// Crée un nouveau commentaire
  factory MarketplaceComments.create({
    required String contenu,
    int? userId,
    int? publicationId,
    int? forumId,
  }) {
    return MarketplaceComments(
      contenu: contenu,
      dateCreation: DateTime.now(),
      userId: userId,
      publicationId: publicationId,
      forumId: forumId,
    );
  }

  /// Convertit un commentaire en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'contenu': contenu,
      'date_creation': dateCreation.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (publicationId != null) 'publication_id': publicationId,
      if (forumId != null) 'forum_id': forumId,
    };
  }

  /// Crée un commentaire à partir d'un Map de SQLite
  factory MarketplaceComments.fromMap(Map<String, dynamic> map) {
    return MarketplaceComments(
      id: map['id'],
      contenu: map['contenu'] ?? '',
      dateCreation: map['date_creation'] != null 
          ? DateTime.parse(map['date_creation']) 
          : DateTime.now(),
      userId: map['user_id'],
      publicationId: map['publication_id'],
      forumId: map['forum_id'],
    );
  }

  /// Crée une copie du commentaire avec des modifications
  MarketplaceComments copyWith({
    int? id,
    String? contenu,
    DateTime? dateCreation,
    int? userId,
    int? publicationId,
    int? forumId,
  }) {
    return MarketplaceComments(
      id: id ?? this.id,
      contenu: contenu ?? this.contenu,
      dateCreation: dateCreation ?? this.dateCreation,
      userId: userId ?? this.userId,
      publicationId: publicationId ?? this.publicationId,
      forumId: forumId ?? this.forumId,
    );
  }
}
