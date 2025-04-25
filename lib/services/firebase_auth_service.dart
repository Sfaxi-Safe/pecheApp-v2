import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seatrace/models/user.dart';
import 'package:seatrace/models/pecheur.dart';
import 'package:seatrace/models/vitirinaire.dart';
import 'package:seatrace/models/maryeur.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Clé pour stocker l'utilisateur dans les préférences partagées
  static const String _userKey = 'current_user';

  // Obtenir l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = json.decode(userJson);
      return User.fromMap(userMap);
    } catch (e) {
      return null;
    }
  }

  // Sauvegarder l'utilisateur courant
  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toMap());
    await prefs.setString(_userKey, userJson);
  }

  // Supprimer l'utilisateur courant
  Future<void> removeCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Connexion
  Future<User?> login(String email, String password) async {
    try {
      // Connexion avec Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) return null;
      
      // Récupérer les données utilisateur depuis Firestore
      final uid = userCredential.user!.uid;
      
      // Vérifier dans la collection users (clients)
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        
        // Vérifier si l'utilisateur est vérifié
        if (userData['isVerified'] != true) {
          throw Exception('Veuillez vérifier votre email avant de vous connecter');
        }
        
        // Vérifier si l'utilisateur est bloqué
        if (userData['isBlocked'] == true) {
          throw Exception('Votre compte a été bloqué. Veuillez contacter l\'administrateur');
        }
        
        final user = User(
          id: uid,
          email: email,
          roles: userData['roles'],
          password: password, // Note: normalement on ne stocke pas le mot de passe
          nom: userData['nom'],
          prenom: userData['prenom'],
          telephone: userData['telephone'],
          isVerified: userData['isVerified'] ?? false,
          isBlocked: userData['isBlocked'] ?? false,
          isValid: userData['isValid'] ?? false,
        );
        
        await saveCurrentUser(user);
        return user;
      }
      
      // Vérifier dans la collection pecheurs
      final pecheurDoc = await _firestore.collection('pecheurs').doc(uid).get();
      if (pecheurDoc.exists) {
        final pecheurData = pecheurDoc.data()!;
        
        // Vérifier si le pêcheur est validé
        if (pecheurData['isValid'] != true) {
          throw Exception('Votre compte est en attente de validation par l\'administrateur');
        }
        
        final user = User(
          id: uid,
          email: email,
          roles: pecheurData['roles'],
          password: password,
          nom: pecheurData['nom'],
          prenom: pecheurData['prenom'],
          telephone: pecheurData['telephone'],
          isVerified: true,
          isBlocked: false,
          isValid: pecheurData['isValid'] ?? false,
        );
        
        await saveCurrentUser(user);
        return user;
      }
      
      // Vérifier dans la collection vitirinaires
      final vitirinaireDoc = await _firestore.collection('vitirinaires').doc(uid).get();
      if (vitirinaireDoc.exists) {
        final vitirinaireData = vitirinaireDoc.data()!;
        
        // Vérifier si le vétérinaire est validé
        if (vitirinaireData['isValid'] != true) {
          throw Exception('Votre compte est en attente de validation par l\'administrateur');
        }
        
        final user = User(
          id: uid,
          email: email,
          roles: vitirinaireData['roles'],
          password: password,
          nom: vitirinaireData['nom'],
          prenom: vitirinaireData['prenom'],
          telephone: vitirinaireData['telephone'],
          isVerified: true,
          isBlocked: false,
          isValid: vitirinaireData['isValid'] ?? false,
        );
        
        await saveCurrentUser(user);
        return user;
      }
      
      // Vérifier dans la collection maryeurs
      final maryeurDoc = await _firestore.collection('maryeurs').doc(uid).get();
      if (maryeurDoc.exists) {
        final maryeurData = maryeurDoc.data()!;
        
        // Vérifier si le maryeur est validé
        if (maryeurData['isValid'] != true) {
          throw Exception('Votre compte est en attente de validation par l\'administrateur');
        }
        
        final user = User(
          id: uid,
          email: email,
          roles: maryeurData['roles'],
          password: password,
          nom: maryeurData['nom'],
          prenom: maryeurData['prenom'],
          telephone: maryeurData['telephone'],
          isVerified: true,
          isBlocked: false,
          isValid: maryeurData['isValid'] ?? false,
        );
        
        await saveCurrentUser(user);
        return user;
      }
      
      // Si l'utilisateur n'est trouvé dans aucune collection
      await _auth.signOut();
      return null;
    } catch (e) {
      print('Erreur de connexion: ${e.toString()}');
      return null;
    }
  }
  
  // Inscription
  Future<User?> register(Map<String, dynamic> userData, String password, String role) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: password,
      );
      
      if (userCredential.user == null) return null;
      
      final uid = userCredential.user!.uid;
      
      // Ajouter les données utilisateur à la collection appropriée
      if (role == 'ROLE_CLIENT') {
        await _firestore.collection('users').doc(uid).set({
          ...userData,
          'roles': '["ROLE_CLIENT"]',
          'isVerified': true,
          'isBlocked': false,
          'isValid': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (role == 'ROLE_PECHEUR') {
        await _firestore.collection('pecheurs').doc(uid).set({
          ...userData,
          'roles': '["ROLE_PECHEUR"]',
          'isValid': false, // Les pêcheurs doivent être validés
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (role == 'ROLE_VETERINAIRE') {
        await _firestore.collection('vitirinaires').doc(uid).set({
          ...userData,
          'roles': '["ROLE_VETERINAIRE"]',
          'isValid': false, // Les vétérinaires doivent être validés
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else if (role == 'ROLE_MARYEUR') {
        await _firestore.collection('maryeurs').doc(uid).set({
          ...userData,
          'roles': '["ROLE_MARYEUR"]',
          'isValid': false, // Les maryeurs doivent être validés
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      // Créer l'objet User
      final user = User(
        id: uid,
        email: userData['email'],
        roles: '["$role"]',
        password: password,
        nom: userData['nom'],
        prenom: userData['prenom'],
        telephone: userData['telephone'],
        isVerified: role == 'ROLE_CLIENT', // Seuls les clients sont vérifiés automatiquement
        isBlocked: false,
        isValid: role == 'ROLE_CLIENT', // Seuls les clients sont validés automatiquement
      );
      
      await saveCurrentUser(user);
      return user;
    } catch (e) {
      print('Erreur d\'inscription: ${e.toString()}');
      return null;
    }
  }
  
  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    await removeCurrentUser();
  }
  
  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
  
  // Rafraîchir les données de l'utilisateur courant
  Future<User?> refreshCurrentUser() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;
    
    try {
      // Récupérer les données à jour depuis Firestore
      User? updatedUser;
      
      if (currentUser.isPecheur()) {
        final pecheurDoc = await _firestore.collection('pecheurs').doc(currentUser.id).get();
        if (pecheurDoc.exists) {
          final pecheurData = pecheurDoc.data()!;
          updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            roles: pecheurData['roles'],
            password: currentUser.password,
            nom: pecheurData['nom'],
            prenom: pecheurData['prenom'],
            telephone: pecheurData['telephone'],
            isVerified: true,
            isBlocked: false,
            isValid: pecheurData['isValid'] ?? false,
          );
        }
      } else if (currentUser.isVeterinaire()) {
        final vitirinaireDoc = await _firestore.collection('vitirinaires').doc(currentUser.id).get();
        if (vitirinaireDoc.exists) {
          final vitirinaireData = vitirinaireDoc.data()!;
          updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            roles: vitirinaireData['roles'],
            password: currentUser.password,
            nom: vitirinaireData['nom'],
            prenom: vitirinaireData['prenom'],
            telephone: vitirinaireData['telephone'],
            isVerified: true,
            isBlocked: false,
            isValid: vitirinaireData['isValid'] ?? false,
          );
        }
      } else if (currentUser.isMaryeur()) {
        final maryeurDoc = await _firestore.collection('maryeurs').doc(currentUser.id).get();
        if (maryeurDoc.exists) {
          final maryeurData = maryeurDoc.data()!;
          updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            roles: maryeurData['roles'],
            password: currentUser.password,
            nom: maryeurData['nom'],
            prenom: maryeurData['prenom'],
            telephone: maryeurData['telephone'],
            isVerified: true,
            isBlocked: false,
            isValid: maryeurData['isValid'] ?? false,
          );
        }
      } else if (currentUser.isClient()) {
        final userDoc = await _firestore.collection('users').doc(currentUser.id).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            roles: userData['roles'],
            password: currentUser.password,
            nom: userData['nom'],
            prenom: userData['prenom'],
            telephone: userData['telephone'],
            isVerified: userData['isVerified'] ?? false,
            isBlocked: userData['isBlocked'] ?? false,
            isValid: userData['isValid'] ?? false,
          );
        }
      }
      
      if (updatedUser != null) {
        await saveCurrentUser(updatedUser);
        return updatedUser;
      }
      
      return currentUser;
    } catch (e) {
      print('Erreur lors du rafraîchissement des données utilisateur: ${e.toString()}');
      return currentUser;
    }
  }
}
