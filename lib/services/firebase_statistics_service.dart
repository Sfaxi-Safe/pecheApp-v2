import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fish.dart';
import 'firebase_fish_service.dart';

class FirebaseStatisticsService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFishService _fishService;
  
  FirebaseStatisticsService(this._fishService);
  
  // Obtenir le nombre de captures pour un pêcheur ce mois-ci
  int getCapturesThisMonth(String fishermanId) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    return fishes.where((fish) => 
      fish.captureDate.isAfter(firstDayOfMonth) || 
      fish.captureDate.isAtSameMomentAs(firstDayOfMonth)
    ).length;
  }
  
  // Obtenir le nombre d'espèces différentes capturées par un pêcheur
  int getDifferentSpeciesCount(String fishermanId) {
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    final species = fishes.map((fish) => fish.species).toSet();
    return species.length;
  }
  
  // Obtenir le poids total des captures d'un pêcheur
  double getTotalWeight(String fishermanId) {
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    return fishes.fold(0.0, (sum, fish) => sum + fish.weight);
  }
  
  // Obtenir la dernière capture d'un pêcheur
  Fish? getLastCapture(String fishermanId) {
    final fishes = _fishService.getFishesByFishermanId(fishermanId);
    if (fishes.isEmpty) {
      return null;
    }
    
    // Trier les poissons par date de capture (du plus récent au plus ancien)
    fishes.sort((a, b) => b.captureDate.compareTo(a.captureDate));
    return fishes.first;
  }
  
  // Obtenir les statistiques de vente par mois
  Future<List<Map<String, dynamic>>> getMonthlySalesStats(String fishermanId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('fishermanId', isEqualTo: fishermanId)
          .where('status', isNotEqualTo: 4) // 4 est l'index de OrderStatus.cancelled
          .get();
      
      // Regrouper les commandes par mois
      final Map<String, Map<String, dynamic>> monthlyStats = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final orderDate = (data['orderDate'] as Timestamp).toDate();
        final month = '${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}';
        
        if (!monthlyStats.containsKey(month)) {
          monthlyStats[month] = {
            'month': month,
            'orderCount': 0,
            'totalSales': 0.0,
          };
        }
        
        monthlyStats[month]!['orderCount'] = monthlyStats[month]!['orderCount'] + 1;
        monthlyStats[month]!['totalSales'] = monthlyStats[month]!['totalSales'] + (data['totalPrice'] ?? 0).toDouble();
      }
      
      // Convertir en liste et trier par mois (du plus récent au plus ancien)
      final result = monthlyStats.values.toList();
      result.sort((a, b) => b['month'].compareTo(a['month']));
      
      // Limiter à 12 mois
      return result.take(12).toList();
    } catch (e) {
      print('Erreur lors de la récupération des statistiques de vente: $e');
      return [];
    }
  }
  
  // Obtenir les espèces les plus vendues
  Future<List<Map<String, dynamic>>> getTopSellingSpecies(String fishermanId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('fishermanId', isEqualTo: fishermanId)
          .where('status', isNotEqualTo: 4) // 4 est l'index de OrderStatus.cancelled
          .get();
      
      // Regrouper les commandes par espèce
      final Map<String, Map<String, dynamic>> speciesStats = {};
      
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data();
        final fishId = data['fishId'];
        
        // Récupérer les informations du poisson
        final fishDoc = await _firestore.collection('fishes').doc(fishId).get();
        if (fishDoc.exists) {
          final fishData = fishDoc.data()!;
          final species = fishData['species'] ?? 'Inconnu';
          
          if (!speciesStats.containsKey(species)) {
            speciesStats[species] = {
              'species': species,
              'orderCount': 0,
              'totalQuantity': 0.0,
            };
          }
          
          speciesStats[species]!['orderCount'] = speciesStats[species]!['orderCount'] + 1;
          speciesStats[species]!['totalQuantity'] = speciesStats[species]!['totalQuantity'] + (data['quantity'] ?? 0).toDouble();
        }
      }
      
      // Convertir en liste et trier par nombre de commandes (du plus grand au plus petit)
      final result = speciesStats.values.toList();
      result.sort((a, b) => b['orderCount'].compareTo(a['orderCount']));
      
      // Limiter à 5 espèces
      return result.take(5).toList();
    } catch (e) {
      print('Erreur lors de la récupération des espèces les plus vendues: $e');
      return [];
    }
  }
}
