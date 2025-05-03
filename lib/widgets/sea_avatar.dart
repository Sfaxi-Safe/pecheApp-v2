import 'package:flutter/material.dart';
import 'package:seatrace/utils/color_extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Un widget d'avatar personnalisé pour l'application SeaTrace
/// avec un style cohérent et des options de personnalisation.
class SeaAvatar extends StatelessWidget {
  /// L'URL de l'image à afficher (optionnel)
  final String? imageUrl;

  /// Les initiales à afficher si aucune image n'est disponible (optionnel)
  final String? initials;

  /// L'icône à afficher si aucune image n'est disponible (optionnel)
  final IconData? icon;

  /// La taille de l'avatar
  final double size;

  /// La couleur de fond de l'avatar (optionnel)
  final Color? backgroundColor;

  /// La couleur du texte ou de l'icône (optionnel)
  final Color? foregroundColor;

  /// L'action à effectuer lorsque l'utilisateur appuie sur l'avatar (optionnel)
  final VoidCallback? onTap;

  /// Indique si l'avatar doit avoir une bordure (optionnel)
  final bool bordered;

  /// La couleur de la bordure (optionnel)
  final Color? borderColor;

  /// L'épaisseur de la bordure (optionnel)
  final double borderWidth;

  /// Indique si l'avatar est en cours de chargement (optionnel)
  final bool isLoading;

  /// Crée une nouvelle instance de [SeaAvatar].
  const SeaAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
    this.bordered = false,
    this.borderColor,
    this.borderWidth = 2,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final defaultBackgroundColor = primaryColor.withValues(alpha: 0.1);
    final defaultForegroundColor = primaryColor;

    final avatarBackgroundColor = backgroundColor ?? defaultBackgroundColor;
    final avatarForegroundColor = foregroundColor ?? defaultForegroundColor;
    final avatarBorderColor = borderColor ?? primaryColor;

    // Construire le contenu de l'avatar
    Widget avatarContent;
    if (isLoading) {
      avatarContent = CircularProgressIndicator(
        strokeWidth: 2,
        color: avatarForegroundColor,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: avatarBackgroundColor,
                child: Center(
                  child: SizedBox(
                    width: size / 3,
                    height: size / 3,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: avatarForegroundColor,
                    ),
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: avatarBackgroundColor,
                child: Icon(
                  Icons.error_outline,
                  size: size / 2,
                  color: avatarForegroundColor,
                ),
              ),
        ),
      );
    } else if (initials != null && initials!.isNotEmpty) {
      avatarContent = Text(
        initials!,
        style: TextStyle(
          color: avatarForegroundColor,
          fontWeight: FontWeight.bold,
          fontSize: size / 2.5,
        ),
      );
    } else if (icon != null) {
      avatarContent = Icon(icon, size: size / 2, color: avatarForegroundColor);
    } else {
      avatarContent = Icon(
        Icons.person,
        size: size / 2,
        color: avatarForegroundColor,
      );
    }

    // Construire l'avatar
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              imageUrl != null && imageUrl!.isNotEmpty
                  ? Colors.transparent
                  : avatarBackgroundColor,
          border:
              bordered
                  ? Border.all(color: avatarBorderColor, width: borderWidth)
                  : null,
        ),
        child: Center(child: avatarContent),
      ),
    );
  }
}
