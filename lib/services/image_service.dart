import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/auth_service.dart';

class ImageService {
  static final ImageService instance = ImageService._init();

  ImageService._init();

  /// Télécharge une image sur le serveur et retourne l'URL de l'image
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Vérifier si le fichier existe
      if (!await imageFile.exists()) {
        debugPrint('Erreur: Le fichier image n\'existe pas');
        throw Exception('Le fichier image n\'existe pas');
      }

      // Vérifier la taille du fichier
      final fileSize = await imageFile.length();
      debugPrint('Taille originale du fichier: ${fileSize / 1024} KB');

      // Compresser l'image si elle est trop grande
      File fileToUpload = imageFile;
      if (fileSize > 2 * 1024 * 1024) {
        // 2 MB
        debugPrint('Image trop grande, compression en cours...');
        try {
          // Lire l'image
          final List<int> imageBytes = await imageFile.readAsBytes();
          final img.Image? originalImage = img.decodeImage(
            Uint8List.fromList(imageBytes),
          );

          if (originalImage != null) {
            // Réduire la qualité et la taille si nécessaire
            int quality = 80; // Qualité de compression (0-100)

            if (fileSize > 4 * 1024 * 1024) {
              quality =
                  60; // Réduire davantage pour les fichiers très volumineux
            }

            // Redimensionner si l'image est très grande
            img.Image resizedImage = originalImage;
            if (originalImage.width > 1200 || originalImage.height > 1200) {
              resizedImage = img.copyResize(
                originalImage,
                width:
                    originalImage.width > originalImage.height
                        ? 1200
                        : (1200 * originalImage.width ~/ originalImage.height),
                height:
                    originalImage.height > originalImage.width
                        ? 1200
                        : (1200 * originalImage.height ~/ originalImage.width),
              );
            }

            // Encoder en JPEG avec la qualité réduite
            final List<int> compressedBytes = img.encodeJpg(
              resizedImage,
              quality: quality,
            );

            // Créer un fichier temporaire pour stocker l'image compressée
            final tempDir = await getTemporaryDirectory();
            final tempPath = path.join(
              tempDir.path,
              'compressed_${path.basename(imageFile.path)}',
            );
            fileToUpload = await File(tempPath).writeAsBytes(compressedBytes);

            final compressedSize = await fileToUpload.length();
            debugPrint(
              'Image compressée: ${compressedSize / 1024} KB (réduction de ${(1 - compressedSize / fileSize) * 100}%)',
            );
          } else {
            debugPrint('Impossible de décoder l\'image pour la compression');
          }
        } catch (e) {
          debugPrint('Erreur lors de la compression de l\'image: $e');
          // Continuer avec le fichier original si la compression échoue
        }
      }

      // Vérifier à nouveau la taille après compression
      final finalFileSize = await fileToUpload.length();
      if (finalFileSize > 5 * 1024 * 1024) {
        // 5 MB
        debugPrint(
          'Erreur: Taille du fichier toujours trop grande après compression: ${finalFileSize / 1024 / 1024} MB',
        );
        throw Exception(
          'La taille de l\'image ne doit pas dépasser 5 MB. Veuillez choisir une image plus petite.',
        );
      }

      // Obtenir le token d'authentification
      final headers = await AuthService().getAuthHeaders();

      // Vérifier si le token est présent
      if (!headers.containsKey('Authorization')) {
        debugPrint('Erreur: Token d\'authentification manquant');
        throw Exception('Vous devez être connecté pour télécharger une image');
      }

