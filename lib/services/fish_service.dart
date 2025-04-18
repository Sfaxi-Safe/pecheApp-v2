import 'package:flutter/foundation.dart';
import '../models/marketplace_produit.dart';
import '../models/marketplace_avis.dart';
import 'database_helper.dart';

class FishService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MarketplaceProduit> _fishes = [];
  List<MarketplaceAvis> _reviews = [];
  bool _isLoading = false;

  // Getters
  List<MarketplaceProduit> get fishes => _fishes;
  bool get isLoading => _isLoading;

  // Constructeur
  FishService() {
    _init();
  }

  // Initialiser le service
  Future<void> _init() async {
    await loadFishes();
    await loadReviews();
    await _addTestFishesIfEmpty();
  }

  // Charger tous les poissons depuis la base de données
  Future<void> loadFishes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _fishes = await _dbHelper.getAllProduits();
    } catch (e) {
      print('Erreur lors du chargement des poissons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger tous les avis depuis la base de données
  Future<void> loadReviews() async {
    try {
      // Pour simplifier, nous chargeons tous les avis
      // Dans une vraie app, vous pourriez les charger à la demande
      _reviews = await _dbHelper.getAllAvis();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des avis: $e');
    }
  }

  // Obtenir tous les poissons
  List<MarketplaceProduit> getAllFishes() {
    return _fishes;
  }

  // Obtenir un poisson par son ID
  MarketplaceProduit? getFishById(String id) {
    try {
      final idInt = int.tryParse(id);
      if (idInt == null) return null;
      return _fishes.firstWhere((fish) => fish.id == idInt);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les poissons d'un pêcheur
  List<MarketplaceProduit> getFishesByFishermanId(String fishermanId) {
    final fishermanIdInt = int.tryParse(fishermanId);
    if (fishermanIdInt == null) return [];

    return _fishes.where((fish) => fish.userId == fishermanIdInt).toList();
  }

  // Obtenir les avis pour un poisson
  List<MarketplaceAvis> getReviewsForFish(String fishId) {
    final fishIdInt = int.tryParse(fishId);
    if (fishIdInt == null) return [];

    return _reviews.where((review) => review.produitId == fishIdInt).toList();
  }

  // Calculer la note moyenne pour un poisson
  double getAverageRating(String fishId) {
    final reviews = getReviewsForFish(fishId);
    if (reviews.isEmpty) return 0;

    final totalRating = reviews.fold(
      0.0,
      (sum, review) => sum + review.etoileNb.toDouble(),
    );
    return totalRating / reviews.length;
  }

  // Ajouter un avis
  Future<bool> addReview(MarketplaceAvis review) async {
    try {
      final id = await _dbHelper.insertAvis(review);
      if (id > 0) {
        // Créer une nouvelle instance avec l'ID
        final newReview = MarketplaceAvis(
          id: id,
          produitId: review.produitId,
          userId: review.userId,
          etoileNb: review.etoileNb,
          commentaire: review.commentaire,
          createdAt: review.createdAt,
        );
        _reviews.add(newReview);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis: $e');
      return false;
    }
  }

  // Ajouter un poisson
  Future<bool> addFish(MarketplaceProduit fish) async {
    try {
      final id = await _dbHelper.insertProduit(fish);
      if (id > 0) {
        // Créer une nouvelle instance avec l'ID
        final newFish = MarketplaceProduit(
          id: id,
          userId: fish.userId,
          nom: fish.nom,
          description: fish.description,
          stock: fish.stock,
          prix: fish.prix,
          min: fish.min,
          max: fish.max,
          vu: fish.vu,
          visibilite: fish.visibilite,
          typologie: fish.typologie,
          dateDePeche: fish.dateDePeche,
          zoneDePeche: fish.zoneDePeche,
        );
        _fishes.add(newFish);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'ajout du poisson: $e');
      return false;
    }
  }

  // Mettre à jour un poisson
  Future<bool> updateFish(MarketplaceProduit fish) async {
    try {
      final result = await _dbHelper.updateProduit(fish);
      if (result > 0) {
        final index = _fishes.indexWhere((f) => f.id == fish.id);
        if (index != -1) {
          _fishes[index] = fish;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la mise à jour du poisson: $e');
      return false;
    }
  }

  // Supprimer un poisson
  Future<bool> deleteFish(String id) async {
    try {
      final idInt = int.tryParse(id);
      if (idInt == null) return false;

      final result = await _dbHelper.deleteProduit(idInt);
      if (result > 0) {
        _fishes.removeWhere((fish) => fish.id == idInt);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression du poisson: $e');
      return false;
    }
  }

  // Rechercher des poissons
  List<MarketplaceProduit> searchFishes(String query) {
    if (query.isEmpty) {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();
    return _fishes.where((fish) {
      return fish.nom.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Ajouter des poissons de test pour le développement
  Future<void> _addTestFishesIfEmpty() async {
    try {
      // Vérifier si des poissons existent déjà
      final existingFishes = await _dbHelper.getAllProduits();
      if (existingFishes.isNotEmpty) return;

      // Ajouter quelques poissons de test
      final testFishes = [
        MarketplaceProduit(
          userId: 1, // ID du pêcheur de test
          nom: 'Bar commun',
          description: 'Bar frais pêché ce matin',
          stock: 10,
          prix: 12.5,
          min: 1,
          max: 100,
          vu: 0,
          visibilite: true,
          typologie: 'Poisson',
          dateDePeche:
              DateTime.now().subtract(const Duration(days: 2)).toString(),
          zoneDePeche: 'Côte atlantique',
        ),
        MarketplaceProduit(
          userId: 1, // ID du pêcheur de test
          nom: 'Dorade royale',
          description: 'Dorade fraîche de Méditerranée',
          stock: 5,
          prix: 15.0,
          min: 1,
          max: 100,
          vu: 0,
          visibilite: true,
          typologie: 'Poisson',
          dateDePeche:
              DateTime.now().subtract(const Duration(days: 5)).toString(),
          zoneDePeche: 'Méditerranée',
        ),
        MarketplaceProduit(
          userId: 1, // ID du pêcheur de test
          nom: 'Maquereau',
          description: 'Maquereau frais pêché en Manche',
          stock: 20,
          prix: 8.5,
          min: 1,
          max: 100,
          vu: 0,
          visibilite: true,
          typologie: 'Poisson',
          dateDePeche:
              DateTime.now().subtract(const Duration(days: 10)).toString(),
          zoneDePeche: 'Manche',
        ),
      ];

      for (var fish in testFishes) {
        await _dbHelper.insertProduit(fish);
      }

      // Ajouter quelques avis de test
      final loadedFishes = await _dbHelper.getAllProduits();
      if (loadedFishes.isEmpty) return;

      final testReviews = [
        MarketplaceAvis(
          produitId: loadedFishes[0].id,
          userId: 2, // ID du client de test
          etoileNb: 4,
          commentaire: 'Excellent poisson, très frais et savoureux !',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        MarketplaceAvis(
          produitId:
              loadedFishes.length > 1 ? loadedFishes[1].id : loadedFishes[0].id,
          userId: 2, // ID du client de test
          etoileNb: 5,
          commentaire: 'La dorade était parfaite, je recommande vivement !',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      for (var review in testReviews) {
        await _dbHelper.insertAvis(review);
      }

      // Recharger les poissons et les avis
      await loadFishes();
      await loadReviews();
    } catch (e) {
      print('Erreur lors de l\'ajout des poissons de test: $e');
    }
  }
}
