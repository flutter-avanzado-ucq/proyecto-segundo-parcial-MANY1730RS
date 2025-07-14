import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/l10n/app_localizations.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/locale_provider.dart';
// Integración Hive: importación de Hive Flutter
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/tarea_screen.dart';
import 'tema/tema_app.dart';
import 'package:provider/provider.dart';
import 'provider_task/task_provider.dart';
import 'provider_task/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Importar modelo para Hive
import 'models/task_model.dart';

// Importar el servicio de notificaciones
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()), // ✅ NUEVO
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tareas Pro',
      theme: AppTheme.theme,
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      locale: localeProvider.locale,

      // NUEVO: Configuración de internacionalización
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // Español
      ],

      home: const TaskScreen(),
    );
  }
}
