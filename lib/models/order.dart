import 'package:uuid/uuid.dart';
import 'marketplace_aommande.dart';
import 'marketplace_produitvendus.dart';

/// Énumération des statuts possibles pour une commande
enum OrderStatus {
  pending,    // En Attente
  confirmed,  // Confirmée
  inProgress, // En Cours
  delivered,  // Livrée
  cancelled,  // Annulée
}

/// Classe représentant une commande dans l'application
/// Cette classe fait le pont entre le modèle SQLite et le modèle MySQL
class Order {
  final int? id;
  final int? userId;
  final String methodeDePaiement;
  final String? commentaire;
  final double totale;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime dateModification;
  final String reference;
  final int? fournisseurId;
  final List<MarketplaceProduitVendus> produits;

  Order({
    this.id,
    this.userId,
    required this.methodeDePaiement,
    this.commentaire,
    required this.totale,
    required this.status,
    required this.createdAt,
    required this.dateModification,
    required this.reference,
    this.fournisseurId,
    this.produits = const [],
  });

  /// Convertit un statut de commande en chaîne de caractères
  static String statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En Attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.inProgress:
        return 'En Cours';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
      default:
        return 'En Attente';
    }
  }

  /// Convertit une chaîne de caractères en statut de commande
  static OrderStatus stringToStatus(String statusStr) {
    switch (statusStr) {
      case 'En Attente':
        return OrderStatus.pending;
      case 'Confirmée':
        return OrderStatus.confirmed;
      case 'En Cours':
        return OrderStatus.inProgress;
      case 'Livrée':
        return OrderStatus.delivered;
      case 'Annulée':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Crée une nouvelle commande avec une référence générée
  factory Order.create({
    int? userId,
    required String methodeDePaiement,
    String? commentaire,
    required double totale,
    OrderStatus status = OrderStatus.pending,
    int? fournisseurId,
    List<MarketplaceProduitVendus> produits = const [],
  }) {
    final now = DateTime.now();
    return Order(
      userId: userId,
      methodeDePaiement: methodeDePaiement,
      commentaire: commentaire,
      totale: totale,
      status: status,
      createdAt: now,
      dateModification: now,
      reference: 'GIPP${const Uuid().v4().substring(0, 16).toUpperCase()}',
      fournisseurId: fournisseurId,
      produits: produits,
    );
  }

  /// Convertit une commande en MarketplaceAommande pour la base de données
  MarketplaceAommande toMarketplaceAommande() {
    return MarketplaceAommande(
      id: id,
      userId: userId,
      methodeDePaiement: methodeDePaiement,
      commentaire: commentaire,
      totale: totale,
      statutCommande: statusToString(status),
      createdAt: createdAt,
      dateModification: dateModification,
      reference: reference,
      fournisseurId: fournisseurId,
    );
  }

  /// Crée une commande à partir d'un MarketplaceAommande et de ses produits
  factory Order.fromMarketplaceAommande(
    MarketplaceAommande aommande, 
    List<MarketplaceProduitVendus> produits,
  ) {
    return Order(
      id: aommande.id,
      userId: aommande.userId,
      methodeDePaiement: aommande.methodeDePaiement,
      commentaire: aommande.commentaire,
      totale: aommande.totale,
      status: stringToStatus(aommande.statutCommande),
      createdAt: aommande.createdAt,
      dateModification: aommande.dateModification,
      reference: aommande.reference,
      fournisseurId: aommande.fournisseurId,
      produits: produits,
    );
  }

  /// Crée une copie de la commande avec des modifications
  Order copyWith({
    int? id,
    int? userId,
    String? methodeDePaiement,
    String? commentaire,
    double? totale,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? dateModification,
    String? reference,
    int? fournisseurId,
    List<MarketplaceProduitVendus>? produits,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      methodeDePaiement: methodeDePaiement ?? this.methodeDePaiement,
      commentaire: commentaire ?? this.commentaire,
      totale: totale ?? this.totale,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dateModification: dateModification ?? this.dateModification,
      reference: reference ?? this.reference,
      fournisseurId: fournisseurId ?? this.fournisseurId,
      produits: produits ?? this.produits,
    );
  }
}
