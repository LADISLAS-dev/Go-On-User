import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'Français'; // Langue par défaut
  Locale _locale = const Locale('fr', 'FR'); // Locale par défaut (Français)
  final Locale _currentLocale = const Locale('en', 'US');

  String get language => _language;
  Locale get locale => _locale; // Getter pour la locale
  Locale get currentLocale => _currentLocale;

  void changeLanguage(String newLanguage) {
    _language = newLanguage;
    switch (newLanguage) {
      case 'Français':
        _locale = const Locale('fr', 'FR'); // Locale pour le français
        break;
      case 'Anglais':
        _locale = const Locale('en', 'US'); // Locale pour l'anglais
        break;
      case 'Espagnol':
        _locale = const Locale('es', 'ES'); // Locale pour l'espagnol
        break;
      case 'Italien':
        _locale = const Locale('it', 'IT'); // Locale pour l'italien
        break;
    }
    notifyListeners(); // Notifie tous les écouteurs que la langue a changé
  }

  void setLanguage(String s) {}

  loadSavedLocale() {}
}
