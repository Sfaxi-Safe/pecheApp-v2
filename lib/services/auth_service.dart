import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:seatrace/models/user.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seatrace/dtos/user_dto.dart';

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

      // Journaliser l'action
      ErrorHandler.instance.logInfo(
        'Récupération de l\'utilisateur actuel',
        context: 'AuthService',
      );

      final response = await ApiService.instance.get('auth/me');

      if (response.containsKey('user')) {
        final user = User.fromMap(response['user']);

        // Vérifier si les informations de base sont présentes
        if (user.nom.isEmpty || user.prenom.isEmpty) {
          ErrorHandler.instance.logWarning(
            'Informations utilisateur incomplètes: nom=${user.nom}, prenom=${user.prenom}',
            context: 'AuthService.getCurrentUser',
          );
        } else {
          ErrorHandler.instance.logInfo(
            'Utilisateur récupéré avec succès: ${user.prenom} ${user.nom}',
            context: 'AuthService.getCurrentUser',
          );
        }

        return user;
      } else {
        ErrorHandler.instance.logWarning(
          'Réponse API sans utilisateur: ${response.toString()}',
          context: 'AuthService.getCurrentUser',
        );
      }
    } on AppError catch (e) {
      // Si c'est une erreur d'authentification, déconnecter l'utilisateur
      if (e.type == ErrorType.authentication ||
          e.type == ErrorType.authorization) {
        ErrorHandler.instance.logWarning(
          'Session expirée, déconnexion de l\'utilisateur',
          context: 'AuthService',
        );
        await logout();
      } else {
        ErrorHandler.instance.logError(
          e,
          context: 'AuthService.getCurrentUser',
        );
      }
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'AuthService.getCurrentUser');
      await logout(); // Déconnexion en cas d'erreur
    }
    return null;
  }

  /// Obtenir l'utilisateur actuel sous forme de DTO
  Future<UserDto?> getCurrentUserDto() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return null;

      return UserDto(
        id: user.id,
        email: user.email,
        roles: user.roles.split(','),
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone?.toString(),
        photo: user.photo,
        isValidated: user.isValidated,
        isBlocked: user.isBlocked,
      );
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'AuthService.getCurrentUserDto',
      );
      return null;
    }
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
      // Journaliser l'action
      ErrorHandler.instance.logInfo(
        'Tentative de connexion: $email',
        context: 'AuthService',
      );

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

        // Journaliser le succès
        ErrorHandler.instance.logInfo(
          'Connexion réussie: ${user.email}',
          context: 'AuthService',
        );

        return user;
      } else {
        throw AppError(
          message: 'Informations de connexion invalides',
          type: ErrorType.authentication,
          context: 'AuthService.login',
        );
      }
    } on AppError catch (e) {
      ErrorHandler.instance.logError(e, context: 'AuthService.login');
      rethrow;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'AuthService.login');
      throw AppError(
        message: 'Erreur lors de la connexion: ${e.toString()}',
        type: ErrorType.unknown,
        originalError: e,
        context: 'AuthService.login',
      );
    }
  }

  /// Connexion avec retour de DTO
  Future<UserDto?> loginDto(String email, String password) async {
    try {
      final user = await login(email, password);
      if (user == null) return null;

      return UserDto(
        id: user.id,
        email: user.email,
        roles: user.roles.split(','),
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone?.toString(),
        photo: user.photo,
        isValidated: user.isValidated,
        isBlocked: user.isBlocked,
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'AuthService.loginDto');
      rethrow;
    }
  }

  /// Rafraîchir l'utilisateur actuel
  Future<User?> refreshCurrentUser() async {
    try {
      // Journaliser l'action
      ErrorHandler.instance.logInfo(
        'Rafraîchissement des données utilisateur',
        context: 'AuthService',
      );

      final response = await ApiService.instance.get('auth/me');
      if (response.containsKey('user')) {
        final updatedUser = User.fromMap(response['user']);
        await saveCurrentUser(updatedUser);
        return updatedUser;
      } else {
        throw AppError(
          message: 'Impossible de récupérer les données utilisateur',
          type: ErrorType.notFound,
          context: 'AuthService.refreshCurrentUser',
        );
      }
    } on AppError catch (e) {
      // Si c'est une erreur d'authentification, déconnecter l'utilisateur
      if (e.type == ErrorType.authentication ||
          e.type == ErrorType.authorization) {
        ErrorHandler.instance.logWarning(
          'Session expirée, déconnexion de l\'utilisateur',
          context: 'AuthService',
        );
        await logout();
      } else {
        ErrorHandler.instance.logError(
          e,
          context: 'AuthService.refreshCurrentUser',
        );
      }
      return null;
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'AuthService.refreshCurrentUser',
      );
      return null;
    }
  }

  /// Réinitialisation du mot de passe
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      // Journaliser l'action
      ErrorHandler.instance.logInfo(
        'Tentative de réinitialisation du mot de passe: $email',
        context: 'AuthService',
      );

      final response = await ApiService.instance.post('auth/reset-password', {
        'email': email,
        'newPassword': newPassword,
      });

      final success = response['success'] ?? false;

      if (success) {
        ErrorHandler.instance.logInfo(
          'Réinitialisation du mot de passe réussie: $email',
          context: 'AuthService',
        );
      } else {
        ErrorHandler.instance.logWarning(
          'Échec de la réinitialisation du mot de passe: $email',
          context: 'AuthService',
        );
      }

      return success;
    } on AppError catch (e) {
      ErrorHandler.instance.logError(e, context: 'AuthService.resetPassword');
      rethrow;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'AuthService.resetPassword');
      throw AppError(
        message:
            'Erreur lors de la réinitialisation du mot de passe: ${e.toString()}',
        type: ErrorType.unknown,
        originalError: e,
        context: 'AuthService.resetPassword',
      );
    }
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
