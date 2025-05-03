import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Service pour gérer les animations dans l'application SeaTrace
class AnimationService {
  /// Instance singleton du service d'animation
  static final AnimationService _instance = AnimationService._internal();

  /// Constructeur factory pour accéder à l'instance singleton
  factory AnimationService() => _instance;

  /// Constructeur interne pour l'instance singleton
  AnimationService._internal();

  /// Durée par défaut pour les animations
  final Duration defaultDuration = const Duration(milliseconds: 300);

  /// Durée pour les animations lentes
  final Duration slowDuration = const Duration(milliseconds: 600);

  /// Durée pour les animations rapides
  final Duration fastDuration = const Duration(milliseconds: 150);

  /// Crée une animation de fondu pour un widget
  Widget fadeIn(
    Widget child, {
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    return child.animate().fade(
      duration: duration ?? defaultDuration,
      curve: curve,
    );
  }

  /// Crée une animation de glissement depuis le bas pour un widget
  Widget slideUp(
    Widget child, {
    Duration? duration,
    Curve curve = Curves.easeOutQuint,
    double distance = 50.0,
  }) {
    return child.animate().slideY(
      begin: distance,
      end: 0,
      duration: duration ?? defaultDuration,
      curve: curve,
    );
  }

  /// Crée une animation de glissement depuis la droite pour un widget
  Widget slideRight(
    Widget child, {
    Duration? duration,
    Curve curve = Curves.easeOutQuint,
    double distance = 50.0,
  }) {
    return child.animate().slideX(
      begin: -distance,
      end: 0,
      duration: duration ?? defaultDuration,
      curve: curve,
    );
  }

  /// Crée une animation de glissement depuis la gauche pour un widget
  Widget slideLeft(
    Widget child, {
    Duration? duration,
    Curve curve = Curves.easeOutQuint,
    double distance = 50.0,
  }) {
    return child.animate().slideX(
      begin: distance,
      end: 0,
      duration: duration ?? defaultDuration,
      curve: curve,
    );
  }

  /// Crée une animation de zoom pour un widget
  Widget scaleWidget(Widget child, {Duration? duration}) {
    return child.animate().scaleXY(
      begin: 0.8,
      end: 1.0,
      duration: duration ?? defaultDuration,
      curve: Curves.easeOutBack,
    );
  }

  /// Crée une animation de zoom pour un widget
  Widget scale(Widget child, {Duration? duration}) {
    return child.animate().scaleXY(
      begin: 0.8,
      end: 1.0,
      duration: duration ?? defaultDuration,
      curve: Curves.easeOutBack,
    );
  }

  /// Crée une animation de zoom pour un widget
  Widget scaleWithParams(
    Widget child, {
    Duration? duration,
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOutBack,
  }) {
    return child.animate().scaleXY(
      begin: begin,
      end: end,
      duration: duration ?? defaultDuration,
      curve: curve,
    );
  }

  /// Crée une animation de rebond pour un widget
  Widget bounce(Widget child, {Duration? duration, double intensity = 0.1}) {
    return child
        .animate()
        .scaleXY(
          begin: 1.0,
          end: 1.0 + intensity,
          duration: duration ?? fastDuration,
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          begin: 1.0 + intensity,
          end: 1.0,
          duration: duration ?? fastDuration,
          curve: Curves.bounceOut,
        );
  }

  /// Crée une animation de pulsation pour un widget
  Widget pulse(Widget child, {Duration? duration, double intensity = 0.05}) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .scaleXY(
          begin: 1.0,
          end: 1.0 + intensity,
          duration: duration ?? const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        )
        .then()
        .scaleXY(
          begin: 1.0 + intensity,
          end: 1.0,
          duration: duration ?? const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
  }

  /// Crée une animation de secousse pour un widget
  Widget shake(Widget child, {Duration? duration, double intensity = 5.0}) {
    return child
        .animate(onPlay: (controller) => controller.forward())
        .moveX(
          begin: 0,
          end: intensity,
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeInOut,
        )
        .then()
        .moveX(
          begin: intensity,
          end: -intensity,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        )
        .then()
        .moveX(
          begin: -intensity,
          end: intensity,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        )
        .then()
        .moveX(
          begin: intensity,
          end: 0,
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeInOut,
        );
  }

  /// Crée une animation de fondu et glissement pour une liste d'éléments
  List<Widget> staggeredList(
    List<Widget> children, {
    Duration? staggerDuration,
    bool fadeIn = true,
    bool slideIn = true,
  }) {
    final stagDuration = staggerDuration ?? const Duration(milliseconds: 50);

    return List.generate(children.length, (index) {
      Widget child = children[index];

      if (fadeIn && slideIn) {
        return child
            .animate(delay: stagDuration * index)
            .fade(duration: defaultDuration)
            .slideY(
              begin: 20,
              end: 0,
              duration: defaultDuration,
              curve: Curves.easeOutQuint,
            );
      } else if (fadeIn) {
        return child
            .animate(delay: stagDuration * index)
            .fade(duration: defaultDuration);
      } else if (slideIn) {
        return child
            .animate(delay: stagDuration * index)
            .slideY(
              begin: 20,
              end: 0,
              duration: defaultDuration,
              curve: Curves.easeOutQuint,
            );
      } else {
        return child;
      }
    });
  }

  /// Crée une transition de page personnalisée
  PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
    bool fadeIn = true,
    bool slideUp = false,
    bool slideLeft = false,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration ?? defaultDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
        );

        var transitions = <Widget Function(Widget)>[];

        if (fadeIn) {
          transitions.add(
            (child) => FadeTransition(opacity: curvedAnimation, child: child),
          );
        }

        if (slideUp) {
          transitions.add(
            (child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        }

        if (slideLeft) {
          transitions.add(
            (child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        }

        Widget result = child;
        for (var transition in transitions.reversed) {
          result = transition(result);
        }

        return result;
      },
    );
  }
}
