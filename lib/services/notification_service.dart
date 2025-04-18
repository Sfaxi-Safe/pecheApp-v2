import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io';
import 'dart:math';
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Singleton pattern
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialiser les fuseaux horaires
    tz_data.initializeTimeZones();

    // Initialiser les paramètres pour Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialiser les paramètres pour iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialiser les paramètres pour tous les plateformes
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialiser le plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Gérer les actions de notification
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
          // Naviguer vers l'écran approprié en fonction du payload
        }
      },
    );

    _isInitialized = true;
  }

  // Demander les permissions de notification (iOS uniquement)
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  // Afficher une notification immédiate
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'peche_app_channel',
      'Pêche App Notifications',
      channelDescription: 'Notifications pour l\'application Pêche App',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      Random().nextInt(1000), // ID unique pour chaque notification
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Planifier une notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await init();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'peche_app_channel',
      'Pêche App Notifications',
      channelDescription: 'Notifications pour l\'application Pêche App',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      Random().nextInt(1000), // ID unique pour chaque notification
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Ajout requis
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time, // ✅ Optionnel selon le besoin
    );

  }

  // Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
