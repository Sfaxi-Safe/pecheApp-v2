import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette de couleurs principale - Thème maritime moderne
  static const Color primaryColor = Color(0xFF1A5F7A); // Bleu profond
  static const Color secondaryColor = Color(0xFF159895); // Turquoise
  static const Color accentColor = Color(0xFF57C5B6); // Turquoise clair
  static const Color backgroundColor = Color(0xFFF8F9FA); // Gris très clair
  static const Color surfaceColor = Color(0xFFFFFFFF); // Blanc
  static const Color errorColor = Color(0xFFE74C3C); // Rouge vif
  static const Color successColor = Color(0xFF2ECC71); // Vert vif
  static const Color warningColor = Color(0xFFF39C12); // Orange
  static const Color textColor = Color(0xFF2C3E50); // Bleu-gris foncé
  static const Color textLightColor = Color(0xFF7F8C8D); // Gris moyen
  static const Color dividerColor = Color(0xFFECF0F1); // Gris très clair

  // Thème clair
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColor,
      onBackground: textColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.montserrat(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      shadowColor: Colors.black.withAlpha(13),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: textLightColor),
      hintStyle: TextStyle(color: textLightColor.withAlpha(179)),
      prefixIconColor: textLightColor,
      suffixIconColor: textLightColor,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dividerColor, width: 1),
      ),
      color: surfaceColor,
      shadowColor: Colors.black.withAlpha(13),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 24,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.montserrat(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.montserrat(color: textColor),
      titleSmall: GoogleFonts.montserrat(color: textColor),
      bodyLarge: GoogleFonts.roboto(color: textColor),
      bodyMedium: GoogleFonts.roboto(color: textColor),
      bodySmall: GoogleFonts.roboto(color: textLightColor),
      labelLarge: GoogleFonts.roboto(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor, size: 24),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withAlpha(26),
      disabledColor: dividerColor,
      selectedColor: primaryColor,
      secondarySelectedColor: secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(color: primaryColor),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.light,
    ),
  );

  // Thème sombre
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor:
        accentColor, // Utiliser une couleur plus claire pour le thème sombre
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: secondaryColor,
      tertiary: primaryColor,
      surface: const Color(0xFF1A1A2E), // Bleu très foncé
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F0F1A), // Bleu-noir
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: accentColor),
      titleTextStyle: GoogleFonts.montserrat(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(color: accentColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: Colors.grey),
      hintStyle: const TextStyle(color: Color(0xFF6C6C7C)),
      prefixIconColor: const Color(0xFF6C6C7C),
      suffixIconColor: const Color(0xFF6C6C7C),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A2A3E), width: 1),
      ),
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A3E),
      thickness: 1,
      space: 24,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.montserrat(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.montserrat(color: Colors.white),
      titleSmall: GoogleFonts.montserrat(color: Colors.white),
      bodyLarge: GoogleFonts.roboto(color: Colors.white),
      bodyMedium: GoogleFonts.roboto(color: Colors.white),
      bodySmall: GoogleFonts.roboto(color: const Color(0xFFAAAAAA)),
      labelLarge: GoogleFonts.roboto(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: accentColor, size: 24),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF2A2A3E),
      disabledColor: Color(0xFF1A1A2E),
      selectedColor: accentColor,
      secondarySelectedColor: secondaryColor,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(color: Colors.white),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      brightness: Brightness.dark,
    ),
  );
}
