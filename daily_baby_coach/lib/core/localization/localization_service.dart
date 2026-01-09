import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading and accessing localized strings
class LocalizationService {
  Map<String, String> _strings = {};
  String _currentLocale = 'en';

  String get currentLocale => _currentLocale;

  /// Load translations for a given locale
  Future<void> load(String locale) async {
    _currentLocale = locale;

    try {
      final jsonString = await rootBundle.loadString('assets/i18n/$locale.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      _strings = json.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      // If locale file not found, fallback to English
      if (locale != 'en') {
        await load('en');
      } else {
        _strings = {'app_name': 'Daily Baby Coach'};
      }
    }
  }

  /// Translate a key to localized string
  /// Returns the key itself if translation not found
  String t(String key) {
    return _strings[key] ?? key;
  }

  /// Check if a key exists
  bool hasKey(String key) {
    return _strings.containsKey(key);
  }

  /// Get all available strings (for debugging)
  Map<String, String> get allStrings => Map.unmodifiable(_strings);
}
