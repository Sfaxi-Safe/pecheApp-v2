import 'package:flutter/material.dart';

/// Tailles disponibles pour les boutons personnalisés
enum CustomButtonSize { small, medium, large }

/// Types de boutons personnalisés
enum CustomButtonType { filled, outline, text, icon }

/// Un widget de bouton personnalisé pour résoudre le problème d'affichage
class CustomButton extends StatelessWidget {
  /// Le texte à afficher sur le bouton
  final String? text;

  /// L'icône à afficher sur le bouton (optionnel)
  final IconData? icon;

  /// L'action à effectuer lorsque l'utilisateur appuie sur le bouton
  final VoidCallback? onPressed;

  /// Le type de bouton (filled, outline, text, icon)
  final CustomButtonType type;

  /// La taille du bouton
  final CustomButtonSize size;

  /// Indique si le bouton est en cours de chargement
  final bool isLoading;

  /// La couleur du bouton (optionnel, utilise la couleur primaire par défaut)
  final Color? color;

  /// La largeur du bouton (optionnel)
  final double? width;

  /// La hauteur du bouton (optionnel)
  final double? height;

  /// Le rayon de la bordure du bouton (optionnel)
  final double? borderRadius;

  /// Le style du texte (optionnel)
  final TextStyle? textStyle;

  /// Crée un nouveau bouton rempli.
  const CustomButton.filled({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
  }) : type = CustomButtonType.filled,
       super(key: key);

  /// Crée un nouveau bouton avec contour.
  const CustomButton.outline({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
  }) : type = CustomButtonType.outline,
       super(key: key);

  /// Crée un nouveau bouton texte.
  const CustomButton.text({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
  }) : type = CustomButtonType.text,
       super(key: key);

  /// Crée un nouveau bouton icône.
  const CustomButton.icon({
    Key? key,
    this.text,
    required this.icon,
    required this.onPressed,
    this.size = CustomButtonSize.medium,
    this.isLoading = false,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
  }) : type = CustomButtonType.icon,
       super(key: key);

  /// Constructeur standard pour la compatibilité avec le code existant
  const CustomButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onPressed,
    bool isOutline = false,
    this.isLoading = false,
    this.color,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.size = CustomButtonSize.medium,
  }) : type = isOutline ? CustomButtonType.outline : CustomButtonType.filled,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;

    // Déterminer les dimensions en fonction de la taille
    final buttonHeight = height ?? _getHeightForSize(size);
    final buttonWidth =
        width ?? (type == CustomButtonType.icon ? buttonHeight : null);
    final buttonBorderRadius = borderRadius ?? _getBorderRadiusForSize(size);

    // Déterminer la couleur du texte et de l'icône
    final contentColor = _getContentColor(buttonColor, theme);

    // Construire le contenu du bouton
    Widget buttonContent = _buildButtonContent(context, contentColor);

    // Créer le bouton en fonction du type
    return _buildButton(
      buttonContent,
      buttonColor,
      buttonHeight,
      buttonWidth,
      buttonBorderRadius,
    );
  }

  /// Construit le contenu du bouton (texte, icône, indicateur de chargement)
  Widget _buildButtonContent(BuildContext context, Color contentColor) {
    final theme = Theme.of(context);
    final defaultTextStyle = _getTextStyleForSize(size, theme);
    final finalTextStyle =
        textStyle?.copyWith(color: contentColor) ??
        defaultTextStyle.copyWith(color: contentColor);

    if (isLoading) {
      return SizedBox(
        height: _getIconSizeForSize(size),
        width: _getIconSizeForSize(size),
        child: CircularProgressIndicator(strokeWidth: 2, color: contentColor),
      );
    } else if (type == CustomButtonType.icon) {
      return Icon(icon, color: contentColor, size: _getIconSizeForSize(size));
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: contentColor, size: _getIconSizeForSize(size)),
            SizedBox(width: text != null ? 8 : 0),
          ],
          if (text != null) Text(text!, style: finalTextStyle),
        ],
      );
    }
  }

  /// Construit le bouton en fonction du type
  Widget _buildButton(
    Widget content,
    Color buttonColor,
    double height,
    double? width,
    double borderRadius,
  ) {
    // Créer le conteneur de base avec les dimensions et le contenu
    final container = Container(
      height: height,
      width: width,
      padding: _getPaddingForSize(size),
      decoration: BoxDecoration(
        color: _getBackgroundColor(buttonColor),
        borderRadius: BorderRadius.circular(borderRadius),
        border: _getBorder(buttonColor),
      ),
      child: Center(child: content),
    );

    // Ajouter l'effet d'encre pour le feedback tactile
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      ),
    );
  }

  /// Détermine la couleur de fond du bouton
  Color _getBackgroundColor(Color buttonColor) {
    switch (type) {
      case CustomButtonType.filled:
        return buttonColor;
      case CustomButtonType.outline:
      case CustomButtonType.text:
      case CustomButtonType.icon:
        return Colors.transparent;
    }
  }

  /// Détermine la bordure du bouton
  Border? _getBorder(Color buttonColor) {
    if (type == CustomButtonType.outline) {
      return Border.all(color: buttonColor, width: 1.5);
    }
    return null;
  }

  /// Détermine la couleur du contenu (texte, icône)
  Color _getContentColor(Color buttonColor, ThemeData theme) {
    switch (type) {
      case CustomButtonType.filled:
        return Colors.white;
      case CustomButtonType.outline:
      case CustomButtonType.text:
      case CustomButtonType.icon:
        return buttonColor;
    }
  }

  /// Retourne la hauteur en fonction de la taille du bouton
  double _getHeightForSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 36;
      case CustomButtonSize.medium:
        return 48;
      case CustomButtonSize.large:
        return 56;
    }
  }

  /// Retourne le rayon de la bordure en fonction de la taille du bouton
  double _getBorderRadiusForSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 18;
      case CustomButtonSize.medium:
        return 24;
      case CustomButtonSize.large:
        return 28;
    }
  }

  /// Retourne le padding en fonction de la taille du bouton
  EdgeInsetsGeometry _getPaddingForSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  /// Retourne la taille de l'icône en fonction de la taille du bouton
  double _getIconSizeForSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return 16;
      case CustomButtonSize.medium:
        return 20;
      case CustomButtonSize.large:
        return 24;
    }
  }

  /// Retourne le style de texte en fonction de la taille du bouton
  TextStyle _getTextStyleForSize(CustomButtonSize size, ThemeData theme) {
    final baseStyle = theme.textTheme.labelLarge ?? const TextStyle();

    switch (size) {
      case CustomButtonSize.small:
        return baseStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold);
      case CustomButtonSize.medium:
        return baseStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold);
      case CustomButtonSize.large:
        return baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold);
    }
  }
}
