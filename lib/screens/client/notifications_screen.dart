import 'package:flutter/material.dart';
import 'package:peche_app/utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Données simulées pour les notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Bar commun disponible',
      'message': 'Le poisson que vous recherchiez est maintenant disponible au Marché aux poissons du port.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'fish',
      'read': false,
    },
    {
      'id': '2',
      'title': 'Marché de la Criée ouvert',
      'message': 'Le marché à proximité de votre position est maintenant ouvert.',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'type': 'market',
      'read': true,
    },
    {
      'id': '3',
      'title': 'Nouvelle capture de Pierre Dupont',
      'message': 'Le pêcheur que vous suivez a ajouté une nouvelle capture: Dorade royale.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'fisherman',
      'read': false,
    },
    {
      'id': '4',
      'title': 'Promotion sur les maquereaux',
      'message': 'Profitez d\'une réduction de 15% sur les maquereaux aujourd\'hui à la Poissonnerie de la Plage.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'promotion',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // Marquer toutes les notifications comme lues
              setState(() {
                for (var notification in _notifications) {
                  notification['read'] = true;
                }
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications ont été marquées comme lues'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Tout marquer comme lu',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Text(
                'Aucune notification',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final DateTime time = notification['time'];
    final bool isToday = time.day == DateTime.now().day &&
        time.month == DateTime.now().month &&
        time.year == DateTime.now().year;
    
    String timeText;
    if (isToday) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      timeText = 'Aujourd\'hui à $hour:$minute';
    } else if (time.day == DateTime.now().day - 1 &&
        time.month == DateTime.now().month &&
        time.year == DateTime.now().year) {
      timeText = 'Hier';
    } else {
      timeText = '${time.day}/${time.month}/${time.year}';
    }
    
    IconData iconData;
    Color iconColor;
    
    switch (notification['type']) {
      case 'fish':
        iconData = Icons.set_meal;
        iconColor = Colors.blue;
        break;
      case 'market':
        iconData = Icons.store;
        iconColor = Colors.green;
        break;
      case 'fisherman':
        iconData = Icons.person;
        iconColor = Colors.orange;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((item) => item['id'] == notification['id']);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification supprimée'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: notification['read'] ? 0 : 2,
        color: notification['read'] ? Colors.white : Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          title: Text(
            notification['title'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: notification['read'] ? FontWeight.normal : FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                notification['message'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          onTap: () {
            // Marquer comme lu et naviguer vers le contenu approprié
            setState(() {
              notification['read'] = true;
            });
            
            // Navigation en fonction du type de notification
            switch (notification['type']) {
              case 'fish':
                // Naviguer vers la recherche de poisson
                break;
              case 'market':
                // Naviguer vers la carte
                break;
              case 'fisherman':
                // Naviguer vers le profil du pêcheur
                break;
              case 'promotion':
                // Naviguer vers les promotions
                break;
            }
          },
        ),
      ),
    );
  }
}
