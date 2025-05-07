import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Types d'erreurs spécifiques pour l'application
enum ErrorType {
  network,
  authentication,
  authorization,
  notFound,
  validation,
  server,
  unknown,
}

/// Classe pour représenter une erreur de l'application
class AppError extends Error {
  final String message;
  final ErrorType type;
  final dynamic originalError;
  @override
  final StackTrace? stackTrace;
  final String? context;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
    this.stackTrace,
    this.context, int? statusCode,
  });

  @override
  String toString() {
    return 'AppError: $message (Type: $type)';
  }
}

/// Gestionnaire d'erreurs centralisé pour l'application
class ErrorHandler {
  static final ErrorHandler instance = ErrorHandler._internal();

  ErrorHandler._internal();

  /// Niveau de journalisation
  /// - 0: Aucune journalisation
  /// - 1: Erreurs seulement
  /// - 2: Erreurs et avertissements
  /// - 3: Tout (erreurs, avertissements, informations)
  int logLevel = 3;

  /// Convertit une exception en AppError
  AppError handleException(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    // Erreurs réseau
    if (error is SocketException ||
        error is HttpException ||
        error is TimeoutException) {
      return AppError(
        message:
            'Problème de connexion réseau. Veuillez vérifier votre connexion internet.',
        type: ErrorType.network,
        originalError: error,
        stackTrace: stackTrace,
        context: context,
      );
    }

    // Erreurs HTTP
    if (error is http.Response ||
        (error is Exception && error.toString().contains('StatusCode'))) {
      return _handleHttpError(error, stackTrace: stackTrace, context: context);
    }

    // Erreurs de format JSON
    if (error is FormatException) {
      return AppError(
        message: 'Erreur de format de données.',
        type: ErrorType.server,
        originalError: error,
        stackTrace: stackTrace,
        context: context,
      );
    }

    // Erreurs d'authentification
    if (error.toString().contains('auth') ||
        error.toString().contains('token') ||
        error.toString().contains('connexion')) {
      return AppError(
        message: 'Erreur d\'authentification. Veuillez vous reconnecter.',
        type: ErrorType.authentication,
        originalError: error,
        stackTrace: stackTrace,
        context: context,
      );
    }

    // Erreurs génériques
    return AppError(
      message: _getUserFriendlyMessage(error),
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Gère les erreurs HTTP spécifiquement
  AppError _handleHttpError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    int statusCode = 0;
    String errorMessage = '';

    if (error is http.Response) {
      statusCode = error.statusCode;
      try {
        final errorBody = json.decode(error.body);
        errorMessage =
            errorBody['message'] ?? errorBody['error'] ?? 'Erreur serveur';
      } catch (e) {
        errorMessage = error.reasonPhrase ?? 'Erreur serveur';
      }
    } else {
      // Extraire le code d'état de l'exception
      final errorString = error.toString();
      final statusCodeMatch = RegExp(
        r'StatusCode: (\d+)',
      ).firstMatch(errorString);
      if (statusCodeMatch != null) {
        statusCode = int.parse(statusCodeMatch.group(1)!);
      }
      errorMessage = errorString;
    }

    // Déterminer le type d'erreur en fonction du code d'état
    ErrorType errorType;
    String userMessage;

    switch (statusCode) {
      case 400:
        errorType = ErrorType.validation;
        userMessage = 'Données invalides: $errorMessage';
        break;
      case 401:
        errorType = ErrorType.authentication;
        userMessage = 'Authentification requise. Veuillez vous reconnecter.';
        break;
      case 403:
        errorType = ErrorType.authorization;
        userMessage =
            'Vous n\'avez pas les droits nécessaires pour cette action.';
        break;
      case 404:
        errorType = ErrorType.notFound;
        userMessage = 'La ressource demandée n\'existe pas.';
        break;
      case 422:
        errorType = ErrorType.validation;
        userMessage = 'Données invalides: $errorMessage';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        errorType = ErrorType.server;
        userMessage = 'Erreur serveur. Veuillez réessayer plus tard.';
        break;
      default:
        errorType = ErrorType.unknown;
        userMessage = 'Une erreur est survenue: $errorMessage';
    }

    return AppError(
      message: userMessage,
      type: errorType,
      originalError: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Convertit un message d'erreur technique en message convivial pour l'utilisateur
  String _getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString();

    // Messages d'erreur spécifiques
    if (errorString.contains('Connection refused') ||
        errorString.contains('SocketException') ||
        errorString.contains('Connection timed out')) {
      return 'Impossible de se connecter au serveur. Veuillez vérifier votre connexion internet.';
    }

    if (errorString.contains('No such host')) {
      return 'Serveur introuvable. Veuillez vérifier votre connexion internet.';
    }

    if (errorString.contains('token') || errorString.contains('JWT')) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Vous n\'avez pas les permissions nécessaires pour cette action.';
    }

    // Message générique pour les autres erreurs
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Journalise une erreur
  void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    if (logLevel < 1) return;

    final errorToLog =
        error is AppError
            ? error
            : handleException(error, stackTrace: stackTrace, context: context);

    // Format de journalisation
    final timestamp = DateTime.now().toIso8601String();
    final errorType = errorToLog.type.toString().split('.').last;
    final errorMessage = errorToLog.message;
    final errorContext = errorToLog.context ?? context ?? 'Unknown';
    final originalError =
        errorToLog.originalError?.toString() ?? 'No original error';

    // Journaliser l'erreur
    debugPrint(
      '[$timestamp] ERROR [$errorType] [$errorContext]: $errorMessage',
    );
    debugPrint('Original error: $originalError');

    if (errorToLog.stackTrace != null) {
      debugPrint('Stack trace:');
      debugPrint(errorToLog.stackTrace.toString());
    }
  }

  /// Journalise un avertissement
  void logWarning(String message, {String? context}) {
    if (logLevel < 2) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] WARNING [$context]: $message');
  }

