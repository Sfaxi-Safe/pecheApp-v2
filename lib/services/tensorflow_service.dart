import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:seatrace/models/fish_classification_result.dart';
import 'package:seatrace/config/fish_species_config.dart';

/// Service pour l'intégration du modèle TensorFlow Lite
class TensorFlowService {
  static final TensorFlowService instance = TensorFlowService._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;
  List<String>? _labels;

  TensorFlowService._internal();

  /// Initialise le modèle TensorFlow Lite
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Copier le modèle et les labels depuis les assets vers le stockage local
      await _copyModelToLocal();

      // Charger les labels
      await _loadLabels();

      // Obtenir le chemin du modèle
      final modelPath = await _getModelPath();

      // Configurer les options d'interprétation
      final options = InterpreterOptions();

      // Essayer d'utiliser le GPU si disponible
      try {
        options.addDelegate(GpuDelegateV2());
        debugPrint('GPU delegate ajouté avec succès');
      } catch (e) {
        debugPrint('GPU non disponible, utilisation du CPU: $e');
      }

      // Charger le modèle
      _interpreter = Interpreter.fromFile(File(modelPath), options: options);

      _isInitialized = true;
      debugPrint('Modèle TensorFlow initialisé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du modèle TensorFlow: $e');

      // En cas d'erreur avec le GPU, essayer avec CPU seulement
      try {
        final modelPath = await _getModelPath();
        final options = InterpreterOptions();
        _interpreter = Interpreter.fromFile(File(modelPath), options: options);
        _isInitialized = true;
        debugPrint('Modèle initialisé avec CPU seulement');
      } catch (e) {
        debugPrint('Échec de l\'initialisation du modèle même avec CPU: $e');
        rethrow;
      }
    }
  }

  /// Copie le modèle et les labels depuis les assets vers le stockage local
  Future<void> _copyModelToLocal() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory(path.join(appDir.path, 'models'));

    // Créer le répertoire s'il n'existe pas
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    // Copier le modèle
    final modelPath = path.join(modelDir.path, 'keras_model.h5');
    final modelFile = File(modelPath);

    if (!await modelFile.exists()) {
      final modelData = await rootBundle.load('assets/models/keras_model.h5');
      await modelFile.writeAsBytes(modelData.buffer.asUint8List());
      debugPrint('Modèle copié vers: $modelPath');
    }

    // Copier les labels
    final labelsPath = path.join(modelDir.path, 'labels.txt');
    final labelsFile = File(labelsPath);

    if (!await labelsFile.exists()) {
      final labelsData = await rootBundle.load('assets/models/labels.txt');
      await labelsFile.writeAsBytes(labelsData.buffer.asUint8List());
      debugPrint('Labels copiés vers: $labelsPath');
    }
  }

  /// Charge les labels depuis le fichier
  Future<void> _loadLabels() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final labelsPath = path.join(appDir.path, 'models', 'labels.txt');
      final labelsFile = File(labelsPath);

      if (await labelsFile.exists()) {
        final labelsContent = await labelsFile.readAsString();
        _labels =
            labelsContent.split('\n').where((line) => line.isNotEmpty).map((
              line,
            ) {
              // Format attendu: "0 baliste"
              final parts = line.trim().split(' ');
              if (parts.length > 1) {
                return parts.sublist(1).join(' '); // Prendre tout sauf l'index
              }
              return line;
            }).toList();

        // Enrichir les labels avec les espèces supplémentaires
        _enrichLabels();

        debugPrint('Labels chargés: ${_labels!.length} espèces');
      } else {
        throw Exception('Fichier de labels non trouvé');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des labels: $e');
      rethrow;
    }
  }

  /// Enrichit les labels avec les espèces supplémentaires
  void _enrichLabels() {
    if (_labels == null) return;

    // Créer un ensemble pour éviter les doublons
    final Set<String> uniqueLabels = Set.from(_labels!);

    // Ajouter les espèces méditerranéennes
    uniqueLabels.addAll(FishSpeciesConfig.mediterraneanSpecies);

    // Ajouter les espèces supplémentaires
    uniqueLabels.addAll(FishSpeciesConfig.additionalSpecies);

    // Mettre à jour les labels
    _labels = uniqueLabels.toList()..sort();

    debugPrint('Labels enrichis: ${_labels!.length} espèces au total');
  }

  /// Obtient le chemin du modèle
  Future<String> _getModelPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'models', 'keras_model.h5');
  }

  /// Prédit l'espèce de poisson à partir d'une image
  Future<FishClassificationResult> predictFish(File imageFile) async {
    await initialize();

    if (_interpreter == null) {
      throw Exception('Le modèle n\'a pas été initialisé correctement');
    }

    if (_labels == null || _labels!.isEmpty) {
      throw Exception('Les labels n\'ont pas été chargés correctement');
    }

    try {
      // Prétraiter l'image
      final processedImage = await _preprocessImage(imageFile);

      // Préparer le buffer de sortie (1 résultat avec autant de classes que de labels)
      final outputBuffer = List<List<double>>.filled(
        1,
        List<double>.filled(_labels!.length, 0),
      );

      // Exécuter l'inférence
      _interpreter!.run(processedImage, outputBuffer);

      // Traiter les résultats
      final result = outputBuffer[0];

      // Créer une liste de résultats triés par confiance
      final List<FishClassificationResult> allResults = [];

      for (int i = 0; i < result.length; i++) {
        if (i < _labels!.length) {
          allResults.add(
            FishClassificationResult(
              espece: _labels![i],
              confiance: result[i],
              source: 'TensorFlow',
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
        source: 'TensorFlow',
        alternatives: alternatives,
      );
    } catch (e) {
      debugPrint('Erreur lors de la prédiction: $e');
      rethrow;
    }
  }

  /// Prétraite l'image pour l'adapter au format attendu par le modèle
  Future<List<List<List<double>>>> _preprocessImage(File imageFile) async {
    // Lire l'image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) throw Exception('Impossible de décoder l\'image');

    // Redimensionner l'image à la taille d'entrée du modèle (224x224 est courant pour les modèles Keras)
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
        // Obtenir les valeurs RGB normalisées
        final pixel = resizedImage.getPixel(x, y);
        final r = pixel.r / 255.0;
        final g = pixel.g / 255.0;
        final b = pixel.b / 255.0;

        // Stocker dans le buffer (format dépendant du modèle)
        inputBuffer[0][y][x * 3] = r;
        inputBuffer[0][y][x * 3 + 1] = g;
        inputBuffer[0][y][x * 3 + 2] = b;
      }
    }

    return inputBuffer;
  }

  /// Libère les ressources
  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
      _isInitialized = false;
    }
  }

  /// Obtient la liste des labels
  List<String> getLabels() {
    if (_labels == null) {
      throw Exception('Les labels n\'ont pas été chargés');
    }
    return List.from(_labels!);
  }
}
