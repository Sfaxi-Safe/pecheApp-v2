import 'package:flutter/material.dart';
import 'package:seatrace/utils/color_extensions.dart';

/// Types de boutons disponibles dans l'application SeaTrace
enum SeaButtonType {
  /// Bouton principal avec fond coloré
  primary,

  /// Bouton secondaire avec contour
  outline,

  /// Bouton texte sans fond ni contour
  text,

  /// Bouton avec icône seulement
  icon,
}

/// Un widget de bouton personnalisé pour l'application SeaTrace
/// avec un style cohérent et des options de personnalisation.
class SeaButton extends StatelessWidget {
  /// Le texte à afficher sur le bouton
  final String? text;

  /// L'icône à afficher sur le bouton (optionnel)
  final IconData? icon;

  /// L'action à effectuer lorsque l'utilisateur appuie sur le bouton
  final VoidCallback? onPressed;

  /// Le type de bouton à afficher
  final SeaButtonType type;

  /// Indique si le bouton est en cours de chargement
  final bool isLoading;

  /// La couleur du bouton (optionnel, utilise la couleur primaire par défaut)
  final Color? color;

  /// La taille du bouton
  final SeaButtonSize size;

  /// La largeur du bouton (optionnel)
  final double? width;

  /// La hauteur du bouton (optionnel)
  final double? height;

  /// Le rayon de la bordure du bouton (optionnel)
  final double? borderRadius;

  /// Crée un nouveau bouton principal.
  const SeaButton.primary({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.size = SeaButtonSize.medium,
    this.width,
    this.height,
    this.borderRadius,
  }) : type = SeaButtonType.primary;

  /// Crée un nouveau bouton avec contour.
  const SeaButton.outline({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.size = SeaButtonSize.medium,
    this.width,
    this.height,
    this.borderRadius,
  }) : type = SeaButtonType.outline;

  /// Crée un nouveau bouton texte.
  const SeaButton.text({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.size = SeaButtonSize.medium,
    this.width,
    this.height,
    this.borderRadius,
  }) : type = SeaButtonType.text;

  /// Crée un nouveau bouton icône.
  const SeaButton.icon({
    super.key,
    this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.size = SeaButtonSize.medium,
    this.width,
    this.height,
    this.borderRadius,
  }) : type = SeaButtonType.icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final buttonTextColor =
        type == SeaButtonType.primary ? Colors.white : buttonColor;

    // Déterminer les dimensions en fonction de la taille
    final buttonHeight = height ?? size.height;
    final buttonWidth =
        width ?? (type == SeaButtonType.icon ? buttonHeight : null);
    final buttonBorderRadius = borderRadius ?? size.borderRadius;
    final buttonPadding = size.padding;
    final buttonIconSize = size.iconSize;
    final buttonTextStyle = theme.textTheme.labelLarge?.copyWith(
      color: buttonTextColor,
      fontWeight: FontWeight.bold,
      fontSize: size.fontSize,
    );

    // Construire le contenu du bouton
    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        height: buttonIconSize,
        width: buttonIconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: buttonTextColor,
        ),
      );
    } else if (type == SeaButtonType.icon) {
      buttonContent = Icon(icon, color: buttonTextColor, size: buttonIconSize);
    } else {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: buttonTextColor, size: buttonIconSize),
            SizedBox(width: text != null ? 8 : 0),
          ],
          if (text != null) Text(text!, style: buttonTextStyle),
        ],
      );
    }

    // Construire le bouton en fonction du type
    switch (type) {
      case SeaButtonType.primary:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
              elevation: 0,
              disabledBackgroundColor: buttonColor.withValues(alpha: 0.6),
            ),
            child: buttonContent,
          ),
        );

      case SeaButtonType.outline:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: buttonColor,
              side: BorderSide(color: buttonColor, width: 1.5),
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
            child: buttonContent,
          ),
        );

      case SeaButtonType.text:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: buttonColor,
              padding: buttonPadding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
            child: buttonContent,
          ),
        );

      case SeaButtonType.icon:
        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: IconButton(
            onPressed: isLoading ? null : onPressed,
            icon: buttonContent,
            style: IconButton.styleFrom(
              foregroundColor: buttonColor,
              backgroundColor:
                  type == SeaButtonType.primary
                      ? buttonColor
                      : Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
                side:
                    type == SeaButtonType.outline
                        ? BorderSide(color: buttonColor, width: 1.5)
                        : BorderSide.none,
              ),
            ),
          ),
        );
    }
  }
}

/// Tailles de boutons disponibles dans l'application SeaTrace
enum SeaButtonSize {
  /// Petit bouton
  small(32, 8, 16, 14, 16),

  /// Bouton de taille moyenne
  medium(40, 12, 20, 16, 18),

  /// Grand bouton
  large(48, 16, 24, 16, 20);

  /// La hauteur du bouton
  final double height;

  /// Le padding horizontal du bouton
  final double paddingHorizontal;

  /// Le rayon de la bordure du bouton
  final double borderRadius;

  /// La taille de la police du bouton
  final double fontSize;

  /// La taille de l'icône du bouton
  final double iconSize;

  /// Crée une nouvelle taille de bouton.
  const SeaButtonSize(
    this.height,
    this.paddingHorizontal,
    this.borderRadius,
    this.fontSize,
    this.iconSize,
  );

  /// Le padding du bouton
  EdgeInsetsGeometry get padding =>
      EdgeInsets.symmetric(horizontal: paddingHorizontal);
}
