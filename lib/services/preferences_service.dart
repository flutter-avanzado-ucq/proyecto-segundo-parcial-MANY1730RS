import 'package:hive/hive.dart';

class PreferencesService {
  // Nombre de la caja Hive donde se guardan las preferencias de la app
  static const String _boxName = 'preferences_box';
  // Clave para almacenar el valor del modo oscuro
  static const String _themeKey = 'isDarkMode';

  // Guarda en Hive si el tema es oscuro (true) o claro (false)
  static Future<void> setDarkMode(bool isDark) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, isDark);
  }

  // Obtiene de Hive el valor guardado para el modo oscuro, si no existe devuelve false por defecto
  static Future<bool> getDarkMode() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_themeKey, defaultValue: false);
  }
}