      // Créer une requête multipart
      final uri = Uri.parse('${ApiService.instance.baseUrl}/images/upload');
      debugPrint('Téléchargement de l\'image vers: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Ajouter les headers d'authentification
      request.headers.addAll(headers);

      // Ajouter le fichier à la requête
      final filename = path.basename(fileToUpload.path);
      debugPrint(
        'Nom du fichier: $filename, Taille finale: ${finalFileSize / 1024} KB',
      );

      // Vérifier l'extension du fichier
      final ext = path.extension(filename).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      if (!validExtensions.contains(ext)) {
        debugPrint('Extension de fichier non supportée: $ext');
        throw Exception(
          'Format d\'image non supporté. Utilisez JPG, PNG, GIF ou WebP.',
        );
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          fileToUpload.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}$ext',
          contentType: MediaType(
            'image',
            ext.substring(1),
          ), // Définir explicitement le type MIME
        ),
      );

      // Envoyer la requête avec timeout
      debugPrint('Envoi de la requête...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Délai d\'attente dépassé lors du téléchargement de l\'image',
          );
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Réponse reçue: ${response.statusCode}');

      if (response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          if (data.containsKey('imageUrl')) {
            debugPrint('Image téléchargée avec succès: ${data['imageUrl']}');
            return data['imageUrl'];
          } else {
            debugPrint('Réponse invalide: imageUrl manquant dans la réponse');
            throw Exception('Format de réponse invalide du serveur');
          }
        } catch (e) {
          debugPrint('Erreur lors du décodage de la réponse: $e');
          throw Exception('Erreur lors du traitement de la réponse du serveur');
        }
      } else {
        String errorMessage = 'Erreur serveur: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {
          // Ignorer les erreurs de décodage JSON
        }

        debugPrint('Erreur lors du téléchargement de l\'image: $errorMessage');
        debugPrint('Détails: ${response.body}');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Exception lors du téléchargement de l\'image: $e');
      rethrow; // Propager l'erreur pour une meilleure gestion
    }
  }

  /// Télécharge une image depuis le serveur et la sauvegarde localement
  Future<File?> downloadImage(String imageUrl) async {
    try {
      // Vérifier si l'URL est valide
      if (imageUrl.isEmpty) return null;

      // Si l'URL est déjà un chemin local, retourner le fichier
      if (imageUrl.startsWith('/')) {
        final file = File(imageUrl);
        if (await file.exists()) return file;
      }

      // Construire l'URL complète si nécessaire
      final fullUrl =
          imageUrl.startsWith('http')
              ? imageUrl
              : '${ApiService.instance.baseUrl}$imageUrl';

      // Télécharger l'image
      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode == 200) {
        // Sauvegarder l'image localement
        final appDir = await getApplicationDocumentsDirectory();
        final filename = path.basename(imageUrl);
        final file = File(path.join(appDir.path, filename));

        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        debugPrint(
          'Erreur lors du téléchargement de l\'image: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  /// Supprime une image du serveur
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Vérifier si l'URL est valide
      if (imageUrl.isEmpty) return false;

      // Extraire le nom du fichier de l'URL
      final filename = path.basename(imageUrl);

      // Obtenir le token d'authentification
      final headers = await AuthService().getAuthHeaders();

      // Envoyer la requête de suppression
      final response = await http.delete(
        Uri.parse('${ApiService.instance.baseUrl}/images/$filename'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Exception lors de la suppression de l\'image: $e');
      return false;
    }
  }

  /// Construit l'URL complète d'une image
  String getImageUrl(String? imagePath) {
    // Déléguer à la méthode getImageUrl de ApiService pour assurer la cohérence
    return ApiService.instance.getImageUrl(imagePath);
  }

  /// Teste la connexion au serveur d'upload d'images
  Future<bool> testImageUploadConnection() async {
    try {
      debugPrint('Test de connexion au serveur d\'upload d\'images...');

      // Vérifier si le token d'authentification est disponible
      final headers = await AuthService().getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        debugPrint('Erreur: Token d\'authentification manquant');
        return false;
      }

      // Tester la connexion au serveur
      final uri = Uri.parse('${ApiService.instance.baseUrl}/images/test');
      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Timeout lors du test de connexion');
              return http.Response('{"error":"Timeout"}', 408);
            },
          );

      debugPrint('Réponse du test de connexion: ${response.statusCode}');

      // Si le serveur répond avec un code 404, c'est normal car l'endpoint de test n'existe pas
      // mais cela confirme que le serveur est accessible
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      debugPrint('Erreur lors du test de connexion: $e');
      return false;
    }
  }
}
