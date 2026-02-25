import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const _key = 'app_theme_option';
  final SharedPreferences _prefs;
  ThemeOption _option = ThemeOption.system;

  ThemeProvider(this._prefs) {
    _load();
  }

  ThemeOption get option => _option;

  void _load() {
    final v = _prefs.getString(_key);
    if (v == 'light') _option = ThemeOption.light;
    if (v == 'dark') _option = ThemeOption.dark;
    if (v == 'system') _option = ThemeOption.system;
    notifyListeners();
  }

  Future<void> setOption(ThemeOption option) async {
    _option = option;
    notifyListeners();
    String val = 'system';
    if (option == ThemeOption.light) val = 'light';
    if (option == ThemeOption.dark) val = 'dark';
    await _prefs.setString(_key, val);
  }

  Brightness resolveBrightness(BuildContext context) => switch (_option) {
        ThemeOption.light => Brightness.light,
        ThemeOption.dark => Brightness.dark,
        ThemeOption.system => MediaQuery.platformBrightnessOf(context),
      };
}
