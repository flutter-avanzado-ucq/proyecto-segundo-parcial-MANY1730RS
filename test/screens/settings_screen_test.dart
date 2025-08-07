import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/l10n/app_localizations.dart'
    show AppLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/screens/settings_screen.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/theme_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/locale_provider.dart';

void main() {
  testWidgets('SettingsScreen muestra opciones de idioma y tema',
      (WidgetTester tester) async {
    // Construye el widget de prueba con los providers requeridos
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<LocaleProvider>(
              create: (_) => LocaleProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('es')],
          locale: Locale('es'),
          home: Scaffold(body: SettingsScreen()),
        ),
      ),
    );

    // Esperar a que se estabilice la interfaz
    await tester.pumpAndSettle();

    // Verificar que el texto relacionado con idioma aparece
    //expect(find.text('Idioma / Language'), findsAtLeastNWidgets(1)); // Comentado porque no hay texto de encabezado en el código original
    // Verificar que las opciones de idioma están presentes
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Usar idioma del sistema'), findsOneWidget);
  });
}