  /// Journalise une information
  void logInfo(String message, {String? context}) {
    if (logLevel < 3) return;

    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] INFO [$context]: $message');
  }

  /// Affiche un message d'erreur dans un SnackBar
  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Affiche un message d'erreur dans une boîte de dialogue
  Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Gère une erreur et affiche un message approprié
  void handleAndShowError(
    BuildContext context,
    dynamic error, {
    String? errorContext,
    bool showDialog = false,
    VoidCallback? onDismiss,
  }) {
    final appError =
        error is AppError
            ? error
            : handleException(error, context: errorContext);

    // Journaliser l'erreur
    logError(appError);

    // Afficher l'erreur à l'utilisateur
    if (showDialog) {
      showErrorDialog(context, 'Erreur', appError.message).then((_) {
        if (onDismiss != null) onDismiss();
      });
    } else {
      showErrorSnackBar(context, appError.message);
      if (onDismiss != null) {
        // Attendre un court instant pour que le SnackBar soit visible
        Future.delayed(const Duration(milliseconds: 300), onDismiss);
      }
    }
  }

  /// Gère spécifiquement les erreurs d'API
  Future<T?> handleApiCall<T>(
    BuildContext context,
    Future<T> Function() apiCall, {
    String? loadingMessage,
    String? successMessage,
    String? errorContext,
    bool showErrorDialog = false,
    bool showSuccessMessage = true,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    // Capturer le ScaffoldMessenger actuel pour éviter les problèmes de contexte
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Afficher un indicateur de chargement si demandé
    if (loadingMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(loadingMessage),
            ],
          ),
          duration: const Duration(
            days: 1,
          ), // Longue durée pour ne pas disparaître
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      // Exécuter l'appel API
      final result = await apiCall();

      // Vérifier si le widget est toujours monté
      if (!context.mounted) return result;

      // Masquer l'indicateur de chargement
      if (loadingMessage != null) {
        scaffoldMessenger.hideCurrentSnackBar();
      }

      // Afficher un message de succès si demandé
      if (successMessage != null && showSuccessMessage) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Appeler le callback de succès si fourni
      if (onSuccess != null) {
        onSuccess();
      }

      return result;
    } catch (error) {
      // Vérifier si le widget est toujours monté
      if (!context.mounted) return null;

      // Masquer l'indicateur de chargement
      if (loadingMessage != null) {
        scaffoldMessenger.hideCurrentSnackBar();
      }

      // Gérer et afficher l'erreur
      handleAndShowError(
        context,
        error,
        errorContext: errorContext,
        showDialog: showErrorDialog,
        onDismiss: onError,
      );

      return null;
    }
  }
}
