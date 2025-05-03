import 'package:flutter/material.dart';

/// Service pour gérer le responsive design dans l'application SeaTrace
class ResponsiveService {
  /// Instance singleton du service de responsive design
  static final ResponsiveService _instance = ResponsiveService._internal();

  /// Constructeur factory pour accéder à l'instance singleton
  factory ResponsiveService() => _instance;

  /// Constructeur interne pour l'instance singleton
  ResponsiveService._internal();

  /// Taille d'écran pour les téléphones
  static const double phoneBreakpoint = 600;
  
  /// Taille d'écran pour les tablettes
  static const double tabletBreakpoint = 900;
  
  /// Taille d'écran pour les ordinateurs de bureau
  static const double desktopBreakpoint = 1200;

  /// Vérifie si l'écran est un téléphone
  bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneBreakpoint;
  }

  /// Vérifie si l'écran est une tablette
  bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneBreakpoint && width < tabletBreakpoint;
  }

  /// Vérifie si l'écran est un ordinateur de bureau
  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Retourne la taille d'écran actuelle
  ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) {
      return ScreenSize.desktop;
    } else if (width >= tabletBreakpoint) {
      return ScreenSize.tablet;
    } else if (width >= phoneBreakpoint) {
      return ScreenSize.tabletSmall;
    } else {
      return ScreenSize.phone;
    }
  }

  /// Retourne une valeur adaptée à la taille de l'écran
  T adaptiveValue<T>({
    required BuildContext context,
    required T phone,
    T? tabletSmall,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? tabletSmall ?? phone;
      case ScreenSize.tablet:
        return tablet ?? tabletSmall ?? phone;
      case ScreenSize.tabletSmall:
        return tabletSmall ?? phone;
      case ScreenSize.phone:
        return phone;
    }
  }

  /// Retourne un padding adapté à la taille de l'écran
  EdgeInsetsGeometry adaptivePadding(BuildContext context) {
    return adaptiveValue<EdgeInsetsGeometry>(
      context: context,
      phone: const EdgeInsets.all(16.0),
      tabletSmall: const EdgeInsets.all(24.0),
      tablet: const EdgeInsets.all(32.0),
      desktop: const EdgeInsets.all(48.0),
    );
  }

  /// Retourne un espacement adapté à la taille de l'écran
  double adaptiveSpacing(BuildContext context) {
    return adaptiveValue<double>(
      context: context,
      phone: 16.0,
      tabletSmall: 24.0,
      tablet: 32.0,
      desktop: 40.0,
    );
  }

  /// Retourne une taille de police adaptée à la taille de l'écran
  double adaptiveFontSize(BuildContext context, double baseSize) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktop:
        return baseSize * 1.25;
      case ScreenSize.tablet:
        return baseSize * 1.15;
      case ScreenSize.tabletSmall:
        return baseSize * 1.05;
      case ScreenSize.phone:
        return baseSize;
    }
  }

  /// Retourne un widget adapté à la taille de l'écran
  Widget adaptiveWidget({
    required BuildContext context,
    required Widget phone,
    Widget? tabletSmall,
    Widget? tablet,
    Widget? desktop,
  }) {
    return adaptiveValue<Widget>(
      context: context,
      phone: phone,
      tabletSmall: tabletSmall,
      tablet: tablet,
      desktop: desktop,
    );
  }

  /// Retourne un layout adapté à la taille de l'écran
  Widget adaptiveLayout({
    required BuildContext context,
    required WidgetBuilder phoneBuilder,
    WidgetBuilder? tabletSmallBuilder,
    WidgetBuilder? tabletBuilder,
    WidgetBuilder? desktopBuilder,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktop:
        return (desktopBuilder ?? tabletBuilder ?? tabletSmallBuilder ?? phoneBuilder)(context);
      case ScreenSize.tablet:
        return (tabletBuilder ?? tabletSmallBuilder ?? phoneBuilder)(context);
      case ScreenSize.tabletSmall:
        return (tabletSmallBuilder ?? phoneBuilder)(context);
      case ScreenSize.phone:
        return phoneBuilder(context);
    }
  }

  /// Retourne un nombre de colonnes adapté à la taille de l'écran
  int adaptiveGridColumns(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.desktop:
        return 4;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.tabletSmall:
        return 2;
      case ScreenSize.phone:
        return 1;
    }
  }
}

/// Énumération des tailles d'écran
enum ScreenSize {
  /// Téléphone (< 600px)
  phone,
  
  /// Petite tablette (600px - 900px)
  tabletSmall,
  
  /// Tablette (900px - 1200px)
  tablet,
  
  /// Ordinateur de bureau (>= 1200px)
  desktop,
}
