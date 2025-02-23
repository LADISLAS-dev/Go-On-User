import 'package:appointy/login/Services/authentification.dart';
import 'package:appointy/login/screen/login.dart';
import 'package:appointy/login/widget/button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Congratulations\nYou have Successfully Logged In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Augmenter légèrement la taille
                  color: Colors.black87, // Ajouter une couleur lisible
                ),
              ),
              const SizedBox(
                  height: 20), // Espacement entre le texte et le bouton
              MyButton(
                onTab: () async {
                  await AuthService().signOut(); // Déconnexion
                  if (context.mounted) {
                    // Vérifier si le contexte est toujours valide
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                text: 'Log Out',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
