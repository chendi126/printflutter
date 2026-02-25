
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

class ConfigProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  AppConfig _config;
  static const String _configKey = 'app_config';

  AppConfig get config => _config;

  ConfigProvider(this._prefs) : _config = AppConfig.defaultConfig() {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final jsonString = _prefs.getString(_configKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        _config = AppConfig.fromJson(jsonMap);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading config: $e');
      }
    }
  }

  Future<void> updateConfig(AppConfig newConfig) async {
    _config = newConfig;
    notifyListeners();
    await _saveConfig();
  }

  Future<void> _saveConfig() async {
    try {
      final jsonString = json.encode(_config.toJson());
      await _prefs.setString(_configKey, jsonString);
    } catch (e) {
      debugPrint('Error saving config: $e');
    }
  }

  void resetConfig() {
    updateConfig(AppConfig.defaultConfig());
  }
}
