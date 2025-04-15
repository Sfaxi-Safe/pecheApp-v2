import 'package:flutter/material.dart';
import '../models/fish.dart';
import 'fish_service.dart';

class StatisticsService with ChangeNotifier {
  final FishService _fishService;
  
  StatisticsService(this._fishService);
  
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
}
