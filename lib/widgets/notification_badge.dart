import 'package:flutter/material.dart';
import 'package:seatrace/services/notification_service.dart';

/// Widget affichant un badge de notification avec le nombre de notifications non lues
class NotificationBadge extends StatelessWidget {
  /// Icône à afficher
  final IconData icon;
  
  /// Taille de l'icône
  final double iconSize;
  
  /// Couleur de l'icône
  final Color? iconColor;
  
  /// Couleur du badge
  final Color? badgeColor;
  
  /// Couleur du texte du badge
  final Color? badgeTextColor;
  
  /// Callback appelé lorsque l'utilisateur appuie sur le badge
  final VoidCallback? onTap;
  
  /// Indique si le badge doit être affiché même s'il n'y a pas de notifications non lues
  final bool showZero;

  const NotificationBadge({
    Key? key,
    this.icon = Icons.notifications,
    this.iconSize = 24.0,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.onTap,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return StreamBuilder<int>(
      stream: NotificationService.instance.unreadCount,
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        
        // Ne pas afficher le badge si le compteur est à zéro et showZero est false
        final showBadge = count > 0 || showZero;
        
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? theme.iconTheme.color,
              ),
              if (showBadge)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: badgeColor ?? theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: TextStyle(
                          color: badgeTextColor ?? Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
