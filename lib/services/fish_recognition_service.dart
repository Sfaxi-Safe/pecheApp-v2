import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/models/fish_classification_result.dart';
import 'package:image/image.dart' as img;
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/google_vision_service.dart';
import 'package:seatrace/services/tensorflow_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FishRecognitionService {
  static final FishRecognitionService _instance =
      FishRecognitionService._internal();
  factory FishRecognitionService() => _instance;

  Interpreter? _interpreter;
  bool _isInitialized = false;
  bool _preferOnlineRecognition = true; // Préférer l'API en ligne si disponible

  // Définir les labels des espèces de poissons que le modèle peut reconnaître
  final List<String> _labels = [
    'Thon rouge',
    'Dorade',
    'Sardine',
    'Bar',
    'Maquereau',
    'Merlu',
    'Sole',
    'Loup de mer',
    'Rouget',
    'Anchois',
  ];

  FishRecognitionService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Charger le modèle TensorFlow Lite
      final options = InterpreterOptions();

      // Utiliser la mémoire GPU si disponible pour accélérer l'inférence
      options.addDelegate(GpuDelegateV2());

      // Charger le modèle depuis les assets
      _interpreter = await Interpreter.fromAsset(
        'assets/models/fish_recognition_model.tflite',
        options: options,
      );

      _isInitialized = true;
      // Modèle de reconnaissance de poissons initialisé avec succès
    } catch (e) {
      // Erreur lors de l'initialisation du modèle de reconnaissance de poissons: $e

      // En cas d'erreur avec le GPU, essayer de charger avec CPU seulement
      try {
        final options = InterpreterOptions();
        _interpreter = await Interpreter.fromAsset(
          'assets/models/fish_recognition_model.tflite',
          options: options,
        );
        _isInitialized = true;
        // Modèle initialisé avec CPU seulement
      } catch (e) {
        // Échec de l'initialisation du modèle même avec CPU: $e
        rethrow;
      }
    }
  }

  /// Obtient le résultat de classification d'un poisson à partir d'une image
  Future<FishClassificationResult?> classifyFish(File imageFile) async {
    // Vérifier la connectivité
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool hasInternet = connectivityResult != ConnectivityResult.none;

    // Si nous avons une connexion internet et que nous préférons l'API en ligne
    if (hasInternet && _preferOnlineRecognition) {
      try {
        debugPrint(
          'Utilisation de Google Cloud Vision API pour la classification',
        );
        // Utiliser l'API Google Cloud Vision
        final result = await GoogleVisionService.instance.classifyFish(
          imageFile,
        );
        if (result != null) {
          return result;
        }
        // Si l'API échoue, utiliser le modèle local comme solution de secours
        debugPrint('Google Cloud Vision a échoué, utilisation du modèle local');
      } catch (e) {
        debugPrint('Erreur avec Google Cloud Vision: $e');
        // Continuer avec le modèle local en cas d'erreur
      }
    }

    // Utiliser le modèle TensorFlow
    debugPrint('Utilisation du modèle TensorFlow pour la classification');
    try {
      // Utiliser le service TensorFlow pour la prédiction
      final result = await TensorFlowService.instance.predictFish(imageFile);
      return result;
    } catch (e) {
      debugPrint('Erreur lors de la classification avec TensorFlow: $e');

      // Essayer avec l'ancien modèle TensorFlow Lite comme solution de secours
      try {
        debugPrint('Tentative avec l\'ancien modèle TensorFlow Lite');
        await initialize();

        if (_interpreter == null) {
          throw Exception('Le modèle n\'a pas été initialisé correctement');
        }

        // Prétraiter l'image
        final inputBuffer = await _preprocessImage(imageFile);

        // Préparer le buffer de sortie
        final outputBuffer = List<List<double>>.filled(
          1,
          List<double>.filled(_labels.length, 0),
        );

        // Exécuter l'inférence
        _interpreter!.run(inputBuffer, outputBuffer);

        // Traiter les résultats
        final result = outputBuffer[0];

        // Créer une liste de résultats triés par confiance
        final List<FishClassificationResult> allResults = [];

        for (int i = 0; i < result.length; i++) {
          if (i < _labels.length) {
            allResults.add(
              FishClassificationResult(
                espece: _labels[i],
                confiance: result[i],
                source: 'TensorFlow Lite (ancien)',
              ),
            );
          }
        }

        // Trier les résultats par confiance (du plus élevé au plus bas)
        allResults.sort((a, b) => b.confiance.compareTo(a.confiance));

        // Le premier résultat est celui avec la plus haute confiance
        final topResult = allResults.first;

        // Garder les 5 meilleurs résultats comme alternatives
        final alternatives =
            allResults.length > 1
                ? allResults.sublist(
                  1,
                  allResults.length > 5 ? 5 : allResults.length,
                )
                : <FishClassificationResult>[];

        // Retourner le résultat principal avec les alternatives
        return FishClassificationResult(
          espece: topResult.espece,
          confiance: topResult.confiance,
          source: topResult.source,
          alternatives: alternatives,
        );
      } catch (e) {
        debugPrint('Erreur avec l\'ancien modèle: $e');
        return null;
      }
    }
  }

  /// Reconnaît un poisson à partir d'une image et retourne l'espèce correspondante
  Future<Espece?> recognizeFish(File imageFile) async {
    // Obtenir le résultat de classification
    final classificationResult = await classifyFish(imageFile);
    if (classificationResult == null) {
      return null;
    }

    final String especeNom = classificationResult.espece;
    final double confiance = classificationResult.confiance;

    // Si la probabilité est trop faible, considérer comme non reconnu
    if (confiance < 0.5) {
      debugPrint(
        'Confiance trop faible: ${(confiance * 100).toStringAsFixed(1)}% pour $especeNom',
      );
      return null;
    }

    debugPrint(
      'Espèce identifiée: $especeNom (confiance: ${(confiance * 100).toStringAsFixed(1)}%)',
    );

    // Récupérer l'espèce correspondante depuis l'API
    try {
      final espece = await ApiService.instance.getEspeceByNom(especeNom);
      return Espece.fromMap(espece);
    } catch (e) {
      debugPrint('Espèce non trouvée dans la base de données: $e');

      // Si l'espèce n'existe pas, la créer via l'API
      try {
        final nouvelleEspece = await ApiService.instance.createEspece(
          especeNom,
        );
        return Espece.fromMap(nouvelleEspece);
      } catch (e) {
        debugPrint('Erreur lors de la création de l\'espèce: $e');

        // En cas d'erreur, essayer de récupérer une espèce aléatoire via l'API
        // comme solution de secours
        try {
          final allEspeces = await ApiService.instance.getAllEspeces();
          if (allEspeces.isNotEmpty) {
            final randomIndex = Random().nextInt(allEspeces.length);
            return Espece.fromMap(allEspeces[randomIndex]);
          }
        } catch (e) {
          debugPrint('Erreur lors de la récupération des espèces: $e');
        }
      }
    }

    return null;
  }

  /// Définit si l'API en ligne doit être préférée au modèle local
  void setPreferOnlineRecognition(bool prefer) {
    _preferOnlineRecognition = prefer;
  }

  Future<List<List<List<double>>>> _preprocessImage(File imageFile) async {
    // Lire l'image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Impossible de décoder l\'image');

    // Redimensionner l'image à la taille d'entrée du modèle (224x224 est courant)
    final inputSize = 224;
    final resizedImage = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Normaliser les valeurs des pixels entre 0 et 1
    // Créer un buffer d'entrée au format attendu par le modèle
    final inputBuffer = List<List<List<double>>>.filled(
      1,
      List<List<double>>.filled(
        inputSize,
        List<double>.filled(inputSize * 3, 0),
      ),
    );

    // Remplir le buffer avec les valeurs normalisées des pixels
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        // Obtenir directement les valeurs RGB normalisées
        // Utiliser les méthodes de la bibliothèque image pour extraire les composantes
        final r = resizedImage.getPixelSafe(x, y).r / 255.0;
        final g = resizedImage.getPixelSafe(x, y).g / 255.0;
        final b = resizedImage.getPixelSafe(x, y).b / 255.0;

        // Stocker dans le buffer (format dépendant du modèle)
        // Certains modèles attendent [R, G, B] pour chaque pixel
        inputBuffer[0][y][x * 3] = r;
        inputBuffer[0][y][x * 3 + 1] = g;
        inputBuffer[0][y][x * 3 + 2] = b;
      }
    }

    return inputBuffer;
  }

  // Méthode pour libérer les ressources
  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
      _isInitialized = false;
    }
  }
}
