import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Télécharger une image de poisson
  Future<String> uploadFishImage(File imageFile) async {
    final String fileName = '${_uuid.v4()}.jpg';
    final Reference storageRef = _storage.ref().child('fish_images/$fileName');
    
    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask;
    
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  
  // Télécharger une image de profil
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    final String fileName = '$userId.jpg';
    final Reference storageRef = _storage.ref().child('profile_images/$fileName');
    
    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot taskSnapshot = await uploadTask;
    
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  
  // Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: ${e.toString()}');
    }
  }
}
