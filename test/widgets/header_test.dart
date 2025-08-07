import 'dart:io';
import 'package:flutter/material.dart';

// Importamos la clase de localización para mostrar textos traducidos
import 'package:flutter_animaciones_notificaciones/l10n/app_localizations.dart'
    show AppLocalizations;

// Servicios de clima y feriados (no se usan directamente aquí, pero sus modelos sí)
import 'package:flutter_animaciones_notificaciones/services/holiday_service.dart';
import 'package:flutter_animaciones_notificaciones/services/weather_service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Widget y providers a testear
import 'package:flutter_animaciones_notificaciones/widgets/header.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/weather_provider.dart';

// Simulación de un WeatherProvider con datos fijos
class FakeWeatherProvider extends WeatherProvider {
  @override
  WeatherData? get weatherData => WeatherData(
        temperature: 25.5,
        description: 'Soleado',
        cityName: 'Querétaro',
        iconCode: '01d',
      );

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;
}

// Simulación de un HolidayProvider con un feriado falso
class FakeHolidayProvider extends HolidayProvider {
  @override
  Holiday? get todayHoliday => Holiday(
        localName: 'Día de prueba',
        date: DateTime.now(),
      );
}

void main() {
  // Este override evita llamadas HTTP reales durante las pruebas
  setUpAll(() => HttpOverrides.global = _NoNetworkHttpOverrides());

  testWidgets('Header muestra feriado y clima correctamente', (tester) async {
    // Construimos el widget completo con los providers falsos y MaterialApp
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WeatherProvider>(
            create: (_) => FakeWeatherProvider(),
          ),
          ChangeNotifierProvider<HolidayProvider>(
            create: (_) => FakeHolidayProvider(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es')],
          home: const Scaffold(
            body: Header(), // Este es el widget que se está testeando
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Esperamos a que se renderice por completo

    // Verificamos que el texto del feriado esté presente (revisamos la palabra 'feriado')
    expect(find.textContaining('feriado'), findsOneWidget);

    // Verificamos que la temperatura esté presente en el texto del clima
    expect(find.textContaining('25.5'), findsOneWidget);

    // Verificamos que la descripción del clima también esté visible
    expect(find.textContaining('Soleado'), findsOneWidget);
  });
}

// Override para bloquear llamadas HTTP externas durante el test
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw UnsupportedError('No HTTP requests allowed in widget tests');
  }
}
