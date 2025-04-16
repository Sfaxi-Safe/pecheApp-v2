import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Gestionnaire de cache d'images personnalisé
class CustomCacheManager {
  static const key = 'pecheAppCustomCache';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Précharger une image
  static Future<void> preloadImage(String url) async {
    try {
      await instance.getSingleFile(url);
    } catch (e) {
      debugPrint('Erreur lors du préchargement de l\'image: $e');
    }
  }

  /// Précharger plusieurs images
  static Future<void> preloadImages(List<String> urls) async {
    for (final url in urls) {
      await preloadImage(url);
    }
  }

  /// Effacer le cache
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
}

/// Widget d'image mise en cache avec gestion des erreurs et du chargement
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: CustomCacheManager.instance,
      placeholder: (context, url) => placeholder ?? const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => errorWidget ?? const Center(
        child: Icon(Icons.error, color: Colors.red),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}
