import 'package:flutter/material.dart';
import 'package:seatrace/utils/color_extensions.dart';

/// Un widget de carte de statistique personnalisé pour l'application SeaTrace
/// avec un style cohérent et des options de personnalisation.
class SeaStatCard extends StatelessWidget {
  /// La valeur de la statistique
  final String value;

  /// Le libellé de la statistique
  final String label;

  /// L'icône à afficher (optionnel)
  final IconData? icon;

  /// La couleur de la statistique (optionnel)
  final Color? color;

  /// L'action à effectuer lorsque l'utilisateur appuie sur la carte (optionnel)
  final VoidCallback? onTap;

  /// La couleur de fond de la carte (optionnel)
  final Color? backgroundColor;

  /// Indique si la carte doit avoir une bordure (optionnel)
  final bool bordered;

  /// Le rayon de la bordure de la carte (optionnel)
  final double borderRadius;

  /// La marge externe de la carte (optionnel)
  final EdgeInsetsGeometry? margin;

  /// Le rembourrage interne de la carte (optionnel)
  final EdgeInsetsGeometry? padding;

  /// Indique si la carte est en cours de chargement (optionnel)
  final bool isLoading;

  /// Crée une nouvelle instance de [SeaStatCard].
  const SeaStatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.backgroundColor,
    this.bordered = true,
    this.borderRadius = 16,
    this.margin,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;
    final dividerColor =
        theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2);
    final cardBackgroundColor = backgroundColor ?? theme.colorScheme.surface;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: bordered ? Border.all(color: dividerColor, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child:
                isLoading
                    ? _buildLoadingContent(context, primaryColor)
                    : _buildContent(context, primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: 32, color: primaryColor),
        if (icon != null) const SizedBox(height: 12),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingContent(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Icon(icon, size: 32, color: primaryColor.withValues(alpha: 0.5)),
        if (icon != null) const SizedBox(height: 12),
        Container(
          width: 60,
          height: 24,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 16,
          decoration: BoxDecoration(
            color:
                theme.dividerTheme.color?.withValues(alpha: 0.5) ??
                Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
