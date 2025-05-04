import 'dart:async';
import 'package:flutter/material.dart';
import 'package:seatrace/models/notification.dart' as model;
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/utils/error_handler.dart';

/// Service de gestion des notifications
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  
  /// Liste des notifications
  List<model.Notification> _notifications = [];
  
  /// Nombre de notifications non lues
  int _unreadCount = 0;
  
  /// Contrôleur de flux pour les notifications
  final _notificationsController = StreamController<List<model.Notification>>.broadcast();
  
  /// Contrôleur de flux pour le nombre de notifications non lues
  final _unreadCountController = StreamController<int>.broadcast();
  
  /// Intervalle de rafraîchissement des notifications (en secondes)
  final int _refreshInterval = 30;
  
  /// Timer pour le rafraîchissement automatique des notifications
  Timer? _refreshTimer;
  
  /// Indique si le service est initialisé
  bool _isInitialized = false;

  NotificationService._internal();

  /// Flux de notifications
  Stream<List<model.Notification>> get notifications => _notificationsController.stream;
  
  /// Flux du nombre de notifications non lues
  Stream<int> get unreadCount => _unreadCountController.stream;
  
  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Charger les notifications
      await fetchNotifications();
      
      // Démarrer le rafraîchissement automatique
      _startAutoRefresh();
      
      _isInitialized = true;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'NotificationService.initialize');
    }
  }
  
  /// Récupère les notifications depuis l'API
  Future<List<model.Notification>> fetchNotifications({int page = 1, int limit = 20}) async {
    try {
      // Vérifier si l'utilisateur est connecté
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      // Récupérer les notifications
      final response = await ApiService.instance.get(
        'notifications',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      
      // Extraire les données
      final List<dynamic> data = response['data'] ?? [];
      final int total = response['total'] ?? 0;
      final int nonLues = response['nonLues'] ?? 0;
      
      // Convertir les données en objets Notification
      final notifications = data.map((item) => model.Notification.fromMap(item)).toList();
      
      // Mettre à jour les données
      _notifications = notifications;
      _unreadCount = nonLues;
      
      // Émettre les nouvelles valeurs
      _notificationsController.add(_notifications);
      _unreadCountController.add(_unreadCount);
      
      return notifications;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'NotificationService.fetchNotifications');
      return [];
    }
  }
  
  /// Marque une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      // Appeler l'API
      await ApiService.instance.patch('notifications/$notificationId/lue', {});
      
      // Mettre à jour la notification localement
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final notification = _notifications[index];
        if (!notification.lue) {
          // Créer une nouvelle notification avec lue = true
          final updatedNotification = notification.copyWith(lue: true);
          
          // Mettre à jour la liste
          _notifications[index] = updatedNotification;
          
          // Mettre à jour le compteur
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          
          // Émettre les nouvelles valeurs
          _notificationsController.add(_notifications);
          _unreadCountController.add(_unreadCount);
        }
      }
      
      return true;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'NotificationService.markAsRead');
      return false;
    }
  }
  
  /// Marque toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      // Appeler l'API
      final response = await ApiService.instance.patch('notifications/lire-tout', {});
      
      // Mettre à jour les notifications localement
      final count = response['count'] ?? 0;
      if (count > 0) {
        // Mettre à jour toutes les notifications
        _notifications = _notifications.map((n) => n.copyWith(lue: true)).toList();
        
        // Mettre à jour le compteur
        _unreadCount = 0;
        
        // Émettre les nouvelles valeurs
        _notificationsController.add(_notifications);
        _unreadCountController.add(_unreadCount);
      }
      
      return true;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'NotificationService.markAllAsRead');
      return false;
    }
  }
  
  /// Supprime une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Appeler l'API
      await ApiService.instance.delete('notifications/$notificationId');
      
      // Supprimer la notification localement
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final notification = _notifications[index];
        
        // Supprimer de la liste
        _notifications.removeAt(index);
        
        // Mettre à jour le compteur si la notification n'était pas lue
        if (!notification.lue) {
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          _unreadCountController.add(_unreadCount);
        }
        
        // Émettre les nouvelles valeurs
        _notificationsController.add(_notifications);
      }
      
      return true;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'NotificationService.deleteNotification');
      return false;
    }
  }
  
  /// Démarre le rafraîchissement automatique des notifications
  void _startAutoRefresh() {
    // Annuler le timer existant s'il y en a un
    _refreshTimer?.cancel();
    
    // Créer un nouveau timer
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval),
      (_) => fetchNotifications(),
    );
  }
  
  /// Arrête le rafraîchissement automatique des notifications
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  /// Libère les ressources
  void dispose() {
    stopAutoRefresh();
    _notificationsController.close();
    _unreadCountController.close();
    _isInitialized = false;
  }
}
