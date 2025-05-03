import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
      _interpreter = await Interpreter.fromFile(
        File(modelPath),
        options: options,
      );
      
      _isInitialized = true;
      debugPrint('Modèle TensorFlow initialisé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du modèle TensorFlow: $e');
      
      // En cas d'erreur avec le GPU, essayer avec CPU seulement
      try {
        final modelPath = await _getModelPath();
        final options = InterpreterOptions();
        _interpreter = await Interpreter.fromFile(
          File(modelPath),
          options: options,
        );
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
        _labels = labelsContent.split('\n')
            .where((line) => line.isNotEmpty)
            .map((line) {
              // Format attendu: "0 baliste"
              final parts = line.trim().split(' ');
              if (parts.length > 1) {
                return parts.sublist(1).join(' '); // Prendre tout sauf l'index
              }
              return line;
            })
            .toList();
        
        debugPrint('Labels chargés: ${_labels!.length} espèces');
      } else {
        throw Exception('Fichier de labels non trouvé');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des labels: $e');
      rethrow;
    }
  }
  
  /// Obtient le chemin du modèle
  Future<String> _getModelPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'models', 'keras_model.h5');
  }
  
  /// Prédit l'espèce de poisson à partir d'une image
  Future<Map<String, dynamic>> predictFish(File imageFile) async {
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
      
      // Trouver l'indice de la classe avec la plus haute probabilité
      int maxIndex = 0;
      double maxProb = result[0];
      
      for (int i = 1; i < result.length; i++) {
        if (result[i] > maxProb) {
          maxProb = result[i];
          maxIndex = i;
        }
      }
      
      // Retourner le résultat
      return {
        'espece': _labels![maxIndex],
        'confiance': maxProb,
        'resultats': Map.fromIterables(
          _labels!,
          result.map((prob) => prob * 100).toList(),
        ),
      };
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
        final r = img.getRed(pixel) / 255.0;
        final g = img.getGreen(pixel) / 255.0;
        final b = img.getBlue(pixel) / 255.0;
        
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
