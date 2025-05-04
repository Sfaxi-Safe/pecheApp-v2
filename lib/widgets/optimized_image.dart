import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../utils/error_handler.dart';

/// Widget d'image optimisé qui gère différentes sources d'images
/// (réseau, fichier local, asset) avec mise en cache et gestion des erreurs
class OptimizedImage extends StatelessWidget {
  /// URL ou chemin de l'image
  final String? imageUrl;
  
  /// Largeur de l'image
  final double? width;
  
  /// Hauteur de l'image
  final double? height;
  
  /// Mode d'ajustement de l'image
  final BoxFit fit;
  
  /// Image à afficher en cas d'erreur
  final Widget? errorWidget;
  
  /// Image à afficher pendant le chargement
  final Widget? loadingWidget;
  
  /// Forme de l'image (rectangle, cercle, etc.)
  final BoxShape shape;
  
  /// Rayon de bordure pour les images rectangulaires
  final BorderRadius? borderRadius;
  
  /// Couleur de bordure
  final Color? borderColor;
  
  /// Épaisseur de bordure
  final double borderWidth;
  
  /// Indique si l'image est un asset
  final bool isAsset;
  
  /// Indique si l'image est un fichier local
  final bool isFile;
  
  /// Gestionnaire de cache personnalisé
  final CacheManager? cacheManager;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 0,
    this.isAsset = false,
    this.isFile = false,
    this.cacheManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Widget à afficher en cas d'erreur
    final errorPlaceholder = errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey,
            ),
          ),
        );

    // Widget à afficher pendant le chargement
    final loadingPlaceholder = loadingWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );

    // Si l'URL est null ou vide, afficher le widget d'erreur
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorPlaceholder;
    }

    // Créer le widget d'image en fonction du type de source
    Widget imageWidget;

    if (isAsset) {
      // Image d'asset
      imageWidget = Image.asset(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          ErrorHandler.instance.logError(
            error,
            stackTrace: stackTrace,
            context: 'OptimizedImage.build (asset)',
          );
          return errorPlaceholder;
        },
      );
    } else if (isFile) {
      // Image de fichier local
      try {
        final file = File(imageUrl!);
        if (!file.existsSync()) {
          return errorPlaceholder;
        }
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            ErrorHandler.instance.logError(
              error,
              stackTrace: stackTrace,
              context: 'OptimizedImage.build (file)',
            );
            return errorPlaceholder;
          },
        );
      } catch (e) {
        ErrorHandler.instance.logError(
          e,
          context: 'OptimizedImage.build (file exception)',
        );
        return errorPlaceholder;
      }
    } else {
      // Image réseau avec mise en cache
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => loadingPlaceholder,
        errorWidget: (context, url, error) {
          ErrorHandler.instance.logError(
            error,
            context: 'OptimizedImage.build (network)',
          );
          return errorPlaceholder;
        },
        cacheManager: cacheManager,
      );
    }

    // Appliquer la forme et la bordure
    if (shape == BoxShape.circle) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth,
                )
              : null,
        ),
        child: ClipOval(child: imageWidget),
      );
    } else {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth,
                )
              : null,
        ),
        child: borderRadius != null
            ? ClipRRect(
                borderRadius: borderRadius!,
                child: imageWidget,
              )
            : imageWidget,
      );
    }
  }
}

/// Extension pour faciliter l'utilisation du widget OptimizedImage
extension OptimizedImageExtension on String? {
  /// Convertit une chaîne en widget OptimizedImage
  Widget toImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Widget? loadingWidget,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
    Color? borderColor,
    double borderWidth = 0,
    bool isAsset = false,
    bool isFile = false,
    CacheManager? cacheManager,
  }) {
    return OptimizedImage(
      imageUrl: this,
      width: width,
      height: height,
      fit: fit,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
      shape: shape,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      isAsset: isAsset,
      isFile: isFile,
      cacheManager: cacheManager,
    );
  }

  /// Convertit une chaîne en widget OptimizedImage circulaire
  Widget toCircleImage({
    double? size,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
    Widget? loadingWidget,
    Color? borderColor,
    double borderWidth = 0,
    bool isAsset = false,
    bool isFile = false,
    CacheManager? cacheManager,
  }) {
    return OptimizedImage(
      imageUrl: this,
      width: size,
      height: size,
      fit: fit,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
      shape: BoxShape.circle,
      borderColor: borderColor,
      borderWidth: borderWidth,
      isAsset: isAsset,
      isFile: isFile,
      cacheManager: cacheManager,
    );
  }
}
