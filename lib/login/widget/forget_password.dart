import 'package:appointy/login/widget/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Libérer les ressources
    emailController.dispose();
    super.dispose();
  }

  void showDialogBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // Espacement
                    const Text(
                      'Forgot Your Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Champ de texte pour l'email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter your email',
                    hintText: 'e.g., abc@gmail.com',
                  ),
                ),
                const SizedBox(height: 20),
                // Bouton pour envoyer le lien de réinitialisation
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                  ),
                  onPressed: () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      ShowSnackBar(context, 'Please enter your email');
                      return;
                    }

                    try {
                      await auth.sendPasswordResetEmail(email: email);
                      Navigator.pop(context); // Fermer la boîte de dialogue
                      ShowSnackBar(context,
                          'A reset password link has been sent to your email.');
                      emailController.clear(); // Effacer le champ
                    } catch (error) {
                      ShowSnackBar(context, 'Error: ${error.toString()}');
                    }
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: InkWell(
        onTap: () {
          showDialogBox(context);
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF9C27B0),
          ),
        ),
      ),
    );
  }
}
