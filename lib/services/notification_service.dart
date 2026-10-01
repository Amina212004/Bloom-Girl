import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      print("Erreur d'initialisation des notifications: $e");
    }
  }

  /// Notification immédiate ou test
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'bloom_rose_channel',
      'Rappels Bloom Rose 🌸',
      channelDescription: 'Notifications de rappels de cycle, ovulation et hydratation',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.show(id, title, body, details);
    } catch (e) {
      print("Erreur d'affichage notification: $e");
    }
  }

  /// Programmation d'un rappel d'eau à boire
  Future<void> scheduleWaterReminder() async {
    await showNotification(
      id: 101,
      title: 'Hydratation 💧🌸',
      body: 'Coucou ma belle ! Pense à boire un grand verre d\'eau fraîche pour prendre soin de toi.',
    );
  }

  /// Rappel préventif de règles
  Future<void> schedulePeriodReminder(int daysUntil) async {
    await showNotification(
      id: 102,
      title: 'Suivi de Cycle 🌸',
      body: 'Tes règles sont prévues dans $daysUntil jour(s). Prépare ta bouillotte et tes soins douillets !',
    );
  }

  /// Rappel d'ovulation
  Future<void> scheduleOvulationReminder() async {
    await showNotification(
      id: 103,
      title: 'Période d\'Ovulation 🥚✨',
      body: 'Tu entre dans ta phase ovulatoire ! Ton énergie et ta créativité sont au maximum.',
    );
  }
}
