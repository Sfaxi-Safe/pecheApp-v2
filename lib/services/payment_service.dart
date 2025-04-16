import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/order.dart';
import 'database_helper.dart';
import 'notification_service.dart';

class PaymentService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  List<Payment> _payments = [];
  bool _isLoading = false;

  // Getters
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  // Initialiser le service
  Future<void> init(String userId) async {
    await loadPayments(userId);
  }

  // Charger les paiements depuis la base de données
  Future<void> loadPayments(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _payments = await _dbHelper.getPaymentsByUser(userId);
    } catch (e) {
      print('Erreur lors du chargement des paiements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer un nouveau paiement
  Future<bool> createPayment({
    required String orderId,
    required String userId,
    required double amount,
    required PaymentMethod method,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final newPayment = Payment.create(
        orderId: orderId,
        userId: userId,
        amount: amount,
        method: method,
        transactionId: transactionId,
        notes: notes,
      );

      await _dbHelper.insertPayment(newPayment);
      _payments.add(newPayment);
      
      // Mettre à jour le statut de la commande si le paiement est réussi
      final order = await _dbHelper.getOrderById(orderId);
      if (order != null && order.status == OrderStatus.pending) {
        final updatedOrder = order.copyWith(status: OrderStatus.confirmed);
        await _dbHelper.updateOrder(updatedOrder);
      }
      
      // Envoyer une notification de confirmation de paiement
      await _notificationService.showNotification(
        title: 'Paiement confirmé',
        body: 'Votre paiement de ${amount.toStringAsFixed(2)} € a été confirmé.',
        payload: 'payment:${newPayment.id}',
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la création du paiement: $e');
      return false;
    }
  }

  // Mettre à jour le statut d'un paiement
  Future<bool> updatePaymentStatus(String paymentId, PaymentStatus newStatus) async {
    try {
      final payment = await _dbHelper.getPaymentById(paymentId);
      if (payment == null) return false;

      final updatedPayment = payment.copyWith(status: newStatus);
      await _dbHelper.updatePayment(updatedPayment);

      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut du paiement: $e');
      return false;
    }
  }

  // Obtenir un paiement par son ID
  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les paiements pour une commande
  Future<List<Payment>> getPaymentsForOrder(String orderId) async {
    try {
      return await _dbHelper.getPaymentsByOrder(orderId);
    } catch (e) {
      print('Erreur lors de la récupération des paiements pour la commande: $e');
      return [];
    }
  }

  // Vérifier si une commande a été payée
  Future<bool> isOrderPaid(String orderId) async {
    try {
      final payments = await _dbHelper.getPaymentsByOrder(orderId);
      return payments.any((payment) => 
        payment.status == PaymentStatus.completed || 
        payment.status == PaymentStatus.processing
      );
    } catch (e) {
      print('Erreur lors de la vérification du paiement de la commande: $e');
      return false;
    }
  }

  // Simuler un paiement par carte de crédit
  Future<bool> processCardPayment({
    required String orderId,
    required String userId,
    required double amount,
    required CreditCard creditCard,
    String? notes,
  }) async {
    try {
      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));
      
      // Simuler une validation de carte (dans une vraie application, cela serait fait par un service de paiement)
      if (creditCard.number.length < 16 || 
          creditCard.cvv.length < 3 || 
          creditCard.expiryDate.isEmpty || 
          creditCard.holderName.isEmpty) {
        return false;
      }
      
      // Créer le paiement
      return await createPayment(
        orderId: orderId,
        userId: userId,
        amount: amount,
        method: PaymentMethod.creditCard,
        transactionId: 'CARD_${DateTime.now().millisecondsSinceEpoch}',
        notes: notes,
      );
    } catch (e) {
      print('Erreur lors du traitement du paiement par carte: $e');
      return false;
    }
  }

  // Simuler un paiement en espèces
  Future<bool> processCashPayment({
    required String orderId,
    required String userId,
    required double amount,
    String? notes,
  }) async {
    try {
      // Créer le paiement
      return await createPayment(
        orderId: orderId,
        userId: userId,
        amount: amount,
        method: PaymentMethod.cash,
        notes: notes ?? 'Paiement en espèces à la livraison',
      );
    } catch (e) {
      print('Erreur lors du traitement du paiement en espèces: $e');
      return false;
    }
  }
}
