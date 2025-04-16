import 'package:flutter/material.dart';

/// Classe qui fournit différentes transitions de page personnalisées
class PageTransitions {
  /// Transition de fondu
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        var tween = Tween(begin: begin, end: end);
        var fadeAnimation = animation.drive(tween);
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Transition de glissement
  static PageRouteBuilder slideTransition(Widget page, {SlideDirection direction = SlideDirection.right}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(
          direction == SlideDirection.right ? 1.0 : direction == SlideDirection.left ? -1.0 : 0.0,
          direction == SlideDirection.down ? 1.0 : direction == SlideDirection.up ? -1.0 : 0.0,
        );
        const end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Transition de zoom
  static PageRouteBuilder zoomTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        var tween = Tween(begin: begin, end: end);
        var scaleAnimation = animation.drive(tween);
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Transition de rotation et de zoom
  static PageRouteBuilder rotateZoomTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var rotation = Tween(begin: 0.0, end: 2 * 3.14159).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );
        
        var scale = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        );
        
        return ScaleTransition(
          scale: scale,
          child: RotationTransition(
            turns: rotation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

enum SlideDirection {
  left,
  right,
  up,
  down,
}

/// Extension pour faciliter la navigation avec des transitions
extension NavigatorExtension on NavigatorState {
  Future<dynamic> pushWithFade(Widget page) {
    return push(PageTransitions.fadeTransition(page));
  }
  
  Future<dynamic> pushWithSlide(Widget page, {SlideDirection direction = SlideDirection.right}) {
    return push(PageTransitions.slideTransition(page, direction: direction));
  }
  
  Future<dynamic> pushWithZoom(Widget page) {
    return push(PageTransitions.zoomTransition(page));
  }
  
  Future<dynamic> pushWithRotateZoom(Widget page) {
    return push(PageTransitions.rotateZoomTransition(page));
  }
}
