/// Représente un avis dans le système, correspondant à la table `marketplace_avis` dans la base de données.
class MarketplaceAvis {
  final int? id;
  final int note;
  final String commentaire;
  final DateTime dateCreation;
  final int? userId;
  final int? produitId;
  final int? pecheurId;

  MarketplaceAvis({
    this.id,
    required this.note,
    required this.commentaire,
    required this.dateCreation,
    this.userId,
    this.produitId,
    this.pecheurId,
  });

  /// Crée un nouvel avis
  factory MarketplaceAvis.create({
    required int note,
    required String commentaire,
    int? userId,
    int? produitId,
    int? pecheurId,
  }) {
    // Validation de la note
    if (note < 1 || note > 5) {
      throw ArgumentError('La note doit être comprise entre 1 et 5');
    }

    return MarketplaceAvis(
      note: note,
      commentaire: commentaire,
      dateCreation: DateTime.now(),
      userId: userId,
      produitId: produitId,
      pecheurId: pecheurId,
    );
  }

  /// Convertit un avis en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'note': note,
      'commentaire': commentaire,
      'date_creation': dateCreation.toIso8601String(),
      if (userId != null) 'user_id': userId,
      if (produitId != null) 'produit_id': produitId,
      if (pecheurId != null) 'pecheur_id': pecheurId,
    };
  }

  /// Crée un avis à partir d'un Map de SQLite
  factory MarketplaceAvis.fromMap(Map<String, dynamic> map) {
    return MarketplaceAvis(
      id: map['id'],
      note: map['note'] ?? 0,
      commentaire: map['commentaire'] ?? '',
      dateCreation: map['date_creation'] != null 
          ? DateTime.parse(map['date_creation']) 
          : DateTime.now(),
      userId: map['user_id'],
      produitId: map['produit_id'],
      pecheurId: map['pecheur_id'],
    );
  }

  /// Crée une copie de l'avis avec des modifications
  MarketplaceAvis copyWith({
    int? id,
    int? note,
    String? commentaire,
    DateTime? dateCreation,
    int? userId,
    int? produitId,
    int? pecheurId,
  }) {
    return MarketplaceAvis(
      id: id ?? this.id,
      note: note ?? this.note,
      commentaire: commentaire ?? this.commentaire,
      dateCreation: dateCreation ?? this.dateCreation,
      userId: userId ?? this.userId,
      produitId: produitId ?? this.produitId,
      pecheurId: pecheurId ?? this.pecheurId,
    );
  }
}
