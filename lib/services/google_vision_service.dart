import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/models/fish_classification_result.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/config/fish_species_config.dart';

/// Service pour interagir avec l'API Google Cloud Vision
class GoogleVisionService {
  static final GoogleVisionService instance = GoogleVisionService._internal();

  // Clé API Google Cloud Vision
  static const String _apiKey = 'AIzaSyCSQO5KlHy3K7rx-58gL9n94xzH12GzwRQ';

  // URL de l'API Google Cloud Vision
  static const String _apiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  // Utiliser la configuration des espèces de poissons
  final Map<String, String> _fishSpeciesMapping =
      FishSpeciesConfig.englishToFrench;

  GoogleVisionService._internal();

  /// Analyse une image pour identifier l'espèce de poisson et retourne un objet Espece
  Future<Espece?> identifyFish(File imageFile) async {
    try {
      // Obtenir le résultat de classification
      final classificationResult = await classifyFish(imageFile);
      if (classificationResult == null) {
        return null;
      }

      // Mapper le nom à une espèce connue
      final String mappedSpecies = _mapToKnownSpecies(
        classificationResult.espece,
      );
      final double confidence = classificationResult.confiance;

      debugPrint(
        'Espèce identifiée: $mappedSpecies (confiance: ${(confidence * 100).toStringAsFixed(1)}%)',
      );

      // Vérifier si l'espèce existe dans la base de données
      try {
        final especeData = await ApiService.instance.getEspeceByNom(
          mappedSpecies,
        );
        if (especeData.containsKey('data') && especeData['data'] != null) {
          return Espece.fromMap(especeData['data']);
        }
      } catch (e) {
        debugPrint('Espèce non trouvée dans la base de données: $e');
      }

      // Si l'espèce n'existe pas, créer une nouvelle espèce
      try {
        final newEspeceData = await ApiService.instance.createEspece(
          mappedSpecies,
        );
        if (newEspeceData.containsKey('data') &&
            newEspeceData['data'] != null) {
          return Espece.fromMap(newEspeceData['data']);
        }
      } catch (e) {
        debugPrint('Erreur lors de la création de l\'espèce: $e');
      }

      // Si tout échoue, retourner une espèce temporaire
      return Espece(
        id: 'temp',
        nom: mappedSpecies,
        description:
            'Identifié par Google Vision API avec ${(confidence * 100).toStringAsFixed(1)}% de confiance',
      );
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'GoogleVisionService.identifyFish',
      );
      rethrow;
    }
  }

  /// Analyse une image pour classifier l'espèce de poisson et retourne un résultat de classification
  Future<FishClassificationResult?> classifyFish(File imageFile) async {
    try {
      // Convertir l'image en base64
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Préparer la requête à l'API
      final Map<String, dynamic> requestBody = {
        'requests': [
          {
            'image': {'content': base64Image},
            'features': [
              {'type': 'OBJECT_LOCALIZATION', 'maxResults': 5},
              {'type': 'LABEL_DETECTION', 'maxResults': 10},
            ],
          },
        ],
      };

      // Envoyer la requête à l'API
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Vérifier la réponse
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _processApiResponseForClassification(data);
      } else {
        debugPrint(
          'Erreur API Vision: ${response.statusCode} - ${response.body}',
        );
        throw Exception(
          'Erreur lors de l\'appel à l\'API Vision: ${response.statusCode}',
        );
      }
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'GoogleVisionService.classifyFish',
      );
      rethrow;
    }
  }

  /// Traite la réponse de l'API pour extraire l'espèce de poisson
  Future<Espece?> _processApiResponse(Map<String, dynamic> apiResponse) async {
    try {
      final responses = apiResponse['responses'];
      if (responses == null || responses.isEmpty) {
        return null;
      }

      final firstResponse = responses[0];

      // Vérifier les objets localisés
      final localizedObjectAnnotations =
          firstResponse['localizedObjectAnnotations'] ?? [];

      // Vérifier les labels détectés
      final labelAnnotations = firstResponse['labelAnnotations'] ?? [];

      // Combiner les résultats pour une meilleure identification
      final List<Map<String, dynamic>> fishCandidates = [];

      // Ajouter les objets localisés
      for (final obj in localizedObjectAnnotations) {
        final String name = obj['name'].toString().toLowerCase();
        final double score = obj['score'] as double;

        if (_isFishRelated(name)) {
          fishCandidates.add({
            'name': name,
            'score': score,
            'source': 'object',
          });
        }
      }

      // Ajouter les labels
      for (final label in labelAnnotations) {
        final String description =
            label['description'].toString().toLowerCase();
        final double score = label['score'] as double;

        if (_isFishRelated(description)) {
          fishCandidates.add({
            'name': description,
            'score': score,
            'source': 'label',
          });
        }
      }

      // Si aucun poisson n'est détecté
      if (fishCandidates.isEmpty) {
        debugPrint('Aucun poisson détecté dans l\'image');
        return null;
      }

      // Trier les candidats par score
      fishCandidates.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double),
      );

      // Prendre le meilleur candidat
      final bestCandidate = fishCandidates.first;
      final String fishName = bestCandidate['name'] as String;
      final double confidence = bestCandidate['score'] as double;

      // Mapper le nom à une espèce connue
      final String mappedSpecies = _mapToKnownSpecies(fishName);

      debugPrint(
        'Espèce identifiée: $mappedSpecies (confiance: ${(confidence * 100).toStringAsFixed(1)}%)',
      );

      // Vérifier si l'espèce existe dans la base de données
      try {
        final especeData = await ApiService.instance.getEspeceByNom(
          mappedSpecies,
        );
        if (especeData.containsKey('data') && especeData['data'] != null) {
          return Espece.fromMap(especeData['data']);
        }
      } catch (e) {
        debugPrint('Espèce non trouvée dans la base de données: $e');
      }

      // Si l'espèce n'existe pas, créer une nouvelle espèce
      try {
        final newEspeceData = await ApiService.instance.createEspece(
          mappedSpecies,
        );
        if (newEspeceData.containsKey('data') &&
            newEspeceData['data'] != null) {
          return Espece.fromMap(newEspeceData['data']);
        }
      } catch (e) {
        debugPrint('Erreur lors de la création de l\'espèce: $e');
      }

      // Si tout échoue, retourner une espèce temporaire
      return Espece(
        id: 'temp',
        nom: mappedSpecies,
        description:
            'Identifié par Google Vision API avec ${(confidence * 100).toStringAsFixed(1)}% de confiance',
      );
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'GoogleVisionService._processApiResponse',
      );
      return null;
    }
  }

  /// Vérifie si un nom est lié à un poisson
  bool _isFishRelated(String name) {
    // Vérifier si le nom est dans notre mapping
    if (_fishSpeciesMapping.keys.any((key) => name.contains(key))) {
      return true;
    }

    // Vérifier si le nom est dans notre liste d'espèces méditerranéennes
    if (FishSpeciesConfig.mediterraneanSpecies.any(
      (species) => name.contains(species),
    )) {
      return true;
    }

    // Vérifier si le nom est dans notre liste d'espèces supplémentaires
    if (FishSpeciesConfig.additionalSpecies.any(
      (species) => name.contains(species),
    )) {
      return true;
    }

    // Vérifier les termes génériques liés aux poissons
    final List<String> fishRelatedTerms = [
      'fish',
      'poisson',
      'seafood',
      'marine',
      'aquatic',
      'ocean',
      'sea',
      'water',
      'scale',
      'fin',
      'gill',
      'swim',
      'aquarium',
      'fishing',
      'catch',
      'bait',
    ];

    return fishRelatedTerms.any((term) => name.contains(term));
  }

  /// Mappe un nom détecté à une espèce connue
  String _mapToKnownSpecies(String detectedName) {
    // Chercher une correspondance exacte dans le mapping anglais-français
    for (final entry in _fishSpeciesMapping.entries) {
      if (detectedName == entry.key) {
        return entry.value;
      }
    }

    // Chercher une correspondance partielle dans le mapping anglais-français
    for (final entry in _fishSpeciesMapping.entries) {
      if (detectedName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Chercher une correspondance exacte dans les espèces méditerranéennes
    for (final species in FishSpeciesConfig.mediterraneanSpecies) {
      if (detectedName == species) {
        return species;
      }
    }

    // Chercher une correspondance partielle dans les espèces méditerranéennes
    for (final species in FishSpeciesConfig.mediterraneanSpecies) {
      if (detectedName.contains(species)) {
        return species;
      }
    }

    // Chercher une correspondance exacte dans les espèces supplémentaires
    for (final species in FishSpeciesConfig.additionalSpecies) {
      if (detectedName == species) {
        return species;
      }
    }

    // Chercher une correspondance partielle dans les espèces supplémentaires
    for (final species in FishSpeciesConfig.additionalSpecies) {
      if (detectedName.contains(species)) {
        return species;
      }
    }

    // Si aucune correspondance n'est trouvée, retourner "Poisson non identifié"
    return 'Poisson non identifié';
  }

  /// Traite la réponse de l'API pour extraire le résultat de classification
  Future<FishClassificationResult?> _processApiResponseForClassification(
    Map<String, dynamic> apiResponse,
  ) async {
    try {
      final responses = apiResponse['responses'];
      if (responses == null || responses.isEmpty) {
        return null;
      }

      final firstResponse = responses[0];

      // Vérifier les objets localisés
      final localizedObjectAnnotations =
          firstResponse['localizedObjectAnnotations'] ?? [];

      // Vérifier les labels détectés
      final labelAnnotations = firstResponse['labelAnnotations'] ?? [];

      // Combiner les résultats pour une meilleure identification
      final List<FishClassificationResult> fishCandidates = [];

      // Ajouter les objets localisés
      for (final obj in localizedObjectAnnotations) {
        final String name = obj['name'].toString().toLowerCase();
        final double score = obj['score'] as double;

        if (_isFishRelated(name)) {
          fishCandidates.add(
            FishClassificationResult(
              espece: name,
              confiance: score,
              source: 'Google Vision (object)',
            ),
          );
        }
      }

      // Ajouter les labels
      for (final label in labelAnnotations) {
        final String description =
            label['description'].toString().toLowerCase();
        final double score = label['score'] as double;

        if (_isFishRelated(description)) {
          fishCandidates.add(
            FishClassificationResult(
              espece: description,
              confiance: score,
              source: 'Google Vision (label)',
            ),
          );
        }
      }

      // Si aucun poisson n'est détecté
      if (fishCandidates.isEmpty) {
        debugPrint('Aucun poisson détecté dans l\'image');
        return null;
      }

      // Trier les candidats par score
      fishCandidates.sort((a, b) => b.confiance.compareTo(a.confiance));

      // Prendre le meilleur candidat
      final bestCandidate = fishCandidates.first;

      // Garder les 5 meilleurs résultats comme alternatives
      final alternatives =
          fishCandidates.length > 1
              ? fishCandidates.sublist(
                1,
                fishCandidates.length > 5 ? 5 : fishCandidates.length,
              )
              : <FishClassificationResult>[];

      // Retourner le résultat principal avec les alternatives
      return FishClassificationResult(
        espece: bestCandidate.espece,
        confiance: bestCandidate.confiance,
        source: bestCandidate.source,
        alternatives: alternatives,
      );
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'GoogleVisionService._processApiResponseForClassification',
      );
      return null;
    }
  }
}
