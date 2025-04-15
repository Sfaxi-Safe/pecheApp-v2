import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/fisherman.dart';
import 'database_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isFisherman => _currentUser?.userType == 'fisherman';
  bool get isClient => _currentUser?.userType == 'client';

  // Constructeur
  AuthService() {
    _loadUserFromPrefs();
  }

  // Charger l'utilisateur depuis les préférences partagées
  Future<void> _loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final user = await _dbHelper.getUserById(userId);
        if (user != null) {
          _currentUser = user;
        }
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sauvegarder l'ID de l'utilisateur dans les préférences partagées
  Future<void> _saveUserToPrefs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'utilisateur: $e');
    }
  }

  // Supprimer l'ID de l'utilisateur des préférences partagées
  Future<void> _removeUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Hacher un mot de passe
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // S'inscrire
  Future<bool> register(
    String email,
    String password,
    String name,
    String phoneNumber,
    String userType,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Vérifier si l'email existe déjà
      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Hacher le mot de passe
      final hashedPassword = _hashPassword(password);

      // Créer un nouvel utilisateur
      final userId = const Uuid().v4();
      final newUser = User(
        id: userId,
        email: email,
        password: hashedPassword,
        name: name,
        phoneNumber: phoneNumber,
        userType: userType,
        createdAt: DateTime.now(),
      );

      // Insérer l'utilisateur dans la base de données
      await _dbHelper.insertUser(newUser);

      // Si c'est un pêcheur, créer également une entrée dans la table fishermen
      if (userType == 'fisherman') {
        // Extraire le prénom et le nom
        final nameParts = name.split(' ');
        final prenom = nameParts.isNotEmpty ? nameParts[0] : '';
        final nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final newFisherman = Fisherman(
          id: userId,
          email: email,
          nom: nom,
          prenom: prenom,
          telephone: phoneNumber,
          isValid: false, // Par défaut, le pêcheur n'est pas validé
        );

        await _dbHelper.insertFisherman(newFisherman);
      }

      // Mettre à jour l'état d'authentification
      _currentUser = newUser;
      await _saveUserToPrefs(userId);

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
      // Récupérer l'utilisateur par email
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Vérifier le mot de passe
      final hashedPassword = _hashPassword(password);
      if (user.password != hashedPassword) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Mettre à jour l'état d'authentification
      _currentUser = user;
      await _saveUserToPrefs(user.id);

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
      _currentUser = null;
      await _removeUserFromPrefs();
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
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;

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
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Vérifier l'ancien mot de passe
      final hashedOldPassword = _hashPassword(oldPassword);
      if (_currentUser!.password != hashedOldPassword) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Mettre à jour le mot de passe
      final hashedNewPassword = _hashPassword(newPassword);
      final updatedUser = _currentUser!.copyWith(
        password: hashedNewPassword,
      );

      await _dbHelper.updateUser(updatedUser);
      _currentUser = updatedUser;

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
      final existingPecheur = await _dbHelper.getUserByEmail('pecheur@example.com');
      final existingClient = await _dbHelper.getUserByEmail('client@example.com');

      if (existingPecheur == null) {
        // Créer un pêcheur de test
        final pecheurId = const Uuid().v4();
        final pecheur = User(
          id: pecheurId,
          email: 'pecheur@example.com',
          password: _hashPassword('password123'),
          name: 'Pierre Dupont',
          phoneNumber: '0612345678',
          userType: 'fisherman',
          profileImageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );

        await _dbHelper.insertUser(pecheur);

        // Créer l'entrée correspondante dans la table fishermen
        final fisherman = Fisherman(
          id: pecheurId,
          email: 'pecheur@example.com',
          nom: 'Dupont',
          prenom: 'Pierre',
          telephone: '0612345678',
          isValid: true,
        );

        await _dbHelper.insertFisherman(fisherman);
      }

      if (existingClient == null) {
        // Créer un client de test
        final client = User(
          id: const Uuid().v4(),
          email: 'client@example.com',
          password: _hashPassword('password123'),
          name: 'Jean Martin',
          phoneNumber: '0687654321',
          userType: 'client',
          profileImageUrl: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        );

        await _dbHelper.insertUser(client);
      }
    } catch (e) {
      print('Erreur lors de l\'ajout des utilisateurs de test: $e');
    }
  }
}
