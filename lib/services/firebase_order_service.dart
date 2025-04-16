import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';

class FirebaseOrderService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PecheOrder> _orders = [];
  bool _isLoading = false;
  String? _userId;
  String? _userType;

  // Getters
  List<PecheOrder> get orders => _orders;
  bool get isLoading => _isLoading;

  // Initialiser le service avec l'ID de l'utilisateur et son type
  Future<void> init(String userId, String userType) async {
    _userId = userId;
    _userType = userType;
    await loadOrders();
  }

  // Charger les commandes depuis Firestore
  Future<void> loadOrders() async {
    if (_userId == null || _userType == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final field = _userType == 'client' ? 'clientId' : 'fishermanId';
      final snapshot = await _firestore
          .collection('orders')
          .where(field, isEqualTo: _userId)
          .get();
      
      _orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return PecheOrder(
          id: doc.id,
          clientId: data['clientId'] ?? '',
          fishId: data['fishId'] ?? '',
          fishermanId: data['fishermanId'] ?? '',
          quantity: (data['quantity'] ?? 0).toDouble(),
          totalPrice: (data['totalPrice'] ?? 0).toDouble(),
          status: OrderStatus.values[data['status'] ?? 0],
          orderDate: data['orderDate'] != null 
            ? (data['orderDate'] as Timestamp).toDate() 
            : DateTime.now(),
          deliveryDate: data['deliveryDate'] != null 
            ? (data['deliveryDate'] as Timestamp).toDate() 
            : null,
          deliveryAddress: data['deliveryAddress'],
          notes: data['notes'],
        );
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer une nouvelle commande
  Future<bool> createOrder(PecheOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = await _firestore.collection('orders').add({
        'clientId': order.clientId,
        'fishId': order.fishId,
        'fishermanId': order.fishermanId,
        'quantity': order.quantity,
        'totalPrice': order.totalPrice,
        'status': order.status.index,
        'orderDate': Timestamp.fromDate(order.orderDate),
        'deliveryDate': order.deliveryDate != null 
          ? Timestamp.fromDate(order.deliveryDate!) 
          : null,
        'deliveryAddress': order.deliveryAddress,
        'notes': order.notes,
      });
      
      final newOrder = order.copyWith(id: docRef.id);
      _orders.add(newOrder);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus.index,
        if (newStatus == OrderStatus.delivered) 
          'deliveryDate': Timestamp.now(),
      });
      
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(
          status: newStatus,
          deliveryDate: newStatus == OrderStatus.delivered 
            ? DateTime.now() 
            : _orders[index].deliveryDate,
        );
        _orders[index] = updatedOrder;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut de la commande: $e');
      _isLoading = false;
      notifyListeners();
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

  // Obtenir les commandes par statut
  List<PecheOrder> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Obtenir le nombre de commandes par statut
  Map<OrderStatus, int> getOrderCountsByStatus() {
    final Map<OrderStatus, int> counts = {};
    for (var status in OrderStatus.values) {
      counts[status] = 0;
    }
    
    for (var order in _orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    
    return counts;
  }

  // Annuler une commande
  Future<bool> cancelOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // Confirmer une commande
  Future<bool> confirmOrder(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  // Marquer une commande comme en cours
  Future<bool> markOrderInProgress(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.inProgress);
  }

  // Marquer une commande comme livrée
  Future<bool> markOrderDelivered(String orderId) async {
    return await updateOrderStatus(orderId, OrderStatus.delivered);
  }
}
