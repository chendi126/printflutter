
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

class ConfigProvider with ChangeNotifier {
  AppConfig _config;
  static const String _configKey = 'app_config';

  AppConfig get config => _config;

  ConfigProvider() : _config = AppConfig.defaultConfig() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configString = prefs.getString(_configKey);
    if (configString != null) {
      try {
        final jsonMap = json.decode(configString);
        _config = AppConfig.fromJson(jsonMap);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading config: $e');
      }
    }
  }

  Future<void> saveConfig({bool notify = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final configString = json.encode(_config.toJson());
    await prefs.setString(_configKey, configString);
    if (notify) notifyListeners();
  }

  void updateConfig(AppConfig newConfig) {
    _config = newConfig;
    saveConfig();
  }

  void resetConfig() {
    _config = AppConfig.defaultConfig();
    saveConfig();
  }
}
