import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart' as prefs;
import '../utils/error_handler.dart';

class CacheService {
  static final CacheService instance = CacheService._init();
  final Map<String, CacheEntry> _memoryCache = {};
  late prefs.SharedPreferences _prefs;

  // Durées de cache par défaut
  static const Duration defaultMemoryCacheDuration = Duration(minutes: 5);
  static const Duration defaultDiskCacheDuration = Duration(hours: 24);

  CacheService._init();

  Future<void> initialize() async {
    _prefs = await prefs.SharedPreferences.getInstance();
    _cleanExpiredDiskCache();
  }

  Future<void> set(String key, dynamic value, {Duration? duration}) async {
    final expiryTime = DateTime.now().add(
      duration ?? defaultMemoryCacheDuration,
    );

    // Cache en mémoire
    _memoryCache[key] = CacheEntry(data: value, expiryTime: expiryTime);

    // Cache sur le disque
    try {
      final diskData = {
        'data': value,
        'expiryTime': expiryTime.toIso8601String(),
      };
      await _prefs.setString(key, jsonEncode(diskData));
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'CacheService.set($key)',
      );
      // Ne pas propager l'erreur pour maintenir la fonctionnalité du cache mémoire
    }
  }

  T? get<T>(String key) {
    // Vérifier d'abord le cache mémoire
    final memoryCacheEntry = _memoryCache[key];
    if (memoryCacheEntry != null && !memoryCacheEntry.isExpired) {
      return memoryCacheEntry.data as T;
    }

    // Si pas en mémoire ou expiré, vérifier le cache disque
    try {
      final diskData = _prefs.getString(key);
      if (diskData != null) {
        final decodedData = jsonDecode(diskData);
        final expiryTime = DateTime.parse(decodedData['expiryTime']);

        if (expiryTime.isAfter(DateTime.now())) {
          try {
            // Mettre à jour le cache mémoire avec les données du disque
            _memoryCache[key] = CacheEntry(
              data: decodedData['data'],
              expiryTime: expiryTime,
            );
            return decodedData['data'] as T;
          } catch (e) {
            ErrorHandler.instance.logError(
              e,
              context: 'CacheService.get<$T>($key) - Type casting error',
            );
            // Supprimer l'entrée invalide
            await remove(key);
            return null;
          }
        } else {
          // Supprimer les données expirées
          await remove(key);
        }
      }
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'CacheService.get<$T>($key)',
      );
      // Supprimer l'entrée corrompue
      await remove(key);
    }

    return null;
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    _memoryCache.clear();
    await _prefs.clear();
  }

  void _cleanExpiredDiskCache() {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        try {
          final data = _prefs.getString(key);
          if (data != null) {
            final decodedData = jsonDecode(data);
            final expiryTime = DateTime.parse(decodedData['expiryTime']);

            if (expiryTime.isBefore(DateTime.now())) {
              await _prefs.remove(key);
              _memoryCache.remove(key); // Synchroniser avec le cache mémoire
            }
          }
        } catch (e) {
          ErrorHandler.instance.logError(
            e,
            context: 'CacheService._cleanExpiredDiskCache - key: $key',
          );
          // Supprimer l'entrée corrompue
          await _prefs.remove(key);
          _memoryCache.remove(key);
        }
      }
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'CacheService._cleanExpiredDiskCache',
      );
    }
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiryTime;

  CacheEntry({required this.data, required this.expiryTime});

  bool get isExpired => expiryTime.isBefore(DateTime.now());
}
