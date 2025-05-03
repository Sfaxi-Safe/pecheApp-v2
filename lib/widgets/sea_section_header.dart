import 'package:flutter/material.dart';
import 'sea_button.dart';

/// Un widget d'en-tête de section personnalisé pour l'application SeaTrace
/// avec un style cohérent et des options de personnalisation.
class SeaSectionHeader extends StatelessWidget {
  /// Le titre de la section
  final String title;
  
  /// Le sous-titre de la section (optionnel)
  final String? subtitle;
  
  /// L'icône à afficher à côté du titre (optionnel)
  final IconData? icon;
  
  /// Le texte du bouton d'action (optionnel)
  final String? actionText;
  
  /// L'icône du bouton d'action (optionnel)
  final IconData? actionIcon;
  
  /// L'action à effectuer lorsque l'utilisateur appuie sur le bouton d'action (optionnel)
  final VoidCallback? onActionPressed;
  
  /// La marge externe de l'en-tête (optionnel)
  final EdgeInsetsGeometry? margin;
  
  /// Le rembourrage interne de l'en-tête (optionnel)
  final EdgeInsetsGeometry? padding;

  /// Crée une nouvelle instance de [SeaSectionHeader].
  const SeaSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.actionIcon,
    this.onActionPressed,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16, top: 24),
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with optional action
          Row(
            children: [
              // Icon and title
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Action button
              if (onActionPressed != null) ...[
                if (actionText != null)
                  SeaButton.text(
                    text: actionText,
                    icon: actionIcon,
                    onPressed: onActionPressed,
                    size: SeaButtonSize.small,
                  )
                else if (actionIcon != null)
                  SeaButton.icon(
                    icon: actionIcon,
                    onPressed: onActionPressed,
                    size: SeaButtonSize.small,
                  ),
              ],
            ],
          ),
          
          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
