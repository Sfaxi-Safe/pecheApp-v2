import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/fish.dart';
import '../models/review.dart';
import 'database_helper.dart';

class FishService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Fish> _fishes = [];
  List<Review> _reviews = [];
  bool _isLoading = false;

  // Getters
  List<Fish> get fishes => _fishes;
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
      _fishes = await _dbHelper.getAllFishes();
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
      final allFishes = await _dbHelper.getAllFishes();

      List<Review> allReviews = [];
      for (var fish in allFishes) {
        final fishReviews = await _dbHelper.getReviewsByFish(fish.id);
        allReviews.addAll(fishReviews);
      }

      _reviews = allReviews;
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des avis: $e');
    }
  }

  // Obtenir tous les poissons
  List<Fish> getAllFishes() {
    return _fishes;
  }

  // Obtenir un poisson par son ID
  Fish? getFishById(String id) {
    try {
      return _fishes.firstWhere((fish) => fish.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les poissons d'un pêcheur
  List<Fish> getFishesByFishermanId(String fishermanId) {
    return _fishes.where((fish) => fish.fishermanId == fishermanId).toList();
  }

  // Obtenir les avis pour un poisson
  List<Review> getReviewsForFish(String fishId) {
    return _reviews.where((review) => review.fishId == fishId).toList();
  }

  // Calculer la note moyenne pour un poisson
  double getAverageRating(String fishId) {
    final reviews = getReviewsForFish(fishId);
    if (reviews.isEmpty) return 0;

    final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  // Ajouter un avis
  Future<bool> addReview(Review review) async {
    try {
      await _dbHelper.insertReview(review);
      _reviews.add(review);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis: $e');
      return false;
    }
  }

  // Ajouter un poisson
  Future<bool> addFish(Fish fish) async {
    try {
      await _dbHelper.insertFish(fish);
      _fishes.add(fish);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du poisson: $e');
      return false;
    }
  }

  // Mettre à jour un poisson
  Future<bool> updateFish(Fish fish) async {
    try {
      await _dbHelper.updateFish(fish);
      final index = _fishes.indexWhere((f) => f.id == fish.id);
      if (index != -1) {
        _fishes[index] = fish;
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du poisson: $e');
      return false;
    }
  }

  // Supprimer un poisson
  Future<bool> deleteFish(String id) async {
    try {
      await _dbHelper.deleteFish(id);
      _fishes.removeWhere((fish) => fish.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du poisson: $e');
      return false;
    }
  }

  // Rechercher des poissons
  List<Fish> searchFishes(String query) {
    if (query.isEmpty) {
      return [];
    }

    final lowercaseQuery = query.toLowerCase();
    return _fishes.where((fish) {
      return fish.species.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Ajouter des poissons de test pour le développement
  Future<void> _addTestFishesIfEmpty() async {
    try {
      // Vérifier si des poissons existent déjà
      final existingFishes = await _dbHelper.getAllFishes();
      if (existingFishes.isNotEmpty) return;

      // Ajouter quelques poissons de test
      final testFishes = [
        Fish(
          id: const Uuid().v4(),
          species: 'Bar commun',
          imageUrl: 'https://images.unsplash.com/photo-1545816250-e12bedba42ba?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          weight: 2.5,
          length: 45.0,
          location: 'Côte atlantique',
          fishingMethod: 'Canne à pêche',
          captureDate: DateTime.now().subtract(const Duration(days: 2)),
          fishermanId: '1', // ID du pêcheur de test
        ),
        Fish(
          id: const Uuid().v4(),
          species: 'Dorade royale',
          imageUrl: 'https://images.unsplash.com/photo-1579168765467-3b235f938439?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          weight: 1.8,
          length: 35.0,
          location: 'Méditerranée',
          fishingMethod: 'Filet',
          captureDate: DateTime.now().subtract(const Duration(days: 5)),
          fishermanId: '1', // ID du pêcheur de test
        ),
        Fish(
          id: const Uuid().v4(),
          species: 'Maquereau',
          imageUrl: 'https://images.unsplash.com/photo-1574781330855-d0db8cc6a79c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          weight: 0.9,
          length: 28.0,
          location: 'Manche',
          fishingMethod: 'Ligne de traîne',
          captureDate: DateTime.now().subtract(const Duration(days: 10)),
          fishermanId: '1', // ID du pêcheur de test
        ),
      ];

      for (var fish in testFishes) {
        await _dbHelper.insertFish(fish);
      }

      // Ajouter quelques avis de test
      final testReviews = [
        Review(
          id: const Uuid().v4(),
          fishId: testFishes[0].id,
          userId: '2', // ID du client de test
          userName: 'Jean Martin',
          userImageUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          rating: 4.5,
          comment: 'Excellent poisson, très frais et savoureux !',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Review(
          id: const Uuid().v4(),
          fishId: testFishes[1].id,
          userId: '2', // ID du client de test
          userName: 'Jean Martin',
          userImageUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          rating: 5.0,
          comment: 'La dorade était parfaite, je recommande vivement !',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      for (var review in testReviews) {
        await _dbHelper.insertReview(review);
      }

      // Recharger les poissons et les avis
      await loadFishes();
      await loadReviews();
    } catch (e) {
      print('Erreur lors de l\'ajout des poissons de test: $e');
    }
  }
}
