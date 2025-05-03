import 'package:flutter/material.dart';

/// Extensions pour la classe Color
extension ColorExtensions on Color {
  /// Crée une nouvelle couleur avec les valeurs spécifiées
  /// Si une valeur n'est pas spécifiée, la valeur actuelle est utilisée
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? r.toInt(),
      green ?? g.toInt(),
      blue ?? b.toInt(),
      alpha ?? a,
    );
  }
}
