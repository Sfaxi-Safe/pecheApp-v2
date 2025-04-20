import 'package:flutter/foundation.dart';
import '../models/marketplace_panier.dart';
import '../models/marketplace_aommande.dart';
import '../models/marketplace_produitvendus.dart';

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
  List<MarketplacePanier> _cartItems = [];
  bool _isLoading = false;

  // Getters
  List<MarketplacePanier> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  // Initialiser le service
  Future<void> init(int userId) async {
    await loadCartItems(userId);
  }

  // Charger les articles du panier depuis la base de données
  Future<void> loadCartItems(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await _dbHelper.getPaniersByUser(userId);
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter un article au panier
  Future<bool> addToCart({
    required int userId,
    required int produitId,
    required int quantite,
  }) async {
    try {
      // Vérifier si l'article est déjà dans le panier
      final existingItem = _cartItems.firstWhere(
        (item) => item.produitId == produitId && item.userId == userId,
        orElse: () => MarketplacePanier(
          produitId: -1,
          userId: -1,
          quantite: 0,
          dateAjout: DateTime.now(),
        ),
      );

      if (existingItem.produitId != -1) {
        // Mettre à jour la quantité
        final updatedItem = existingItem.updateQuantite(
          existingItem.quantite + quantite,
        );
        await _dbHelper.updatePanier(updatedItem);
        
        // Mettre à jour la liste locale
        final index = _cartItems.indexWhere((item) => item.id == existingItem.id);
        if (index != -1) {
          _cartItems[index] = updatedItem;
        }
      } else {
        // Créer un nouvel article
        final newItem = MarketplacePanier.create(
          userId: userId,
          produitId: produitId,
          quantite: quantite,
        );
        
        final id = await _dbHelper.insertPanier(newItem);
        if (id > 0) {
          _cartItems.add(newItem.copyWith(id: id));
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      return false;
    }
  }

  // Mettre à jour la quantité d'un article du panier
  Future<bool> updateCartItemQuantity(int itemId, int newQuantity) async {
    try {
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index == -1) return false;
      
      final updatedItem = _cartItems[index].updateQuantite(newQuantity);
      await _dbHelper.updatePanier(updatedItem);
      
      _cartItems[index] = updatedItem;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
      return false;
    }
  }

  // Supprimer un article du panier
  Future<bool> removeFromCart(int itemId) async {
    try {
      await _dbHelper.deletePanier(itemId);
      _cartItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'article du panier: $e');
      return false;
    }
  }

  // Vider le panier
  Future<bool> clearCart(int userId) async {
    try {
      for (var item in _cartItems.where((item) => item.userId == userId)) {
        if (item.id != null) {
          await _dbHelper.deletePanier(item.id!);
        }
      }
      
      _cartItems.removeWhere((item) => item.userId == userId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors du vidage du panier: $e');
      return false;
    }
  }

  // Calculer le total du panier
  Future<double> calculateCartTotal(int userId) async {
    try {
      double total = 0.0;
      
      for (var item in _cartItems.where((item) => item.userId == userId)) {
        if (item.produitId != null) {
          final produit = await _dbHelper.getProduitById(item.produitId);
          if (produit != null) {
            total += produit.prix * item.quantite;
          }
        }
      }
      
      return total;
    } catch (e) {
      print('Erreur lors du calcul du total du panier: $e');
      return 0.0;
    }
  }

  // Créer une commande à partir du panier
  Future<bool> createOrderFromCart({
    required int userId,
    required String methodeDePaiement,
    String? commentaire,
    required int fournisseurId,
  }) async {
    try {
      // Calculer le total
      final total = await calculateCartTotal(userId);
      
      // Créer la commande
      final commande = MarketplaceAommande.create(
        userId: userId,
        methodeDePaiement: methodeDePaiement,
        commentaire: commentaire,
        totale: total,
        statutCommande: 'En Attente',
        fournisseurId: fournisseurId,
      );
      
      // Créer les produits vendus
      List<MarketplaceProduitVendus> produitsVendus = [];
      
      for (var item in _cartItems.where((item) => item.userId == userId)) {
        if (item.produitId != null) {
          final produit = await _dbHelper.getProduitById(item.produitId);
          if (produit != null) {
            produitsVendus.add(
              MarketplaceProduitVendus.create(
                produitId: item.produitId,
                quantite: item.quantite,
                prix: produit.prix,
              ),
            );
          }
        }
      }
      
      // Insérer la commande et les produits vendus
      final commandeId = await _dbHelper.insertCommande(commande, produitsVendus);
      
      if (commandeId > 0) {
        // Vider le panier
        await clearCart(userId);
        
        // Envoyer une notification
        await _notificationService.showNotification(
          title: 'Commande confirmée',
          body: 'Votre commande de ${total.toStringAsFixed(2)} € a été confirmée.',
          payload: 'order:$commandeId',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      return false;
    }
  }

  // Traiter un paiement par carte de crédit
  Future<bool> processCardPayment({
    required int userId,
    required CreditCard creditCard,
    String? notes,
  }) async {
    try {
      // Simuler un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler une validation de carte
      if (creditCard.number.length < 16 ||
          creditCard.cvv.length < 3 ||
          creditCard.expiryDate.isEmpty ||
          creditCard.holderName.isEmpty) {
        return false;
      }

      // Le paiement est considéré comme réussi
      return true;
    } catch (e) {
      print('Erreur lors du traitement du paiement par carte: $e');
      return false;
    }
  }

  // Simuler un paiement en espèces
  Future<bool> processCashPayment() async {
    try {
      // Le paiement en espèces est toujours considéré comme réussi
      return true;
    } catch (e) {
      print('Erreur lors du traitement du paiement en espèces: $e');
      return false;
    }
  }
}
