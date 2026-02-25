import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const _key = 'app_theme_option';
  ThemeOption _option = ThemeOption.system;

  ThemeOption get option => _option;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v == 'light') _option = ThemeOption.light;
    if (v == 'dark') _option = ThemeOption.dark;
    if (v == 'system') _option = ThemeOption.system;
    notifyListeners();
  }

  Future<void> setOption(ThemeOption option) async {
    _option = option;
    final prefs = await SharedPreferences.getInstance();
    final str = switch (option) { 
      ThemeOption.light => 'light',
      ThemeOption.dark => 'dark',
      ThemeOption.system => 'system',
    };
    await prefs.setString(_key, str);
    notifyListeners();
  }

  Brightness resolveBrightness(BuildContext context) => switch (_option) {
        ThemeOption.light => Brightness.light,
        ThemeOption.dark => Brightness.dark,
        ThemeOption.system => MediaQuery.platformBrightnessOf(context),
      };
}
