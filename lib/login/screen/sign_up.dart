import 'package:flutter/material.dart';
import 'package:appointy/login/Services/authentification.dart';
import 'package:appointy/login/screen/login.dart';
import 'package:appointy/login/widget/button.dart';
import 'package:appointy/login/widget/snack_bar.dart';
import 'package:appointy/pages/business/business_home_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController(); // Nouveau contrôleur
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose(); // Dispose du nouveau contrôleur
    nameController.dispose();
    super.dispose();
  }

  // Méthode d'inscription
  void signUpUser() async {
    // Vérifier si les mots de passe correspondent
    if (passwordController.text != confirmPasswordController.text) {
      ShowSnackBar(context, 'Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true; // Activer le spinner
    });

    String res = await AuthService().signUpUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
    );

    setState(() {
      isLoading = false; // Désactiver le spinner après la réponse
    });

    if (res == 'Successfully registered') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(businessId: ''),
        ),
      );
    } else {
      ShowSnackBar(context, res); // Afficher un message d'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: height / 2.7,
                child: Image.asset('images/1.webp'),
              ),
              // Champ de texte pour le nom
              TextFieldInpute(
                textEditingController: nameController,
                hintText: 'Enter your name',
                icon: Icons.person,
              ),
              // Champ de texte pour l'email
              TextFieldInpute(
                textEditingController: emailController,
                hintText: 'Enter your email',
                icon: Icons.email,
              ),
              // Champ de texte pour le mot de passe (obscurci)
              TextFieldInpute(
                textEditingController: passwordController,
                hintText: 'Enter your password',
                icon: Icons.lock,
                isObscure: true,
              ),
              // Champ de texte pour la vérification du mot de passe (obscurci)
              TextFieldInpute(
                textEditingController: confirmPasswordController,
                hintText: 'Confirm your password',
                icon: Icons.lock,
                isObscure: true,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTab: signUpUser,
                      text: 'Sign Up',
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      ' Log In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personnalisé pour les champs de texte
class TextFieldInpute extends StatefulWidget {
  final TextEditingController textEditingController;
  final String hintText;
  final IconData icon;
  final bool isObscure;

  const TextFieldInpute({
    Key? key,
    required this.textEditingController,
    required this.hintText,
    required this.icon,
    this.isObscure = false,
  }) : super(key: key);

  @override
  _TextFieldInputeState createState() => _TextFieldInputeState();
}

class _TextFieldInputeState extends State<TextFieldInpute> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: widget.textEditingController,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget.isObscure
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        obscureText: widget.isObscure ? _isObscure : false,
      ),
    );
  }
}
