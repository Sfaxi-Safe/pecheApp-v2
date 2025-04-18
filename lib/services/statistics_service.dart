import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_produit.dart';
import '../models/marketplace_aommande.dart';
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
  int getCapturesThisMonth(String fishermanId) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final fishermanIdInt = int.tryParse(fishermanId);
    if (fishermanIdInt == null) return 0;

    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    return fishes.where((fish) {
      if (fish.dateDePeche == null) return false;

      try {
        final captureDate = DateTime.parse(fish.dateDePeche!);
        return captureDate.isAfter(firstDayOfMonth) ||
            captureDate.isAtSameMomentAs(firstDayOfMonth);
      } catch (e) {
        return false;
      }
    }).length;
  }

  // Obtenir le nombre d'espèces différentes capturées par un pêcheur
  int getDifferentSpeciesCount(String fishermanId) {
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    final species = fishes.map((fish) => fish.nom).toSet();
    return species.length;
  }

  // Obtenir le poids total des captures d'un pêcheur
  double getTotalWeight(String fishermanId) {
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    // Dans le nouveau modèle, nous n'avons pas de poids
    // Nous utilisons le stock comme approximation
    return fishes.fold(0.0, (sum, fish) => sum + fish.stock);
  }

  // Obtenir la dernière capture d'un pêcheur
  MarketplaceProduit? getLastCapture(String fishermanId) {
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    if (fishes.isEmpty) {
      return null;
    }

    // Trier les poissons par date de capture (du plus récent au plus ancien)
    fishes.sort((a, b) {
      if (a.dateDePeche == null) return 1;
      if (b.dateDePeche == null) return -1;

      try {
        final dateA = DateTime.parse(a.dateDePeche!);
        final dateB = DateTime.parse(b.dateDePeche!);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return fishes.first;
  }

  // Statistiques pour les ventes

  // Charger toutes les statistiques
  Future<void> loadAllStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Récupérer toutes les commandes
      final orders = await _dbHelper.getAllOrders();

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
        // Convertir l'ordre en MarketplaceAommande
        final commande = order as MarketplaceAommande;

        _totalOrders++;
        _totalRevenue += commande.totale;

        // Statistiques par statut
        final statusStr = commande.statutCommande;
        _ordersByStatus[statusStr] = (_ordersByStatus[statusStr] ?? 0) + 1;

        // Statistiques par mois
        final createdAt = commande.createdAt;
        final monthYear = DateFormat('MM-yyyy').format(createdAt);
        _revenueByMonth[monthYear] =
            (_revenueByMonth[monthYear] ?? 0.0) + commande.totale;

        // Statistiques par produit
        // Note: Dans une implémentation réelle, nous récupérerions les produits vendus
        // Pour l'instant, nous utilisons des données fictives
        _totalProducts += 0;
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
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Définir la période du rapport
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month, 1);
      final end = endDate ?? now;

      // Récupérer toutes les commandes
      final allOrders = await _dbHelper.getAllOrders();

      // Filtrer les commandes par période
      final orders =
          allOrders.where((order) {
            // Convertir l'ordre en MarketplaceAommande
            final commande = order as MarketplaceAommande;
            final createdAt = commande.createdAt;

            return createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
                createdAt.isBefore(end.add(const Duration(days: 1)));
          }).toList();

      // Calculer les statistiques
      double totalRevenue = 0.0;
      int totalOrders = orders.length;
      Map<String, int> ordersByStatus = {};
      List<Map<String, dynamic>> topProducts = [];
      Map<String, int> quantityByProduct = {};
      Map<String, double> revenueByProduct = {};

      for (var order in orders) {
        // Convertir l'ordre en MarketplaceAommande
        final commande = order as MarketplaceAommande;

        totalRevenue += commande.totale;

        // Statistiques par statut
        final statusStr = commande.statutCommande;
        ordersByStatus[statusStr] = (ordersByStatus[statusStr] ?? 0) + 1;

        // Statistiques par produit
        // Note: Dans une implémentation réelle, nous récupérerions les produits vendus
        // Pour l'instant, nous utilisons des données fictives
      }

      // Préparer la liste des produits les plus vendus (données fictives)
      topProducts = [
        {'name': 'Bar', 'quantity': 10, 'revenue': 150.0},
        {'name': 'Dorade', 'quantity': 8, 'revenue': 120.0},
        {'name': 'Sole', 'quantity': 5, 'revenue': 75.0},
      ];

      // Préparer le rapport
      return {
        'period': {
          'start': DateFormat('dd/MM/yyyy').format(start),
          'end': DateFormat('dd/MM/yyyy').format(end),
        },
        'summary': {
          'totalOrders': totalOrders,
          'totalRevenue': totalRevenue,
          'averageOrderValue':
              totalOrders > 0 ? totalRevenue / totalOrders : 0.0,
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
