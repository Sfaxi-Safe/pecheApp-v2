import 'package:flutter/material.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/screens/notifications_screen.dart';

/// Service pour gérer la navigation dans l'application SeaTrace
class NavigationService {
  /// Instance singleton du service de navigation
  static final NavigationService _instance = NavigationService._internal();

  /// Constructeur factory pour accéder à l'instance singleton
  factory NavigationService() => _instance;

  /// Constructeur interne pour l'instance singleton
  NavigationService._internal();

  /// Service d'animation pour les transitions
  final AnimationService _animationService = AnimationService();

  /// Navigue vers un nouvel écran avec une animation de fondu
  Future<T?> navigateToWithFade<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: false,
        slideLeft: false,
      ),
    );
  }

  /// Navigue vers un nouvel écran avec une animation de glissement vers le haut
  Future<T?> navigateToWithSlideUp<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: true,
        slideLeft: false,
      ),
    );
  }

  /// Navigue vers un nouvel écran avec une animation de glissement vers la gauche
  Future<T?> navigateToWithSlideLeft<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).push<T>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: false,
        slideLeft: true,
      ),
    );
  }

  /// Remplace l'écran actuel par un nouvel écran avec une animation de fondu
  Future<T?> replaceWithFade<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: false,
        slideLeft: false,
      ),
    );
  }

  /// Remplace l'écran actuel par un nouvel écran avec une animation de glissement vers le haut
  Future<T?> replaceWithSlideUp<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: true,
        slideLeft: false,
      ),
    );
  }

  /// Remplace l'écran actuel par un nouvel écran avec une animation de glissement vers la gauche
  Future<T?> replaceWithSlideLeft<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushReplacement<T, dynamic>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: false,
        slideLeft: true,
      ),
    );
  }

  /// Remplace tous les écrans par un nouvel écran avec une animation de fondu
  Future<T?> replaceAllWithFade<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: false,
        slideLeft: false,
      ),
      (route) => false,
    );
  }

  /// Remplace tous les écrans par un nouvel écran avec une animation de glissement vers le haut
  Future<T?> replaceAllWithSlideUp<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: true,
        slideLeft: false,
      ),
      (route) => false,
    );
  }

  /// Remplace tous les écrans par un nouvel écran avec une animation de glissement vers la gauche
  Future<T?> replaceAllWithSlideLeft<T>(BuildContext context, Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      _animationService.createPageRoute<T>(
        page: screen,
        fadeIn: true,
        slideUp: false,
        slideLeft: true,
      ),
      (route) => false,
    );
  }

  /// Retourne à l'écran précédent avec un résultat
  void goBack<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Navigue vers une route spécifique en fonction de son chemin
  Future<dynamic> navigateToRoute(BuildContext context, String route) {
    // Extraire les paramètres de la route
    final Uri uri = Uri.parse(route);
    final String path = uri.path;

    // Déterminer l'écran à afficher en fonction du chemin
    Widget? screen;

    // Routes pour le pêcheur
    if (path.startsWith('/pecheur/lots/')) {
      final String lotId = path.substring('/pecheur/lots/'.length);
      // Naviguer vers l'écran de détails du lot pour le pêcheur
      // screen = LotDetailsScreen(lotId: lotId, userType: 'pecheur');
    }
    // Routes pour le vétérinaire
    else if (path.startsWith('/veterinaire/lots/')) {
      final String lotId = path.substring('/veterinaire/lots/'.length);
      // Naviguer vers l'écran de détails du lot pour le vétérinaire
      // screen = LotDetailsScreen(lotId: lotId, userType: 'veterinaire');
    }
    // Routes pour le mareyeur
    else if (path.startsWith('/maryeur/lots/')) {
      final String lotId = path.substring('/maryeur/lots/'.length);
      // Naviguer vers l'écran de détails du lot pour le mareyeur
      // screen = LotDetailsScreen(lotId: lotId, userType: 'maryeur');
    }
    // Routes pour le client
    else if (path.startsWith('/client/lots/')) {
      final String lotId = path.substring('/client/lots/'.length);
      // Naviguer vers l'écran de détails du lot pour le client
      // screen = LotDetailsScreen(lotId: lotId, userType: 'client');
    }
    // Routes pour les prises
    else if (path.startsWith('/pecheur/prises/')) {
      final String priseId = path.substring('/pecheur/prises/'.length);
      // Naviguer vers l'écran de détails de la prise pour le pêcheur
      // screen = PriseDetailsScreen(priseId: priseId, userType: 'pecheur');
    } else if (path.startsWith('/maryeur/prises/')) {
      final String priseId = path.substring('/maryeur/prises/'.length);
      // Naviguer vers l'écran de détails de la prise pour le mareyeur
      // screen = PriseDetailsScreen(priseId: priseId, userType: 'maryeur');
    }
    // Autres routes
    else if (path == '/notifications') {
      // Importer dynamiquement pour éviter les dépendances circulaires
      screen = _getNotificationsScreen();
    }

    // Si l'écran est null, afficher un message d'erreur
    if (screen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route non prise en charge: $path'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return Future.value(null);
    }

    // Naviguer vers l'écran
    return navigateToWithSlideLeft(context, screen);
  }

  /// Retourne l'écran des notifications
  Widget _getNotificationsScreen() {
    // Importer dynamiquement pour éviter les dépendances circulaires
    return const NotificationsScreen();
  }
}
