import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Servicio que centraliza toda la logica de notificaciones.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializacion basica del sistema de notificaciones.
  static Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializa las zonas horarias para programar notificaciones con hora exacta.
    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  // Se ejecuta cuando el usuario interactúa con la notificacion.
  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      print('🔔 Payload: ${response.payload}');
    }
  }

  // Solicita permisos de notificaciones al usuario si no estan dados.
  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }

    // iOS: Solicita permisos especificos para alertas, sonidos y badges.
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // Muestra una notificacion inmediata (no programada).
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notificaciones Instantáneas',
      channelDescription: 'Canal para notificaciones inmediatas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // 2. El ID de la notificacion se genera dinamicamente con la hora actual (sin persistencia).
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // ID dinamico
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Programa una notificacion para que se muestre en el futuro.
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int
    notificationId, // 2. Aqui se recibe el notificationId para identificarla luego.
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones Programadas',
      channelDescription: 'Canal para recordatorios de tareas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      notificationId, // 2. Se usa este ID para permitir cancelacion o actualizacion despues.
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // 3. Metodo para cancelar una notificacion programada. Se usa cuando la tarea se borra o se edita.
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
