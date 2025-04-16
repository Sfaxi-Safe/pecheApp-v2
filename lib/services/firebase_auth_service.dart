import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;

class FirebaseAuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  app_user.User? _currentUser;
  bool _isLoading = false;

  // Getters
  app_user.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isFisherman => _currentUser?.userType == 'fisherman';
  bool get isClient => _currentUser?.userType == 'client';

  // Constructeur
  FirebaseAuthService() {
    _initAuthListener();
  }

  // Initialiser l'écouteur d'authentification
  void _initAuthListener() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        // Récupérer les données utilisateur depuis Firestore
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _currentUser = app_user.User(
            id: firebaseUser.uid,
            email: userData['email'] ?? '',
            password: '', // Nous ne stockons pas le mot de passe en clair
            name: userData['name'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            userType: userData['userType'] ?? '',
            profileImageUrl: userData['profileImageUrl'],
            createdAt: userData['createdAt'] != null 
              ? (userData['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
          );
        }
      } catch (e) {
        print('Erreur lors de la récupération des données utilisateur: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // S'inscrire
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String userType,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le document utilisateur dans Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'userType': userType,
        'profileImageUrl': profileImageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Si c'est un pêcheur, créer également une entrée dans la collection fishermen
      if (userType == 'fisherman') {
        // Extraire le prénom et le nom
        final nameParts = name.split(' ');
        final prenom = nameParts.isNotEmpty ? nameParts[0] : '';
        final nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        await _firestore.collection('fishermen').doc(userCredential.user!.uid).set({
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'telephone': phoneNumber,
          'isValid': false, // Par défaut, le pêcheur n'est pas validé
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'inscription: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Se connecter
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Se déconnecter
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le profil de l'utilisateur
  Future<bool> updateProfile({
    required String name,
    required String phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_auth.currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'name': name,
        'phoneNumber': phoneNumber,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });

      // Mettre à jour l'objet utilisateur local
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          phoneNumber: phoneNumber,
          profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Changer le mot de passe
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_auth.currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Vérifier l'ancien mot de passe en se reconnectant
      final credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: oldPassword,
      );
      
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      
      // Mettre à jour le mot de passe
      await _auth.currentUser!.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ajouter des utilisateurs de test pour le développement
  Future<void> addTestUsers() async {
    try {
      // Vérifier si les utilisateurs de test existent déjà
      final pecheurQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'pecheur@example.com')
          .limit(1)
          .get();
      
      final clientQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'client@example.com')
          .limit(1)
          .get();

      if (pecheurQuery.docs.isEmpty) {
        try {
          // Créer un pêcheur de test dans Firebase Auth
          final pecheurCredential = await _auth.createUserWithEmailAndPassword(
            email: 'pecheur@example.com',
            password: 'password123',
          );

          // Créer le document utilisateur dans Firestore
          await _firestore.collection('users').doc(pecheurCredential.user!.uid).set({
            'email': 'pecheur@example.com',
            'name': 'Pierre Dupont',
            'phoneNumber': '0612345678',
            'userType': 'fisherman',
            'profileImageUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Créer l'entrée correspondante dans la collection fishermen
          await _firestore.collection('fishermen').doc(pecheurCredential.user!.uid).set({
            'email': 'pecheur@example.com',
            'nom': 'Dupont',
            'prenom': 'Pierre',
            'telephone': '0612345678',
            'isValid': true,
          });
        } catch (e) {
          print('Erreur lors de la création du pêcheur de test: $e');
        }
      }

      if (clientQuery.docs.isEmpty) {
        try {
          // Créer un client de test dans Firebase Auth
          final clientCredential = await _auth.createUserWithEmailAndPassword(
            email: 'client@example.com',
            password: 'password123',
          );

          // Créer le document utilisateur dans Firestore
          await _firestore.collection('users').doc(clientCredential.user!.uid).set({
            'email': 'client@example.com',
            'name': 'Jean Martin',
            'phoneNumber': '0687654321',
            'userType': 'client',
            'profileImageUrl': 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Erreur lors de la création du client de test: $e');
        }
      }
    } catch (e) {
      print('Erreur lors de l\'ajout des utilisateurs de test: $e');
    }
  }
}
