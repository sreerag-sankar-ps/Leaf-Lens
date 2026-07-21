import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease_analysis.dart';

class StorageService {
  static const String _apiKeyKey = 'api_key';
  static const String _historyKey = 'analysis_history';
  static const int _maxHistoryItems = 50;

  Future<bool> hasApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_apiKeyKey);
    return key != null && key.isNotEmpty;
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }

  Future<void> saveAnalysis(DiseaseAnalysis analysis) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    historyJson.insert(0, jsonEncode(analysis.toJson()));
    if (historyJson.length > _maxHistoryItems) {
      historyJson.removeRange(_maxHistoryItems, historyJson.length);
    }
    await prefs.setStringList(_historyKey, historyJson);
  }

  Future<List<DiseaseAnalysis>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    return historyJson
        .map((json) {
          try {
            return DiseaseAnalysis.fromJson(jsonDecode(json));
          } catch (e) {
            return null;
          }
        })
        .whereType<DiseaseAnalysis>()
        .toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    if (index >= 0 && index < historyJson.length) {
      historyJson.removeAt(index);
      await prefs.setStringList(_historyKey, historyJson);
    }
  }
}
