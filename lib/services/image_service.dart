import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      // Obtenir le token d'authentification
      final headers = await AuthService().getAuthHeaders();
      
      // Créer une requête multipart
      final uri = Uri.parse('${ApiService.instance.baseUrl}/images/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Ajouter les headers d'authentification
      request.headers.addAll(headers);
      
      // Ajouter le fichier à la requête
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));
      
      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['imageUrl'];
      } else {
        debugPrint('Erreur lors du téléchargement de l\'image: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception lors du téléchargement de l\'image: $e');
      return null;
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
      final fullUrl = imageUrl.startsWith('http')
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
        debugPrint('Erreur lors du téléchargement de l\'image: ${response.statusCode}');
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
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Si c'est déjà une URL complète, la retourner
    if (imagePath.startsWith('http')) return imagePath;
    
    // Si c'est un chemin relatif à l'API, construire l'URL complète
    if (imagePath.startsWith('/api/')) {
      return '${ApiService.instance.baseUrl.split('/api').first}$imagePath';
    }
    
    // Sinon, c'est un nom de fichier, construire l'URL complète
    return '${ApiService.instance.baseUrl}/images/$imagePath';
  }
}
