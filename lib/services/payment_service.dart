import 'package:flutter/foundation.dart';
import '../models/marketplace_panier.dart';
import '../models/marketplace_aommande.dart';

import 'database_helper.dart';
import 'notification_service.dart';

/// Enum pour les méthodes de paiement
enum PaymentMethod { creditCard, cash, bankTransfer, paypal }

/// Enum pour les statuts de paiement
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

/// Classe pour les cartes de crédit
class CreditCard {
  final String number;
  final String holderName;
  final String expiryDate;
  final String cvv;

  CreditCard({
    required this.number,
    required this.holderName,
    required this.expiryDate,
    required this.cvv,
  });
}

class PaymentService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  List<MarketplacePanier> _payments = [];
  bool _isLoading = false;

  // Getters
  List<MarketplacePanier> get payments => _payments;
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
      final userIdInt = int.tryParse(userId);
      if (userIdInt != null) {
        _payments = await _dbHelper.getPaniersByUser(userIdInt);
      }
    } catch (e) {
      print('Erreur lors du chargement des paiements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer un nouveau paiement
  Future<bool> createPayment({
    required dynamic orderId,
    required String userId,
    required double amount,
    required PaymentMethod method,
    String? transactionId,
    String? notes,
  }) async {
    try {
      final userIdInt = int.tryParse(userId);
      if (userIdInt == null) return false;

      // Créer un nouveau panier (utilisé comme paiement)
      final newPayment = MarketplacePanier.create(
        produitId: 0, // Pas de produit spécifique pour un paiement
        userId: userIdInt,
        quantite: 1, // Quantité par défaut
      );

      // Insérer le panier dans la base de données
      final paymentId = await _dbHelper.insertPanier(newPayment);
      if (paymentId > 0) {
        // Créer un nouveau panier avec l'ID généré
        final savedPayment = newPayment.copyWith(id: paymentId);
        _payments.add(savedPayment);
      }

      // Mettre à jour le statut de la commande
      // Note: Dans une implémentation réelle, nous mettrions à jour le statut de la commande
      // Pour l'instant, nous supposons que la commande est confirmée

      // Envoyer une notification de confirmation de paiement
      await _notificationService.showNotification(
        title: 'Paiement confirmé',
        body:
            'Votre paiement de ${amount.toStringAsFixed(2)} € a été confirmé.',
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
  Future<bool> updatePaymentStatus(
    String paymentIdStr,
    PaymentStatus newStatus,
  ) async {
    try {
      final paymentId = int.tryParse(paymentIdStr);
      if (paymentId == null) return false;

      // Récupérer le panier (paiement)
      final payment = await _dbHelper.getPanierById(paymentId);
      if (payment == null) return false;

      // Mettre à jour le panier
      // Note: Dans le nouveau modèle, nous n'avons pas de statut de paiement
      // Nous pourrions ajouter un champ dans la base de données pour cela

      // Mettre à jour la liste locale
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = payment;
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut du paiement: $e');
      return false;
    }
  }

  // Obtenir un paiement par son ID
  MarketplacePanier? getPaymentById(String idStr) {
    try {
      final id = int.tryParse(idStr);
      if (id == null) return null;

      return _payments.firstWhere((payment) => payment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les paiements pour une commande
  Future<List<MarketplacePanier>> getPaymentsForOrder(int orderId) async {
    try {
      // Dans le nouveau modèle, nous n'avons pas de relation directe entre panier et commande
      // Nous pourrions ajouter un champ dans la base de données pour cela
      return [];
    } catch (e) {
      print(
        'Erreur lors de la récupération des paiements pour la commande: $e',
      );
      return [];
    }
  }

  // Vérifier si une commande a été payée
  Future<bool> isOrderPaid(int orderId) async {
    try {
      // Dans le nouveau modèle, nous vérifions le statut de la commande directement
      final order = await _dbHelper.getOrderById(orderId);
      if (order == null) return false;

      // Convertir l'ordre en MarketplaceAommande pour accéder à statutCommande
      final commande = order as MarketplaceAommande;

      // Si le statut est confirmed, in_progress, delivered, alors la commande est payée
      return commande.statutCommande == 'confirmed' ||
          commande.statutCommande == 'in_progress' ||
          commande.statutCommande == 'delivered';
    } catch (e) {
      print('Erreur lors de la vérification du paiement de la commande: $e');
      return false;
    }
  }

  // Simuler un paiement par carte de crédit
  Future<bool> processCardPayment({
    required dynamic orderId,
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
    required dynamic orderId,
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
