import 'package:flutter/material.dart';

/// Classe utilitaire pour gérer la responsivité
class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Vérifie si l'appareil est un téléphone mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Vérifie si l'appareil est une tablette
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Vérifie si l'appareil est un ordinateur de bureau
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Retourne la valeur appropriée en fonction de la taille de l'écran
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Retourne la taille de police appropriée en fonction de la taille de l'écran
  static double fontSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base sur iPhone 8
    return size * scaleFactor.clamp(0.8, 1.2); // Limiter le facteur d'échelle
  }

  /// Retourne la hauteur appropriée en fonction de la taille de l'écran
  static double height(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenHeight / 812; // Base sur iPhone X
    return height * scaleFactor.clamp(0.8, 1.2); // Limiter le facteur d'échelle
  }

  /// Retourne la largeur appropriée en fonction de la taille de l'écran
  static double width(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base sur iPhone 8
    return width * scaleFactor.clamp(0.8, 1.2); // Limiter le facteur d'échelle
  }

  /// Retourne le padding approprié en fonction de la taille de l'écran
  static EdgeInsets padding(BuildContext context, EdgeInsets padding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375; // Base sur iPhone 8
    final factor = scaleFactor.clamp(0.8, 1.2); // Limiter le facteur d'échelle
    
    return EdgeInsets.only(
      left: padding.left * factor,
      top: padding.top * factor,
      right: padding.right * factor,
      bottom: padding.bottom * factor,
    );
  }

  /// Retourne le nombre de colonnes approprié pour une grille en fonction de la taille de l'écran
  static int gridCrossAxisCount(BuildContext context, {int defaultCount = 2}) {
    if (isDesktop(context)) {
      return defaultCount + 2;
    } else if (isTablet(context)) {
      return defaultCount + 1;
    } else {
      return defaultCount;
    }
  }
}

/// Extension pour faciliter l'utilisation de Responsive
extension ResponsiveExtension on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  
  double responsiveFontSize(double size) => Responsive.fontSize(this, size);
  double responsiveHeight(double height) => Responsive.height(this, height);
  double responsiveWidth(double width) => Responsive.width(this, width);
  EdgeInsets responsivePadding(EdgeInsets padding) => Responsive.padding(this, padding);
  
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return Responsive.value(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
