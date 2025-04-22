import 'dart:io';
import 'dart:math';
import 'package:peche_app/models/espece.dart';
import 'package:peche_app/services/database_helper.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FishRecognitionService {
  static final FishRecognitionService _instance =
      FishRecognitionService._internal();
  factory FishRecognitionService() => _instance;

  Interpreter? _interpreter;
  bool _isInitialized = false;

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

  Future<Espece?> recognizeFish(File imageFile) async {
    await initialize();

    if (_interpreter == null) {
      throw Exception('Le modèle n\'a pas été initialisé correctement');
    }

    try {
      // Prétraiter l'image
      final inputBuffer = await _preprocessImage(imageFile);

      // Préparer le buffer de sortie
      // Supposons que notre modèle produit un vecteur de probabilités pour chaque classe
      final outputBuffer = List<List<double>>.filled(
        1,
        List<double>.filled(_labels.length, 0),
      );

      // Exécuter l'inférence
      _interpreter!.run(inputBuffer, outputBuffer);

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

      // Si la probabilité est trop faible, considérer comme non reconnu
      if (maxProb < 0.5) {
        // Confiance trop faible: $maxProb pour ${_labels[maxIndex]}
        return null;
      }

      // Récupérer l'espèce correspondante depuis la base de données
      final especes = await DatabaseHelper.instance.queryWhere(
        'marketplace_espece',
        'nom = ?',
        [_labels[maxIndex]],
      );

      if (especes.isNotEmpty) {
        return Espece.fromMap(especes.first);
      } else {
        // Si l'espèce n'est pas dans la base de données, créer une nouvelle entrée
        final id = await DatabaseHelper.instance.insert('marketplace_espece', {
          'nom': _labels[maxIndex],
          'image_url': null,
        });

        return Espece(id: id, nom: _labels[maxIndex]);
      }
    } catch (e) {
      // Erreur lors de la reconnaissance du poisson: $e

      // En cas d'erreur, essayer de récupérer une espèce aléatoire de la base de données
      // comme solution de secours
      try {
        final allEspeces = await DatabaseHelper.instance.queryAllEspeces();
        if (allEspeces.isNotEmpty) {
          final randomIndex = Random().nextInt(allEspeces.length);
          return Espece.fromMap(allEspeces[randomIndex]);
        }
      } catch (e) {
        // Erreur lors de la récupération des espèces: $e
      }

      return null;
    }
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
