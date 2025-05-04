import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seatrace/models/notification.dart' as model;
import 'package:seatrace/services/notification_service.dart';
import 'package:seatrace/utils/navigation_service.dart';

/// Widget affichant une notification
class NotificationItem extends StatelessWidget {
  /// Notification à afficher
  final model.Notification notification;
  
  /// Callback appelé lorsque la notification est marquée comme lue
  final Function(model.Notification)? onMarkAsRead;
  
  /// Callback appelé lorsque la notification est supprimée
  final Function(model.Notification)? onDelete;
  
  /// Indique si la notification doit être affichée de manière compacte
  final bool isCompact;

  const NotificationItem({
    Key? key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Déterminer la couleur en fonction du type de notification
    Color typeColor;
    IconData typeIcon;
    
    switch (notification.type) {
      case 'success':
        typeColor = Colors.green;
        typeIcon = Icons.check_circle;
        break;
      case 'warning':
        typeColor = Colors.orange;
        typeIcon = Icons.warning;
        break;
      case 'error':
        typeColor = Colors.red;
        typeIcon = Icons.error;
        break;
      case 'info':
      default:
        typeColor = theme.colorScheme.primary;
        typeIcon = Icons.info;
        break;
    }
    
    // Formater la date
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(notification.createdAt);
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        NotificationService.instance.deleteNotification(notification.id);
        if (onDelete != null) {
          onDelete!(notification);
        }
      },
      child: InkWell(
        onTap: () {
          // Marquer comme lue
          if (!notification.lue) {
            NotificationService.instance.markAsRead(notification.id);
            if (onMarkAsRead != null) {
              onMarkAsRead!(notification);
            }
          }
          
          // Naviguer vers l'URL d'action si elle existe
          if (notification.urlAction != null && notification.urlAction!.isNotEmpty) {
            NavigationService().navigateToRoute(context, notification.urlAction!);
          }
        },
        child: Container(
          padding: EdgeInsets.all(isCompact ? 8 : 16),
          decoration: BoxDecoration(
            color: notification.lue
                ? null
                : typeColor.withOpacity(0.05),
            border: Border(
              left: BorderSide(
                color: typeColor,
                width: 4,
              ),
              bottom: BorderSide(
                color: theme.dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône du type de notification
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: isCompact ? 16 : 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Contenu de la notification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre et date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.lue ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isCompact) ...[
                          const SizedBox(width: 8),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isCompact) ...[
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                    
                    // Contenu
                    const SizedBox(height: 4),
                    Text(
                      notification.contenu,
                      style: theme.textTheme.bodyMedium,
                      maxLines: isCompact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Lien d'action
                    if (notification.urlAction != null && notification.urlAction!.isNotEmpty && !isCompact) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Marquer comme lue
                              if (!notification.lue) {
                                NotificationService.instance.markAsRead(notification.id);
                                if (onMarkAsRead != null) {
                                  onMarkAsRead!(notification);
                                }
                              }
                              
                              // Naviguer vers l'URL d'action
                              NavigationService().navigateToRoute(context, notification.urlAction!);
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Voir les détails'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
