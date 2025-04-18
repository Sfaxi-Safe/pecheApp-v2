import 'package:uuid/uuid.dart';

/// Représente une commande dans le système, correspondant à la table `marketplace_aommande` dans la base de données.
class MarketplaceAommande {
  final int? id;
  final int? userId;
  final String methodeDePaiement;
  final String? commentaire;
  final double totale;
  final String statutCommande;
  final DateTime createdAt;
  final DateTime dateModification;
  final String reference;
  final int? fournisseurId;

  MarketplaceAommande({
    this.id,
    this.userId,
    required this.methodeDePaiement,
    this.commentaire,
    required this.totale,
    required this.statutCommande,
    required this.createdAt,
    required this.dateModification,
    required this.reference,
    this.fournisseurId,
  });

  /// Crée une nouvelle commande avec une référence générée
  factory MarketplaceAommande.create({
    int? userId,
    required String methodeDePaiement,
    String? commentaire,
    required double totale,
    String statutCommande = 'En Attente',
    int? fournisseurId,
  }) {
    final now = DateTime.now();
    return MarketplaceAommande(
      userId: userId,
      methodeDePaiement: methodeDePaiement,
      commentaire: commentaire,
      totale: totale,
      statutCommande: statutCommande,
      createdAt: now,
      dateModification: now,
      reference: 'GIPP${const Uuid().v4().substring(0, 16).toUpperCase()}',
      fournisseurId: fournisseurId,
    );
  }

  /// Convertit une commande en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'methode_de_paiement': methodeDePaiement,
      'commentaire': commentaire,
      'totale': totale,
      'statut_commande': statutCommande,
      'created_at': createdAt.toIso8601String(),
      'date_modification': dateModification.toIso8601String(),
      'reference': reference,
      'fournisseur_id': fournisseurId,
    };
  }

  /// Crée une commande à partir d'un Map de SQLite
  factory MarketplaceAommande.fromMap(Map<String, dynamic> map) {
    return MarketplaceAommande(
      id: map['id'],
      userId: map['user_id'],
      methodeDePaiement: map['methode_de_paiement'],
      commentaire: map['commentaire'],
      totale: map['totale'] is int ? (map['totale'] as int).toDouble() : map['totale'],
      statutCommande: map['statut_commande'],
      createdAt: DateTime.parse(map['created_at']),
      dateModification: DateTime.parse(map['date_modification']),
      reference: map['reference'],
      fournisseurId: map['fournisseur_id'],
    );
  }

  /// Crée une copie de la commande avec des modifications
  MarketplaceAommande copyWith({
    int? id,
    int? userId,
    String? methodeDePaiement,
    String? commentaire,
    double? totale,
    String? statutCommande,
    DateTime? createdAt,
    DateTime? dateModification,
    String? reference,
    int? fournisseurId,
  }) {
    return MarketplaceAommande(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      methodeDePaiement: methodeDePaiement ?? this.methodeDePaiement,
      commentaire: commentaire ?? this.commentaire,
      totale: totale ?? this.totale,
      statutCommande: statutCommande ?? this.statutCommande,
      createdAt: createdAt ?? this.createdAt,
      dateModification: dateModification ?? this.dateModification,
      reference: reference ?? this.reference,
      fournisseurId: fournisseurId ?? this.fournisseurId,
    );
  }
}
