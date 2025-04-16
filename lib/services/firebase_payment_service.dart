import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';

class FirebasePaymentService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userId;
  List<Payment> _payments = [];
  bool _isLoading = false;

  // Getters
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  // Initialiser le service avec l'ID de l'utilisateur
  Future<void> init(String userId) async {
    _userId = userId;
    await loadPayments();
  }

  // Charger les paiements depuis Firestore
  Future<void> loadPayments() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('payments')
              .where('userId', isEqualTo: _userId)
              .orderBy('date', descending: true)
              .get();

      _payments =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Payment(
              id: doc.id,
              orderId: data['orderId'] ?? '',
              userId: data['userId'] ?? '',
              amount: (data['amount'] ?? 0).toDouble(),
              status: PaymentStatus.values[data['status'] ?? 0],
              method: PaymentMethod.values[data['method'] ?? 0],
              date:
                  data['date'] != null
                      ? (data['date'] as Timestamp).toDate()
                      : DateTime.now(),
              transactionId: data['transactionId'],
              notes: data['notes'],
            );
          }).toList();
    } catch (e) {
      print('Erreur lors du chargement des paiements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer un nouveau paiement
  Future<bool> createPayment(Payment payment) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = await _firestore.collection('payments').add({
        'orderId': payment.orderId,
        'userId': payment.userId,
        'amount': payment.amount,
        'status': payment.status.index,
        'method': payment.method.index,
        'date': Timestamp.fromDate(payment.date),
        'transactionId': payment.transactionId,
        'notes': payment.notes,
      });

      final newPayment = payment.copyWith(id: docRef.id);
      _payments.add(newPayment);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la création du paiement: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour le statut d'un paiement
  Future<bool> updatePaymentStatus(
    String paymentId,
    PaymentStatus newStatus,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': newStatus.index,
      });

      final index = _payments.indexWhere((payment) => payment.id == paymentId);
      if (index != -1) {
        _payments[index] = _payments[index].copyWith(status: newStatus);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut du paiement: $e');
      _isLoading = false;
      notifyListeners();
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
  List<Payment> getPaymentsByOrder(String orderId) {
    return _payments.where((payment) => payment.orderId == orderId).toList();
  }

  // Obtenir le total des paiements par statut
  Map<PaymentStatus, double> getTotalByStatus() {
    final Map<PaymentStatus, double> totals = {};
    for (var status in PaymentStatus.values) {
      totals[status] = 0;
    }

    for (var payment in _payments) {
      totals[payment.status] = (totals[payment.status] ?? 0) + payment.amount;
    }

    return totals;
  }

  // Obtenir le total des paiements par méthode
  Map<PaymentMethod, double> getTotalByMethod() {
    final Map<PaymentMethod, double> totals = {};
    for (var method in PaymentMethod.values) {
      totals[method] = 0;
    }

    for (var payment in _payments) {
      totals[payment.method] = (totals[payment.method] ?? 0) + payment.amount;
    }

    return totals;
  }

  // Vérifier si une commande est entièrement payée
  bool isOrderFullyPaid(String orderId, double orderTotal) {
    final orderPayments = getPaymentsByOrder(orderId);
    final successfulPayments = orderPayments.where(
      (p) => p.status == PaymentStatus.completed,
    );

    final totalPaid = successfulPayments.fold(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
    return totalPaid >= orderTotal;
  }
}
