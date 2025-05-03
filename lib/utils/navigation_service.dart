import 'package:flutter/material.dart';
import 'package:seatrace/utils/animation_service.dart';

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
}
