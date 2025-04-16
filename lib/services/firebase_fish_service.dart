import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/fish.dart';
import '../models/review.dart';

class FirebaseFishService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<Fish> _fishes = [];
  List<Review> _reviews = [];
  bool _isLoading = false;

  // Getters
  List<Fish> get fishes => _fishes;
  bool get isLoading => _isLoading;

  // Constructeur
  FirebaseFishService() {
    _init();
  }

  // Initialiser le service
  Future<void> _init() async {
    await loadFishes();
    await loadReviews();
  }

  // Charger tous les poissons depuis Firestore
  Future<void> loadFishes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('fishes').get();
      
      _fishes = snapshot.docs.map((doc) {
        final data = doc.data();
        return Fish(
          id: doc.id,
          species: data['species'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          weight: (data['weight'] ?? 0).toDouble(),
          length: (data['length'] ?? 0).toDouble(),
          location: data['location'] ?? '',
          fishingMethod: data['fishingMethod'] ?? '',
          captureDate: data['captureDate'] != null 
            ? (data['captureDate'] as Timestamp).toDate() 
            : DateTime.now(),
          fishermanId: data['fishermanId'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des poissons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger tous les avis depuis Firestore
  Future<void> loadReviews() async {
    try {
      final snapshot = await _firestore.collection('reviews').get();
      
      _reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        return Review(
          id: doc.id,
          fishId: data['fishId'] ?? '',
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? '',
          userImageUrl: data['userImageUrl'],
          rating: (data['rating'] ?? 0).toDouble(),
          comment: data['comment'] ?? '',
          createdAt: data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate() 
            : DateTime.now(),
        );
      }).toList();
      
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

  // Télécharger une image vers Firebase Storage
  Future<String> uploadFishImage(File imageFile, String fishermanId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final storageRef = _storage.ref().child('fish_images/$fishermanId/$fileName');
      
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      throw e;
    }
  }

  // Ajouter un avis
  Future<bool> addReview(Review review) async {
    try {
      final docRef = await _firestore.collection('reviews').add({
        'fishId': review.fishId,
        'userId': review.userId,
        'userName': review.userName,
        'userImageUrl': review.userImageUrl,
        'rating': review.rating,
        'comment': review.comment,
        'createdAt': Timestamp.fromDate(review.createdAt),
      });
      
      final newReview = review.copyWith(id: docRef.id);
      _reviews.add(newReview);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis: $e');
      return false;
    }
  }

  // Ajouter un poisson
  Future<bool> addFish(Fish fish, {File? imageFile}) async {
    try {
      String imageUrl = fish.imageUrl;
      
      // Si une nouvelle image est fournie, la télécharger
      if (imageFile != null) {
        imageUrl = await uploadFishImage(imageFile, fish.fishermanId);
      }
      
      final fishWithImage = fish.copyWith(imageUrl: imageUrl);
      
      final docRef = await _firestore.collection('fishes').add({
        'species': fishWithImage.species,
        'imageUrl': fishWithImage.imageUrl,
        'weight': fishWithImage.weight,
        'length': fishWithImage.length,
        'location': fishWithImage.location,
        'fishingMethod': fishWithImage.fishingMethod,
        'captureDate': Timestamp.fromDate(fishWithImage.captureDate),
        'fishermanId': fishWithImage.fishermanId,
      });
      
      final newFish = fishWithImage.copyWith(id: docRef.id);
      _fishes.add(newFish);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du poisson: $e');
      return false;
    }
  }

  // Mettre à jour un poisson
  Future<bool> updateFish(Fish fish, {File? imageFile}) async {
    try {
      String imageUrl = fish.imageUrl;
      
      // Si une nouvelle image est fournie, la télécharger
      if (imageFile != null) {
        imageUrl = await uploadFishImage(imageFile, fish.fishermanId);
      }
      
      final fishWithImage = fish.copyWith(imageUrl: imageUrl);
      
      await _firestore.collection('fishes').doc(fish.id).update({
        'species': fishWithImage.species,
        'imageUrl': fishWithImage.imageUrl,
        'weight': fishWithImage.weight,
        'length': fishWithImage.length,
        'location': fishWithImage.location,
        'fishingMethod': fishWithImage.fishingMethod,
        'captureDate': Timestamp.fromDate(fishWithImage.captureDate),
      });
      
      final index = _fishes.indexWhere((f) => f.id == fish.id);
      if (index != -1) {
        _fishes[index] = fishWithImage;
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
      // Récupérer le poisson pour obtenir l'URL de l'image
      final fish = getFishById(id);
      if (fish != null && fish.imageUrl.isNotEmpty) {
        try {
          // Supprimer l'image de Firebase Storage si elle y est stockée
          if (fish.imageUrl.contains('firebase')) {
            final ref = _storage.refFromURL(fish.imageUrl);
            await ref.delete();
          }
        } catch (e) {
          print('Erreur lors de la suppression de l\'image: $e');
          // Continuer même si la suppression de l'image échoue
        }
      }
      
      // Supprimer les avis associés au poisson
      final batch = _firestore.batch();
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('fishId', isEqualTo: id)
          .get();
      
      for (var doc in reviewsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Supprimer le poisson
      batch.delete(_firestore.collection('fishes').doc(id));
      await batch.commit();
      
      // Mettre à jour les listes locales
      _reviews.removeWhere((review) => review.fishId == id);
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
}
