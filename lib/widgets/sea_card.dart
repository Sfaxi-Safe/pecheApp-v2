import 'package:flutter/material.dart';
import 'package:seatrace/utils/color_extensions.dart';

/// Un widget de carte personnalisé pour l'application SeaTrace
/// avec un style cohérent et des options de personnalisation.
class SeaCard extends StatelessWidget {
  /// Le contenu de la carte
  final Widget child;

  /// Le titre de la carte (optionnel)
  final String? title;

  /// L'icône à afficher à côté du titre (optionnel)
  final IconData? icon;

  /// L'action à effectuer lorsque l'utilisateur appuie sur l'icône d'action (optionnel)
  final VoidCallback? onActionPressed;

  /// L'icône d'action à afficher (optionnel)
  final IconData? actionIcon;

  /// Le texte du bouton d'action (optionnel)
  final String? actionText;

  /// La couleur de fond de la carte (optionnel)
  final Color? backgroundColor;

  /// La marge externe de la carte (optionnel)
  final EdgeInsetsGeometry? margin;

  /// Le rembourrage interne de la carte (optionnel)
  final EdgeInsetsGeometry? padding;

  /// Indique si la carte doit avoir une élévation (optionnel)
  final bool elevated;

  /// Indique si la carte doit avoir une bordure (optionnel)
  final bool bordered;

  /// Le rayon de la bordure de la carte (optionnel)
  final double borderRadius;

  /// Crée une nouvelle instance de [SeaCard].
  const SeaCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.onActionPressed,
    this.actionIcon,
    this.actionText,
    this.backgroundColor,
    this.margin,
    this.padding,
    this.elevated = false,
    this.bordered = true,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = backgroundColor ?? theme.colorScheme.surface;
    final dividerColor =
        theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2);
    final primaryColor = theme.primaryColor;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: bordered ? Border.all(color: dividerColor, width: 1) : null,
        boxShadow:
            elevated
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and action
          if (title != null || onActionPressed != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: padding != null ? 0 : 16,
              ),
              child: Row(
                children: [
                  // Icon and title
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                  ],
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Action button
                  if (onActionPressed != null) ...[
                    if (actionText != null)
                      TextButton(
                        onPressed: onActionPressed,
                        child: Text(
                          actionText!,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (actionIcon != null)
                      IconButton(
                        icon: Icon(actionIcon, color: primaryColor),
                        onPressed: onActionPressed,
                        tooltip: 'Action',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                        iconSize: 20,
                      ),
                  ],
                ],
              ),
            ),
            if (padding == null) const Divider(),
          ],

          // Content
          Padding(
            padding:
                padding ??
                EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: title != null ? 8 : 16,
                  bottom: 16,
                ),
            child: child,
          ),
        ],
      ),
    );
  }
}
