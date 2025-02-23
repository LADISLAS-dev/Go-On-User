import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Méthode pour sauvegarder la langue sélectionnée
  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  // Méthode pour récupérer la langue sauvegardée
  static Future<void> setLocaleFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode =
        prefs.getString('language') ?? 'en'; // Par défaut, 'en'
    Get.updateLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr), // Traduction du titre
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section pour changer la langue
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('language_settings'.tr), // Traduction du titre
            trailing: DropdownButton<String>(
              value: Get.locale?.languageCode ?? 'en', // Langue actuelle
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'it', child: Text('Italiano')),
              ],
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  Get.updateLocale(Locale(newValue)); // Changer la langue
                  await _saveLanguage(newValue); // Sauvegarder la langue
                }
              },
            ),
          ),
          // Autres paramètres
          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: Text('notification_settings'.tr), // Traduction du titre
          //   trailing: Switch(
          //     value: true,
          //     onChanged: (bool value) {
          //       // Logique pour activer/désactiver les notifications
          //     },
          //   ),
          // ),
          // ListTile(
          //   leading: const Icon(Icons.dark_mode),
          //   title: Text('theme_settings'.tr), // Traduction du titre
          //   trailing: Switch(
          //     value: false,
          //     onChanged: (bool value) {
          //       // Logique pour activer/désactiver le mode sombre
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
