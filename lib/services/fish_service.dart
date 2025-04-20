import 'package:flutter/foundation.dart';
import '../models/marketplace_produit.dart';
import '../models/marketplace_avis.dart';
import '../models/marketplace_categorie.dart';
import '../models/marketplace_image.dart';
import 'database_helper.dart';

class FishService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MarketplaceProduit> _fishes = [];
  List<MarketplaceAvis> _reviews = [];
  List<MarketplaceCategorie> _categories = [];
  bool _isLoading = false;

  // Getters
  List<MarketplaceProduit> get fishes => _fishes;
  List<MarketplaceAvis> get reviews => _reviews;
  List<MarketplaceCategorie> get categories => _categories;
  bool get isLoading => _isLoading;

  // Constructeur
  FishService() {
    _init();
  }

  // Initialiser le service
  Future<void> _init() async {
    await loadFishes();
    await loadReviews();
    await loadCategories();
    await _addTestFishesIfEmpty();
  }

  // Charger tous les poissons depuis la base de données
  Future<void> loadFishes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _fishes = await _dbHelper.getAllProduits();
      
      // Charger les images pour chaque produit
      for (int i = 0; i < _fishes.length; i++) {
        final produit = _fishes[i];
        if (produit.id != null) {
          final images = await _dbHelper.getImagesByProduitId(produit.id!);
          _fishes[i] = produit.copyWith(images: images);
        }
      }
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
      _reviews = await _dbHelper.getAllAvis();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des avis: $e');
    }
  }

  // Charger toutes les catégories depuis la base de données
  Future<void> loadCategories() async {
    try {
      _categories = await _dbHelper.getAllCategories();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
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

    return _fishes.where((fish) => fish.pecheurId == fishermanIdInt).toList();
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
      (sum, review) => sum + review.note.toDouble(),
    );
    return totalRating / reviews.length;
  }

  // Ajouter un avis
  Future<bool> addReview(MarketplaceAvis review) async {
    try {
      final id = await _dbHelper.insertAvis(review);
      if (id > 0) {
        // Créer une nouvelle instance avec l'ID
        final newReview = review.copyWith(id: id);
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
  Future<bool> addFish(MarketplaceProduit fish, List<String> imageUrls) async {
    try {
      final id = await _dbHelper.insertProduit(fish);
      if (id > 0) {
        // Créer une nouvelle instance avec l'ID
        final newFish = fish.copyWith(id: id);
        
        // Ajouter les images
        List<MarketplaceImage> images = [];
        for (var url in imageUrls) {
          final image = MarketplaceImage.create(
            url: url,
            produitId: id,
          );
          final imageId = await _dbHelper.insertImage(image);
          if (imageId > 0) {
            images.add(image.copyWith(id: imageId));
          }
        }
        
        final fishWithImages = newFish.copyWith(images: images);
        _fishes.add(fishWithImages);
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
  Future<bool> updateFish(MarketplaceProduit fish, List<String>? newImageUrls) async {
    try {
      final result = await _dbHelper.updateProduit(fish);
      
      // Mettre à jour les images si nécessaire
      if (newImageUrls != null && fish.id != null) {
        // Supprimer les anciennes images
        await _dbHelper.deleteImagesByProduitId(fish.id!);
        
        // Ajouter les nouvelles images
        List<MarketplaceImage> images = [];
        for (var url in newImageUrls) {
          final image = MarketplaceImage.create(
            url: url,
            produitId: fish.id,
          );
          final imageId = await _dbHelper.insertImage(image);
          if (imageId > 0) {
            images.add(image.copyWith(id: imageId));
          }
        }
        
        fish = fish.copyWith(images: images);
      }
      
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

      // Supprimer les images associées
      await _dbHelper.deleteImagesByProduitId(idInt);
      
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
      return _fishes;
    }

    final lowercaseQuery = query.toLowerCase();
    return _fishes.where((fish) {
      return fish.nom.toLowerCase().contains(lowercaseQuery) ||
             fish.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filtrer les poissons par catégorie
  List<MarketplaceProduit> filterFishesByCategory(int categoryId) {
    return _fishes.where((fish) => fish.categorieId == categoryId).toList();
  }

  // Ajouter des poissons de test pour le développement
  Future<void> _addTestFishesIfEmpty() async {
    try {
      // Vérifier si des poissons existent déjà
      final existingFishes = await _dbHelper.getAllProduits();
      if (existingFishes.isNotEmpty) return;

      // Vérifier si des catégories existent déjà
      final existingCategories = await _dbHelper.getAllCategories();
      int? categoryId;
      
      // Créer une catégorie si nécessaire
      if (existingCategories.isEmpty) {
        final testCategory = MarketplaceCategorie.create(
          nom: 'Poissons frais',
          imageUrl: 'assets/images/fresh_fish.png',
        );
        categoryId = await _dbHelper.insertCategorie(testCategory);
      } else {
        categoryId = existingCategories.first.id;
      }

      // Ajouter quelques poissons de test
      final testFishes = [
        MarketplaceProduit.create(
          nom: 'Bar commun',
          description: 'Bar frais pêché ce matin',
          prix: 12.5,
          stock: 10,
          categorieId: categoryId,
          pecheurId: 1, // ID du pêcheur de test
        ),
        MarketplaceProduit.create(
          nom: 'Dorade royale',
          description: 'Dorade fraîche de Méditerranée',
          prix: 15.0,
          stock: 5,
          categorieId: categoryId,
          pecheurId: 1, // ID du pêcheur de test
        ),
        MarketplaceProduit.create(
          nom: 'Maquereau',
          description: 'Maquereau frais pêché en Manche',
          prix: 8.5,
          stock: 20,
          categorieId: categoryId,
          pecheurId: 1, // ID du pêcheur de test
        ),
      ];

      for (var fish in testFishes) {
        final fishId = await _dbHelper.insertProduit(fish);
        
        // Ajouter une image de test
        if (fishId > 0) {
          final testImage = MarketplaceImage.create(
            url: 'assets/images/${fish.nom.toLowerCase().replaceAll(' ', '_')}.jpg',
            produitId: fishId,
          );
          await _dbHelper.insertImage(testImage);
        }
      }

      // Ajouter quelques avis de test
      final loadedFishes = await _dbHelper.getAllProduits();
      if (loadedFishes.isEmpty) return;

      final testReviews = [
        MarketplaceAvis.create(
          produitId: loadedFishes[0].id,
          userId: 2, // ID du client de test
          note: 4,
          commentaire: 'Excellent poisson, très frais et savoureux !',
        ),
        MarketplaceAvis.create(
          produitId: loadedFishes.length > 1 ? loadedFishes[1].id : loadedFishes[0].id,
          userId: 2, // ID du client de test
          note: 5,
          commentaire: 'La dorade était parfaite, je recommande vivement !',
        ),
      ];

      for (var review in testReviews) {
        await _dbHelper.insertAvis(review);
      }

      // Recharger les poissons et les avis
      await loadFishes();
      await loadReviews();
      await loadCategories();
    } catch (e) {
      print('Erreur lors de l\'ajout des poissons de test: $e');
    }
  }
}
