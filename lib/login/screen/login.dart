import 'package:appointy/pages/business/business_home_page.dart';
import 'package:flutter/material.dart';
import 'package:appointy/login/Services/authentification.dart';
import 'package:appointy/login/screen/sign_up.dart';
import 'package:appointy/login/widget/button.dart';
import 'package:appointy/login/widget/forget_password.dart';
import 'package:appointy/login/widget/snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Méthode pour connecter les utilisateurs
  void logInUsers() async {
    // Vérifier si les champs sont vides
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ShowSnackBar(context, 'Please enter both email and password');
      return;
    }

    setState(() {
      isLoading = true; // Affiche le spinner de chargement
    });

    // Appel du service d'authentification
    String res = await AuthService().loginUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() {
      isLoading = false; // Désactive le spinner après la réponse
    });

    // Vérifier la réponse de l'API
    if (res == 'Success') {
      print('Connexion réussie, redirection vers HomePage...');
      if (!mounted) return; // Vérifiez si le widget est encore monté
      // Redirection vers la page d'accueil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(
            businessId: '',
          ),
        ),
      );
    } else {
      // Afficher un message d'erreur
      print('Échec de la connexion : $res');
      ShowSnackBar(context, res);
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
              // Image d'en-tête
              SizedBox(
                width: double.infinity,
                height: height / 2.7,
                child: Image.asset('images/login2.webp'),
              ),
              // Champ de texte pour l'email
              TextFieldInpute(
                textEditingController: emailController,
                hintText: 'Enter your email',
                icon: Icons.email,
                isObscure: false,
                onFocusChange: (hasFocus) {},
                onChanged: (String value) {},
              ),
              // Champ de texte pour le mot de passe
              TextFieldInpute(
                textEditingController: passwordController,
                hintText: 'Enter your password',
                icon: Icons.lock,
                isObscure: true,
                onFocusChange: (hasFocus) {},
                onChanged: (String value) {},
              ),
              // Lien "Mot de passe oublié"
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ForgotPassword(),
                ),
              ),
              SizedBox(height: height / 55),
              // Bouton de connexion ou spinner de chargement
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTab: logInUsers,
                      text: 'Log In',
                    ),
              SizedBox(height: height / 15),
              // Lien vers l'écran d'inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      ' Sign Up',
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
  final Function(bool)? onFocusChange;
  final Function(String)? onChanged;

  const TextFieldInpute({
    Key? key,
    required this.textEditingController,
    required this.hintText,
    required this.icon,
    this.isObscure = false,
    this.onFocusChange,
    this.onChanged,
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
        onChanged: widget.onChanged,
        onTap: () {
          if (widget.onFocusChange != null) {
            widget.onFocusChange!(true);
          }
        },
        onTapOutside: (_) {
          if (widget.onFocusChange != null) {
            widget.onFocusChange!(false);
          }
        },
      ),
    );
  }
}
