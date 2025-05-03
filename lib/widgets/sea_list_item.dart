import 'package:flutter/material.dart';
import 'package:seatrace/utils/color_extensions.dart';
import 'sea_avatar.dart';

/// Un widget d'élément de liste personnalisé pour l'application SeaTrace
/// avec un style cohérent et des options de personnalisation.
class SeaListItem extends StatelessWidget {
  /// Le titre de l'élément
  final String title;

  /// Le sous-titre de l'élément (optionnel)
  final String? subtitle;

  /// L'URL de l'image à afficher (optionnel)
  final String? imageUrl;

  /// L'icône à afficher si aucune image n'est disponible (optionnel)
  final IconData? icon;

  /// Les initiales à afficher si aucune image n'est disponible (optionnel)
  final String? initials;

  /// Le widget à afficher à droite de l'élément (optionnel)
  final Widget? trailing;

  /// L'action à effectuer lorsque l'utilisateur appuie sur l'élément (optionnel)
  final VoidCallback? onTap;

  /// L'action à effectuer lorsque l'utilisateur appuie longuement sur l'élément (optionnel)
  final VoidCallback? onLongPress;

  /// La couleur de fond de l'élément (optionnel)
  final Color? backgroundColor;

  /// Indique si l'élément doit avoir une bordure (optionnel)
  final bool bordered;

  /// Le rayon de la bordure de l'élément (optionnel)
  final double borderRadius;

  /// La marge externe de l'élément (optionnel)
  final EdgeInsetsGeometry? margin;

  /// Le rembourrage interne de l'élément (optionnel)
  final EdgeInsetsGeometry? padding;

  /// Le badge à afficher sur l'élément (optionnel)
  final String? badge;

  /// La couleur du badge (optionnel)
  final Color? badgeColor;

  /// Indique si l'élément est sélectionné (optionnel)
  final bool selected;

  /// Indique si l'élément est désactivé (optionnel)
  final bool disabled;

  /// Crée une nouvelle instance de [SeaListItem].
  const SeaListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.icon,
    this.initials,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.bordered = true,
    this.borderRadius = 12,
    this.margin,
    this.padding,
    this.badge,
    this.badgeColor,
    this.selected = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final dividerColor =
        theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2);
    final itemBackgroundColor = backgroundColor ?? theme.colorScheme.surface;
    final defaultBadgeColor = theme.colorScheme.primary;

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Container(
        margin:
            margin ?? const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        decoration: BoxDecoration(
          color:
              selected
                  ? primaryColor.withValues(alpha: 0.1)
                  : itemBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border:
              bordered
                  ? Border.all(
                    color: selected ? primaryColor : dividerColor,
                    width: selected ? 1.5 : 1,
                  )
                  : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : onTap,
            onLongPress: disabled ? null : onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar/Icon
                  if (imageUrl != null || icon != null || initials != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SeaAvatar(
                        imageUrl: imageUrl,
                        icon: icon,
                        initials: initials,
                        size: 48,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        foregroundColor: primaryColor,
                      ),
                    ),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor ?? defaultBadgeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  badge!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
