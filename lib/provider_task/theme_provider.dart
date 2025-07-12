import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  // Variable privada que almacena el estado actual del tema (oscuro o claro)
  bool _isDarkMode = false;

  // Getter publico para obtener el estado actual del tema
  bool get isDarkMode => _isDarkMode;

  // Constructor: carga el estado guardado del tema cuando se crea la instancia
  ThemeProvider() {
    loadTheme();
  }

  // Metodo para cargar el tema guardado en almacenamiento local (Hive)
  Future<void> loadTheme() async {
    _isDarkMode = await PreferencesService.getDarkMode();
    // Notifica a los widgets que el estado ha cambiado para que se actualicen
    notifyListeners();
  }

  // Metodo para cambiar entre tema claro y oscuro
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    // Guarda el nuevo estado del tema en el almacenamiento local (Hive)
    await PreferencesService.setDarkMode(_isDarkMode);
    // Notifica a los widgets que el estado ha cambiado para actualizar la UI
    notifyListeners();
  }
}
