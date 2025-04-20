import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marketplace_user.dart';
import '../models/marketplace_pecheur.dart';

import 'database_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  MarketplaceUser? _currentUser;
  bool _isLoading = false;

  // Getters
  MarketplaceUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isFisherman => _currentUser?.isPecheur ?? false;
  bool get isClient => _currentUser?.isClient ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

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
      final userIdStr = prefs.getString('userId');

      if (userIdStr != null) {
        final userId = int.tryParse(userIdStr);
        if (userId != null) {
          final user = await _dbHelper.getUserById(userId);
          if (user != null) {
            _currentUser = user;
          }
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
  Future<void> _saveUserToPrefs(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId.toString());
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
  Future<bool> register({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String telephone,
    required List<String> roles,
  }) async {
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
      final newUser = MarketplaceUser.create(
        email: email,
        password: hashedPassword,
        nom: nom,
        prenom: prenom,
        telephone: int.tryParse(telephone),
        roles: roles,
        isVerified: true,
        isBlocked: false,
      );

      // Insérer l'utilisateur dans la base de données
      final userId = await _dbHelper.insertUser(newUser);

      // Si c'est un pêcheur, créer également une entrée dans la table pecheur
      if (roles.contains('ROLE_PECHEUR')) {
        final newFisherman = MarketplacePecheur.create(
          nom: nom,
          prenom: prenom,
          adresse: '',
          telephone: telephone,
          email: email,
          userId: userId,
        );

        await _dbHelper.insertFisherman(newFisherman);
      }

      // Mettre à jour l'état d'authentification
      final createdUser = await _dbHelper.getUserById(userId);
      if (createdUser != null) {
        _currentUser = createdUser;
        await _saveUserToPrefs(userId);
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
      if (user.id != null) {
        await _saveUserToPrefs(user.id!);
      }

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
    required String nom,
    required String prenom,
    required String telephone,
    String? photo,
    String? adresse,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        nom: nom,
        prenom: prenom,
        telephone: int.tryParse(telephone),
        photo: photo,
        adresse: adresse,
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
      final updatedUser = _currentUser!.copyWith(password: hashedNewPassword);

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
        final pecheur = MarketplaceUser.create(
          email: 'pecheur@example.com',
          password: _hashPassword('password123'),
          nom: 'Dupont',
          prenom: 'Pierre',
          telephone: 612345678,
          roles: ['ROLE_PECHEUR'],
          isVerified: true,
          isBlocked: false,
          photo: 'assets/images/fisherman.jpg',
        );

        final pecheurId = await _dbHelper.insertUser(pecheur);

        // Créer l'entrée correspondante dans la table pecheur
        final fisherman = MarketplacePecheur.create(
          nom: 'Dupont',
          prenom: 'Pierre',
          adresse: '123 Rue de la Mer',
          telephone: '0612345678',
          email: 'pecheur@example.com',
          bateau: 'Le Grand Bleu',
          licence: 'P12345',
          userId: pecheurId,
        );

        await _dbHelper.insertFisherman(fisherman);
      }

      if (existingClient == null) {
        // Créer un client de test
        final client = MarketplaceUser.create(
          email: 'client@example.com',
          password: _hashPassword('password123'),
          nom: 'Martin',
          prenom: 'Jean',
          telephone: 687654321,
          roles: ['ROLE_CLIENT'],
          isVerified: true,
          isBlocked: false,
          photo: 'assets/images/client.jpg',
        );

        await _dbHelper.insertUser(client);
      }
    } catch (e) {
      print('Erreur lors de l\'ajout des utilisateurs de test: $e');
    }
  }
}
