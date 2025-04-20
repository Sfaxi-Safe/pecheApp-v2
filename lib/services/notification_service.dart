// Importation des packages Flutter nécessaires
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';

/// Classe représentant une notification dans l'application
/// Contient toutes les informations nécessaires pour afficher et gérer une notification
class Notification {
  final int id;                 // Identifiant unique de la notification
  final String title;           // Titre de la notification
  final String message;         // Message détaillé de la notification
  final DateTime timestamp;     // Date et heure de la notification
  final String type;            // Type de notification (ex: 'order', 'message', 'payment')
  final bool isRead;            // Indique si la notification a été lue
  final String? actionData;     // Données supplémentaires pour l'action (ex: ID de commande)

  // Constructeur principal
  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.actionData,
  });

  // Constructeur de factory pour créer une notification à partir d'une Map
  // Utilisé pour convertir les données de la base de données en objet Notification
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      type: map['type'],
      isRead: map['is_read'] == 1,
      actionData: map['action_data'],
    );
  }

  // Convertir l'objet Notification en Map pour le stockage dans la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'is_read': isRead ? 1 : 0,
      'action_data': actionData,
    };
  }
}

/// Service de gestion des notifications
/// Permet de charger, créer, marquer comme lu et supprimer des notifications
class NotificationService with ChangeNotifier {
  final List<Notification> _notifications = []; // Liste des notifications
  bool _isLoading = false;                      // Indique si le service est en train de charger des données
  String? _userId;                              // ID de l'utilisateur connecté
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Accès à la base de données

  // Getters pour accéder aux propriétés privées
  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Initialiser le service avec l'ID de l'utilisateur
  Future<void> init(String userId) async {
    _userId = userId;
    await loadNotifications(); // ← attend que les notifications soient chargées
  }

  /// Charger les notifications de l'utilisateur depuis la base de données
  Future<void> loadNotifications() async {
    // Vérifier si l'utilisateur est connecté
    if (_userId == null) return;

    // Indiquer que le chargement est en cours
    _isLoading = true;
    notifyListeners();

    try {
      // Simuler le chargement des notifications depuis la base de données
      // Dans une implémentation réelle, vous récupéreriez les notifications depuis la base de données
      await Future.delayed(const Duration(milliseconds: 500));

      // Exemple de notifications
      _notifications.clear();
      _notifications.addAll([
        Notification(
          id: 1,
          title: 'Nouvelle commande',
          message: 'Vous avez reçu une nouvelle commande #12345',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'order',
          isRead: false,
          actionData: '12345',
        ),
        Notification(
          id: 2,
          title: 'Paiement reçu',
          message: 'Le paiement pour la commande #12345 a été reçu',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'payment',
          isRead: true,
          actionData: '12345',
        ),
        Notification(
          id: 3,
          title: 'Nouveau message',
          message: 'Vous avez reçu un nouveau message de Jean Dupont',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: 'message',
          isRead: true,
          actionData: 'user_123',
        ),
      ]);
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
    } finally {
      // Indiquer que le chargement est terminé
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    // Trouver l'index de la notification dans la liste
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      // Récupérer la notification existante
      final notification = _notifications[index];
      
      // Créer une nouvelle notification avec isRead = true
      final updatedNotification = Notification(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        type: notification.type,
        isRead: true,
        actionData: notification.actionData,
      );

      // Mettre à jour la notification dans la liste
      _notifications[index] = updatedNotification;
      notifyListeners();

      // Mettre à jour dans la base de données
      // Dans une implémentation réelle, vous mettriez à jour la notification dans la base de données
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    // Parcourir toutes les notifications
    for (int i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      // Ne mettre à jour que les notifications non lues
      if (!notification.isRead) {
        _notifications[i] = Notification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          type: notification.type,
          isRead: true,
          actionData: notification.actionData,
        );
      }
    }
    notifyListeners();

    // Mettre à jour dans la base de données
    // Dans une implémentation réelle, vous mettriez à jour toutes les notifications dans la base de données
  }

  /// Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    // Supprimer la notification de la liste
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();

    // Supprimer de la base de données
    // Dans une implémentation réelle, vous supprimeriez la notification de la base de données
  }

  /// Ajouter une nouvelle notification
  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
    String? actionData,
  }) async {
    // Créer une nouvelle notification
    final newNotification = Notification(
      id: _notifications.isEmpty ? 1 : _notifications.last.id + 1,
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      actionData: actionData,
    );

    // Ajouter la notification au début de la liste
    _notifications.insert(0, newNotification);
    notifyListeners();

    // Dans une implémentation réelle, vous ajouteriez la notification à la base de données
  }

  /// Gérer l'action lorsqu'une notification est tapée
  void handleNotificationTap(BuildContext context, Notification notification) {
    // Naviguer vers l'écran approprié en fonction du type de notification
    switch (notification.type) {
      case 'order':
        if (notification.actionData != null) {
          // Naviguer vers les détails de la commande
          // Navigator.pushNamed(context, '/order-details', arguments: {'orderId': notification.actionData});
        }
        break;
      case 'message':
        if (notification.actionData != null) {
          // Naviguer vers la conversation
          // Navigator.pushNamed(context, '/chat', arguments: {'userId': notification.actionData});
        }
        break;
      case 'payment':
        // Naviguer vers l'écran des paiements
        // Navigator.pushNamed(context, '/payments');
        break;
      default:
        // Par défaut, ne rien faire
        break;
    }

    // Marquer la notification comme lue
    markAsRead(notification.id);
  }
}
