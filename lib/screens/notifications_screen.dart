import 'package:flutter/material.dart';
import 'package:seatrace/models/notification.dart' as model;
import 'package:seatrace/services/notification_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/notification_item.dart';

/// Écran affichant la liste des notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool _isLoading = true;
  String? _errorMessage;
  List<model.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// Charge les notifications
  Future<void> _loadNotifications() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Initialiser le service de notifications
      await NotificationService.instance.initialize();
      
      // Récupérer les notifications
      final notifications = await NotificationService.instance.fetchNotifications();
      
      if (!mounted) return;
      
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Erreur lors du chargement des notifications';
        _isLoading = false;
      });
      
      ErrorHandler.instance.logError(e, context: 'NotificationsScreen._loadNotifications');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> _markAllAsRead() async {
    try {
      await NotificationService.instance.markAllAsRead();
      
      // Afficher un message de succès
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les notifications ont été marquées comme lues'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ErrorHandler.instance.handleAndShowError(
        context,
        e,
        errorContext: 'Marquer toutes les notifications comme lues',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Bouton pour marquer toutes les notifications comme lues
          StreamBuilder<int>(
            stream: NotificationService.instance.unreadCount,
            initialData: 0,
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Marquer tout comme lu',
                onPressed: unreadCount > 0 ? _markAllAsRead : null,
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Construit le corps de l'écran
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    
    return StreamBuilder<List<model.Notification>>(
      stream: NotificationService.instance.notifications,
      initialData: _notifications,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        
        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Aucune notification',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: () => NotificationService.instance.fetchNotifications(),
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              
              return NotificationItem(
                notification: notification,
                onMarkAsRead: (_) {
                  // La mise à jour est gérée par le service
                },
                onDelete: (_) {
                  // La suppression est gérée par le service
                },
              );
            },
          ),
        );
      },
    );
  }
}
