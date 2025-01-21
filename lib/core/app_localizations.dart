import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  static Map<String, String> _localizedStrings = {};

  static Future<void> load(String languageCode) async {
    String jsonString = await rootBundle.loadString('l10n/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  static String getString(String key, String defaultValue) {
    return _localizedStrings[key] ?? defaultValue;
  }
}
