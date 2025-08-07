import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animaciones_notificaciones/l10n/app_localizations.dart';

import 'package:flutter_animaciones_notificaciones/widgets/card_tarea.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';

void main() {
  testWidgets('TaskCard muestra el título y responde al botón de check',
      (WidgetTester tester) async {
    // Variable booleana para verificar si el botón fue presionado
    bool fueMarcado = false;

    // Creamos un AnimationController simulado con un VSync falso
    final animationController = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 500),
    );

    // Construimos la app y montamos el widget a testear
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es')],
        home: ChangeNotifierProvider<HolidayProvider>(
          create: (_) => HolidayProvider(),
          builder: (context, _) => Scaffold(
            body: TaskCard(
              title: 'Tarea de prueba',
              isDone: false,
              onToggle: () {
                // Este callback debe activarse cuando se presiona el botón de check
                fueMarcado = true;
              },
              onDelete: () {}, // No se testea en este caso
              iconRotation: animationController,
              index: 0,
            ),
          ),
        ),
      ),
    );

    // Verificar que el título de la tarea aparece en pantalla
    expect(find.text('Tarea de prueba'), findsOneWidget);

    // Verificar que el icono de tarea NO completada se muestra
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

    // Simular un toque sobre el icono de tarea no completada
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));

    // Volver a renderizar la UI después del tap
    await tester.pump();

    // Verificar que la variable se actualizó al tocar el botón
    expect(fueMarcado, isTrue);
  });
}

// Clase que simula un VSync necesario para el AnimationController en pruebas
class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(onTick) => Ticker(onTick);
}
