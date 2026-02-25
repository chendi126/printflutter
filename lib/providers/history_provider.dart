
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_record.dart';

class HistoryProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  List<HistoryRecord> _records = [];
  static const String _historyKey = 'print_history';

  List<HistoryRecord> get records => List.unmodifiable(_records);

  HistoryProvider(this._prefs) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final historyString = _prefs.getString(_historyKey);
    if (historyString != null) {
      try {
        final List<dynamic> jsonList = json.decode(historyString);
        _records = jsonList.map((e) => HistoryRecord.fromJson(e)).toList();
        // 按时间倒序排序
        _records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading history: $e');
      }
    }
  }

  Future<void> addRecord(HistoryRecord record) async {
    _records.insert(0, record);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeRecord(String id) async {
    _records.removeWhere((record) => record.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _records.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final historyString = json.encode(_records.map((e) => e.toJson()).toList());
    await _prefs.setString(_historyKey, historyString);
  }
}
