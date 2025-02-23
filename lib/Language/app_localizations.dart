import 'package:intl/intl.dart';

class AppLocalizations {
  static String get welcome {
    return Intl.message(
      'Bienvenue',
      name: 'welcome',
      desc: 'Message de bienvenue',
    );
  }

  static String get home {
    return Intl.message(
      'Accueil',
      name: 'home',
      desc: 'Texte pour l\'accueil',
    );
  }

  // Ajoutez d'autres textes ici
}
