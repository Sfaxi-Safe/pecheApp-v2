import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_produit.dart';
import '../models/marketplace_aommande.dart';
import '../models/marketplace_produitvendus.dart';
import '../models/marketplace_prise.dart';
import 'fish_service.dart';
import 'database_helper.dart';

class StatisticsService with ChangeNotifier {
  final FishService _fishService;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;
  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  int _totalProducts = 0;
  Map<String, int> _ordersByStatus = {};
  Map<String, double> _revenueByMonth = {};
  Map<String, int> _quantityByProduct = {};
  Map<String, double> _revenueByProduct = {};

  // Getters
  bool get isLoading => _isLoading;
  int get totalOrders => _totalOrders;
  double get totalRevenue => _totalRevenue;
  int get totalProducts => _totalProducts;
  Map<String, int> get ordersByStatus => _ordersByStatus;
  Map<String, double> get revenueByMonth => _revenueByMonth;
  Map<String, int> get quantityByProduct => _quantityByProduct;
  Map<String, double> get revenueByProduct => _revenueByProduct;

  StatisticsService(this._fishService);

  // Statistiques pour les pêcheurs

  // Obtenir le nombre de captures pour un pêcheur ce mois-ci
  Future<int> getCapturesThisMonth(int pecheurId) async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    try {
      final prises = await _dbHelper.getPrisesByPecheur(pecheurId);
      return prises.where((prise) {
        return prise.datePeche.isAfter(firstDayOfMonth) ||
               prise.datePeche.isAtSameMomentAs(firstDayOfMonth);
      }).length;
    } catch (e) {
      print('Erreur lors du calcul des captures du mois: $e');
      return 0;
    }
  }

  // Obtenir le nombre d'espèces différentes capturées par un pêcheur
  Future<int> getDifferentSpeciesCount(int pecheurId) async {
    try {
      final prises = await _dbHelper.getPrisesByPecheur(pecheurId);
      final species = prises.map((prise) => prise.espece).toSet();
      return species.length;
    } catch (e) {
      print('Erreur lors du calcul des espèces différentes: $e');
      return 0;
    }
  }

  // Obtenir le poids total des captures d'un pêcheur
   Future<double> getTotalWeight(int pecheurId) async {
    try {
      final prises = await _dbHelper.getPrisesByPecheur(pecheurId);

      return prises.fold<double>(0.0, (double sum, prise) {
        final poids = prise.poids;
        return sum + poids;
      });
    } catch (e) {
      print('Erreur lors du calcul du poids total: $e');
      return 0.0;
    }
  }


  // Obtenir la dernière capture d'un pêcheur
  Future<MarketplacePrise?> getLastCapture(int pecheurId) async {
    try {
      final prises = await _dbHelper.getPrisesByPecheur(pecheurId);
      if (prises.isEmpty) {
        return null;
      }

      // Trier les prises par date de capture (du plus récent au plus ancien)
      prises.sort((a, b) => b.datePeche.compareTo(a.datePeche));
      
      // Charger les images pour la dernière prise
      final lastPrise = prises.first;
      if (lastPrise.id != null) {
        final images = await _dbHelper.getImagesByPriseId(lastPrise.id!);
        return lastPrise.copyWith(images: images);
      }
      
      return lastPrise;
    } catch (e) {
      print('Erreur lors de la récupération de la dernière capture: $e');
      return null;
    }
  }

  // Statistiques pour les ventes

  // Charger toutes les statistiques
  Future<void> loadAllStatistics(int pecheurId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Récupérer toutes les commandes du pêcheur
      final orders = await _dbHelper.getOrdersByFisherman(pecheurId);

      // Réinitialiser les statistiques
      _totalOrders = 0;
      _totalRevenue = 0.0;
      _totalProducts = 0;
      _ordersByStatus = {};
      _revenueByMonth = {};
      _quantityByProduct = {};
      _revenueByProduct = {};

      // Calculer les statistiques
      for (var order in orders) {
        _totalOrders++;
        _totalRevenue += order.totale;

        // Statistiques par statut
        final statusStr = order.statutCommande;
        _ordersByStatus[statusStr] = (_ordersByStatus[statusStr] ?? 0) + 1;

        // Statistiques par mois
        final createdAt = order.createdAt;
        final monthYear = DateFormat('MM-yyyy').format(createdAt);
        _revenueByMonth[monthYear] = (_revenueByMonth[monthYear] ?? 0.0) + order.totale;

        // Statistiques par produit
        if (order.id != null) {
          final produits = await _dbHelper.getProduitVendusByCommandeId(order.id!);
          _totalProducts += produits.length;
          
          for (var produit in produits) {
            if (produit.produitId != null) {
              final fish = await _dbHelper.getProduitById(produit.produitId);
              if (fish != null) {
                final productName = fish.nom;
                _quantityByProduct[productName] = (_quantityByProduct[productName] ?? 0) + produit.quantite;
                _revenueByProduct[productName] = (_revenueByProduct[productName] ?? 0.0) + produit.total;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Générer un rapport de ventes
  Future<Map<String, dynamic>> generateSalesReport({
    required int pecheurId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Définir la période du rapport
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month, 1);
      final end = endDate ?? now;

      // Récupérer les commandes du pêcheur
      final allOrders = await _dbHelper.getOrdersByFisherman(pecheurId);

      // Filtrer les commandes par période
      final orders = allOrders.where((order) {
        return order.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
               order.createdAt.isBefore(end.add(const Duration(days: 1)));
      }).toList();

      // Calculer les statistiques
      double totalRevenue = 0.0;
      int totalOrders = orders.length;
      Map<String, int> ordersByStatus = {};
      List<Map<String, dynamic>> topProducts = [];
      Map<String, int> quantityByProduct = {};
      Map<String, double> revenueByProduct = {};

      for (var order in orders) {
        totalRevenue += order.totale;

        // Statistiques par statut
        final statusStr = order.statutCommande;
        ordersByStatus[statusStr] = (ordersByStatus[statusStr] ?? 0) + 1;

        // Statistiques par produit
        if (order.id != null) {
          final produits = await _dbHelper.getProduitVendusByCommandeId(order.id!);
          
          for (var produit in produits) {
            if (produit.produitId != null) {
              final fish = await _dbHelper.getProduitById(produit.produitId);
              if (fish != null) {
                final productName = fish.nom;
                quantityByProduct[productName] = (quantityByProduct[productName] ?? 0) + produit.quantite;
                revenueByProduct[productName] = (revenueByProduct[productName] ?? 0.0) + produit.total;
              }
            }
          }
        }
      }

      // Préparer la liste des produits les plus vendus
      List<MapEntry<String, int>> sortedProducts = quantityByProduct.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (var i = 0; i < sortedProducts.length && i < 5; i++) {
        final productName = sortedProducts[i].key;
        topProducts.add({
          'name': productName,
          'quantity': quantityByProduct[productName] ?? 0,
          'revenue': revenueByProduct[productName] ?? 0.0,
        });
      }

      // Préparer le rapport
      return {
        'period': {
          'start': DateFormat('dd/MM/yyyy').format(start),
          'end': DateFormat('dd/MM/yyyy').format(end),
        },
        'summary': {
          'totalOrders': totalOrders,
          'totalRevenue': totalRevenue,
          'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
        },
        'ordersByStatus': ordersByStatus,
        'topProducts': topProducts,
      };
    } catch (e) {
      print('Erreur lors de la génération du rapport: $e');
      return {'error': 'Erreur lors de la génération du rapport: $e'};
    }
  }
}
