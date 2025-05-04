/// Modèle représentant le résultat d'une classification de poisson
class FishClassificationResult {
  /// Espèce identifiée
  final String espece;
  
  /// Niveau de confiance (0.0 à 1.0)
  final double confiance;
  
  /// Source de la classification (TensorFlow, Google Vision, etc.)
  final String source;
  
  /// Résultats alternatifs (autres espèces possibles)
  final List<FishClassificationResult>? alternatives;

  FishClassificationResult({
    required this.espece,
    required this.confiance,
    required this.source,
    this.alternatives,
  });

  /// Crée une instance à partir d'une map
  factory FishClassificationResult.fromMap(Map<String, dynamic> map) {
    List<FishClassificationResult>? alternatives;
    
    if (map['alternatives'] != null) {
      alternatives = List<FishClassificationResult>.from(
        (map['alternatives'] as List).map(
          (x) => FishClassificationResult.fromMap(x),
        ),
      );
    }
    
    return FishClassificationResult(
      espece: map['espece'],
      confiance: map['confiance'],
      source: map['source'],
      alternatives: alternatives,
    );
  }

  /// Convertit l'instance en map
  Map<String, dynamic> toMap() {
    return {
      'espece': espece,
      'confiance': confiance,
      'source': source,
      'alternatives': alternatives?.map((x) => x.toMap()).toList(),
    };
  }

  @override
  String toString() {
    return 'FishClassificationResult(espece: $espece, confiance: $confiance, source: $source)';
  }
}
