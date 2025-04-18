import 'package:flutter/foundation.dart';
import '../models/marketplace_aommande.dart';
import '../models/marketplace_produitvendus.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class OrderService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  List<MarketplaceAommande> _orders = [];
  bool _isLoading = false;

  // Getters
  List<MarketplaceAommande> get orders => _orders;
  bool get isLoading => _isLoading;

  // Initialiser le service
  Future<void> init(String userId, String userType) async {
    await loadOrders(int.tryParse(userId) ?? 0, userType);
    await _notificationService.init();
  }

  // Charger les commandes depuis la base de données
  Future<void> loadOrders(int userId, String userType) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userType == 'client') {
        _orders = await _dbHelper.getOrdersByClient(userId);
      } else if (userType == 'fisherman') {
        _orders = await _dbHelper.getOrdersByFisherman(userId);
      }
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer une nouvelle commande
  Future<bool> createOrder({
    required int userId,
    required String methodeDePaiement,
    String? commentaire,
    required double totale,
    required int fournisseurId,
    required List<MarketplaceProduitVendus> produits,
  }) async {
    try {
      final now = DateTime.now();
      final newOrder = MarketplaceAommande.create(
        userId: userId,
        methodeDePaiement: methodeDePaiement,
        commentaire: commentaire,
        totale: totale,
        statutCommande: 'pending',
        fournisseurId: fournisseurId,
      );

      await _dbHelper.insertCommande(newOrder, produits);
      _orders.add(newOrder);
      notifyListeners();

      // Envoyer une notification au pêcheur
      _sendNewOrderNotification(fournisseurId, newOrder.id ?? 0);

      return true;
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      return false;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(dynamic orderId, String newStatus) async {
    try {
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return false;

      // Mettre à jour le statut de la commande
      await _dbHelper.updateOrderStatus(orderId, newStatus);

      // Mettre à jour la commande en mémoire
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = order.copyWith(
          statutCommande: newStatus,
          dateModification: DateTime.now(),
        );
        notifyListeners();
      }

      // Envoyer une notification au client
      if (order.userId != null) {
        _sendOrderStatusUpdateNotification(order.userId!, orderId, newStatus);
      }

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de la commande: $e');
      return false;
    }
  }

  // Obtenir une commande par son ID
  MarketplaceAommande? getOrderById(dynamic id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les commandes d'un client
  List<MarketplaceAommande> getOrdersByClient(int userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }

  // Obtenir les commandes d'un pêcheur
  List<MarketplaceAommande> getOrdersByFisherman(int fournisseurId) {
    return _orders
        .where((order) => order.fournisseurId == fournisseurId)
        .toList();
  }

  // Annuler une commande
  Future<bool> cancelOrder(dynamic orderId) async {
    return await updateOrderStatus(orderId, 'cancelled');
  }

  // Envoyer une notification pour une nouvelle commande
  Future<void> _sendNewOrderNotification(
    int fournisseurId,
    dynamic orderId,
  ) async {
    try {
      // Récupérer les informations du pêcheur
      final fisherman = await _dbHelper.getFishermanById(fournisseurId);
      if (fisherman == null) return;

      // Récupérer les informations de la commande
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return;

      // Envoyer la notification
      await _notificationService.showNotification(
        title: 'Nouvelle commande !',
        body: 'Vous avez reçu une nouvelle commande de ${order.totale} €.',
        payload: 'order:$orderId',
      );
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }

  // Envoyer une notification pour une mise à jour de statut de commande
  Future<void> _sendOrderStatusUpdateNotification(
    int userId,
    dynamic orderId,
    String status,
  ) async {
    try {
      // Récupérer les informations du client
      final client = await _dbHelper.getUserById(userId);
      if (client == null) return;

      // Récupérer les informations de la commande
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return;

      // Déterminer le message en fonction du statut
      String statusMessage;
      switch (status) {
        case 'confirmed':
          statusMessage = 'Votre commande a été confirmée.';
          break;
        case 'in_progress':
          statusMessage = 'Votre commande est en cours de préparation.';
          break;
        case 'delivered':
          statusMessage = 'Votre commande a été livrée.';
          break;
        case 'cancelled':
          statusMessage = 'Votre commande a été annulée.';
          break;
        default:
          statusMessage = 'Le statut de votre commande a été mis à jour.';
      }

      // Envoyer la notification
      await _notificationService.showNotification(
        title: 'Mise à jour de commande',
        body: '$statusMessage (Commande #${order.reference})',
        payload: 'order:$orderId',
      );
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }

  // Rechercher des commandes
  List<MarketplaceAommande> searchOrders(String query) {
    if (query.isEmpty) {
      return _orders;
    }

    final lowercaseQuery = query.toLowerCase();
    return _orders.where((order) {
      return order.reference.toLowerCase().contains(lowercaseQuery) ||
          (order.commentaire != null &&
              order.commentaire!.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Filtrer les commandes par statut
  List<MarketplaceAommande> filterOrdersByStatus(String status) {
    return _orders.where((order) => order.statutCommande == status).toList();
  }

  // Filtrer les commandes par période
  List<MarketplaceAommande> filterOrdersByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _orders.where((order) {
      return order.createdAt.isAfter(startDate) &&
          order.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Trier les commandes
  List<MarketplaceAommande> sortOrders(
    List<MarketplaceAommande> orders,
    String sortBy,
    bool ascending,
  ) {
    switch (sortBy) {
      case 'date':
        orders.sort((a, b) {
          return ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        });
        break;
      case 'status':
        orders.sort((a, b) {
          return ascending
              ? a.statutCommande.compareTo(b.statutCommande)
              : b.statutCommande.compareTo(a.statutCommande);
        });
        break;
      case 'amount':
        orders.sort((a, b) {
          return ascending
              ? a.totale.compareTo(b.totale)
              : b.totale.compareTo(a.totale);
        });
        break;
    }
    return orders;
  }
}
