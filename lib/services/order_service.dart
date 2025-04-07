import 'package:flutter/material.dart';
import 'package:peche_app/models/order.dart';
import 'package:uuid/uuid.dart';

class OrderService with ChangeNotifier {
  final List<PecheOrder> _orders = [];
  
  List<PecheOrder> get orders => [..._orders];
  
  // Obtenir les commandes d'un client
  List<PecheOrder> getOrdersByClientId(String clientId) {
    return _orders.where((order) => order.clientId == clientId).toList();
  }
  
  // Obtenir les commandes pour un pêcheur
  List<PecheOrder> getOrdersByFishermanId(String fishermanId) {
    return _orders.where((order) => order.fishermanId == fishermanId).toList();
  }
  
  // Créer une nouvelle commande
  Future<PecheOrder> createOrder({
    required String clientId,
    required String fishId,
    required String fishermanId,
    required double quantity,
    required double totalPrice,
    String? deliveryAddress,
    String? notes,
  }) async {
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
    
    _orders.add(newOrder);
    notifyListeners();
    return newOrder;
  }
  
  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      final updatedOrder = PecheOrder(
        id: _orders[index].id,
        clientId: _orders[index].clientId,
        fishId: _orders[index].fishId,
        fishermanId: _orders[index].fishermanId,
        quantity: _orders[index].quantity,
        totalPrice: _orders[index].totalPrice,
        status: newStatus,
        orderDate: _orders[index].orderDate,
        deliveryDate: newStatus == OrderStatus.delivered ? DateTime.now() : _orders[index].deliveryDate,
        deliveryAddress: _orders[index].deliveryAddress,
        notes: _orders[index].notes,
      );
      
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }
  
  // Annuler une commande
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }
}

