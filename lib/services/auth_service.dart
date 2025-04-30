import 'dart:convert';
import 'package:seatrace/models/user.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _userKey = 'current_user';

  /// Obtenir l'utilisateur actuel
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return null;

      ApiService.instance.setAuthToken(token);
      final response = await ApiService.instance.get('auth/me');

      if (response.containsKey('user')) {
        return User.fromMap(response['user']);
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      await logout(); // Déconnexion en cas d'erreur
    }
    return null;
  }

  /// Sauvegarder l'utilisateur actuel
  Future<void> saveCurrentUser(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(updatedUser.toMap()));
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove('auth_token');
    ApiService.instance.setAuthToken(null);
  }

  /// Connexion
  Future<User?> login(String email, String password) async {
    try {
      final response = await ApiService.instance.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response.containsKey('token') && response.containsKey('user')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        ApiService.instance.setAuthToken(response['token']);
        final user = User.fromMap(response['user']);
        await saveCurrentUser(user);
        return user;
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
    }
    return null;
  }

  /// Rafraîchir l'utilisateur actuel
  Future<User?> refreshCurrentUser() async {
    try {
      final response = await ApiService.instance.get('auth/me');
      if (response.containsKey('user')) {
        final updatedUser = User.fromMap(response['user']);
        await saveCurrentUser(updatedUser);
        return updatedUser;
      }
    } catch (e) {
      print('Erreur lors du rafraîchissement des données utilisateur: $e');
    }
    return null;
  }

  /// Réinitialisation du mot de passe
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await ApiService.instance.post('auth/reset-password', {
        'email': email,
        'newPassword': newPassword,
      });
      return response['success'] ?? false;
    } catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe: $e');
    }
    return false;
  }

  /// En-têtes d'authentification pour les requêtes API
  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return {};

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

