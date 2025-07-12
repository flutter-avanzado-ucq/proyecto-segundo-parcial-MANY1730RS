import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/tarea_screen.dart';
import 'tema/tema_app.dart';
import 'package:provider/provider.dart';
import 'provider_task/task_provider.dart';
import 'models/task_model.dart';

// 🔔 Importar el servicio de notificaciones
import 'services/notification_service.dart';

void main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  // Integración Hive: inicialización de Hive
  await Hive.initFlutter();
  // Integración Hive: registro del adapter para Task
  Hive.registerAdapter(TaskAdapter());
  // Integración Hive: apertura de la caja tasksBox
  await Hive.openBox<Task>('tasksBox');

  // Inicializar notificaciones
  await NotificationService.initializeNotifications();

  // Pedir permiso para notificaciones (Android 13+ y iOS)
  await NotificationService.requestPermission();

  // Iniciar la app
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tareas Pro',
      theme: AppTheme.theme,
      home: const TaskScreen(),
    );
  }
}
