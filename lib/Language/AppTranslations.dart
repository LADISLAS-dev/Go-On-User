import 'dart:convert';
import 'package:flutter/services.dart';

class AppTranslations {
  late Map<String, dynamic> _localizedStrings;

  Future<void> load(String languageCode) async {
    String jsonString = await rootBundle.loadString('lang/$languageCode.json');
    _localizedStrings = json.decode(jsonString);
  }

  String translate(String key) {
    return _localizedStrings[key] ??
        key; // Retourne la clé si la traduction n'est pas trouvée
  }
}
