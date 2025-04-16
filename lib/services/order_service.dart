import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class OrderService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  List<PecheOrder> _orders = [];
  bool _isLoading = false;

  // Getters
  List<PecheOrder> get orders => _orders;
  bool get isLoading => _isLoading;

  // Initialiser le service
  Future<void> init(String userId, String userType) async {
    await loadOrders(userId, userType);
    await _notificationService.init();
  }

  // Charger les commandes depuis la base de données
  Future<void> loadOrders(String userId, String userType) async {
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
    required String clientId,
    required String fishId,
    required String fishermanId,
    required double quantity,
    required double totalPrice,
    String? deliveryAddress,
    String? notes,
  }) async {
    try {
      final newOrder = PecheOrder(
        id: const Uuid().v4(),
        clientId: clientId,
        fishId: fishId,
        fishermanId: fishermanId,
        quantity: quantity,
        totalPrice: totalPrice,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );

      await _dbHelper.insertOrder(newOrder);
      _orders.add(newOrder);
      notifyListeners();
      
      // Envoyer une notification au pêcheur
      _sendNewOrderNotification(fishermanId, newOrder.id);
      
      return true;
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      return false;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return false;

      final updatedOrder = PecheOrder(
        id: order.id,
        clientId: order.clientId,
        fishId: order.fishId,
        fishermanId: order.fishermanId,
        quantity: order.quantity,
        totalPrice: order.totalPrice,
        status: newStatus,
        orderDate: order.orderDate,
        deliveryDate: newStatus == OrderStatus.delivered ? DateTime.now() : order.deliveryDate,
        deliveryAddress: order.deliveryAddress,
        notes: order.notes,
      );

      await _dbHelper.updateOrder(updatedOrder);

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
      
      // Envoyer une notification au client
      _sendOrderStatusUpdateNotification(order.clientId, orderId, newStatus);

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de la commande: $e');
      return false;
    }
  }

  // Obtenir une commande par son ID
  PecheOrder? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les commandes d'un client
  List<PecheOrder> getOrdersByClient(String clientId) {
    return _orders.where((order) => order.clientId == clientId).toList();
  }

  // Obtenir les commandes d'un pêcheur
  List<PecheOrder> getOrdersByFisherman(String fishermanId) {
    return _orders.where((order) => order.fishermanId == fishermanId).toList();
  }

  // Annuler une commande
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.cancelled);
  }
  
  // Envoyer une notification pour une nouvelle commande
  Future<void> _sendNewOrderNotification(String fishermanId, String orderId) async {
    try {
      // Récupérer les informations du pêcheur
      final fisherman = await _dbHelper.getFishermanById(fishermanId);
      if (fisherman == null) return;
      
      // Récupérer les informations de la commande
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return;
      
      // Récupérer les informations du poisson
      final fish = await _dbHelper.getFishById(order.fishId);
      if (fish == null) return;
      
      // Envoyer la notification
      await _notificationService.showNotification(
        title: 'Nouvelle commande !',
        body: 'Vous avez reçu une commande pour ${order.quantity} kg de ${fish.species}.',
        payload: 'order:$orderId',
      );
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }
  
  // Envoyer une notification pour une mise à jour de statut de commande
  Future<void> _sendOrderStatusUpdateNotification(String clientId, String orderId, OrderStatus status) async {
    try {
      // Récupérer les informations du client
      final client = await _dbHelper.getUserById(clientId);
      if (client == null) return;
      
      // Récupérer les informations de la commande
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return;
      
      // Récupérer les informations du poisson
      final fish = await _dbHelper.getFishById(order.fishId);
      if (fish == null) return;
      
      // Déterminer le message en fonction du statut
      String statusMessage;
      switch (status) {
        case OrderStatus.confirmed:
          statusMessage = 'Votre commande a été confirmée.';
          break;
        case OrderStatus.inProgress:
          statusMessage = 'Votre commande est en cours de préparation.';
          break;
        case OrderStatus.delivered:
          statusMessage = 'Votre commande a été livrée.';
          break;
        case OrderStatus.cancelled:
          statusMessage = 'Votre commande a été annulée.';
          break;
        default:
          statusMessage = 'Le statut de votre commande a été mis à jour.';
      }
      
      // Envoyer la notification
      await _notificationService.showNotification(
        title: 'Mise à jour de commande',
        body: '$statusMessage (${fish.species})',
        payload: 'order:$orderId',
      );
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification: $e');
    }
  }
}
