import 'dart:async';
import 'package:appointy/Language/language_provider.dart';
import 'package:appointy/Language/service.dart';
import 'package:appointy/login/screen/login.dart';
import 'package:appointy/pages/business/business_home_page.dart';
import 'package:appointy/pages/intro/intro_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp();

  // Chargement de la langue sauvegardée
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLocale();

  runApp(
    ChangeNotifierProvider(
      create: (_) => languageProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reservation App',
      theme: ThemeData(primarySwatch: Colors.purple),
      translations: LanguageTranslation(),
      locale: languageProvider.currentLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('es', 'ES'),
        Locale('it', 'IT'),
      ],
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ShowHome') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasSeenOnboarding(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (onboardingSnapshot.hasError) {
          return const ErrorScreen();
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (authSnapshot.hasError) {
              return const ErrorScreen();
            }

            final bool hasSeenOnboarding = onboardingSnapshot.data ?? false;
            final bool isLoggedIn = authSnapshot.hasData;

            if (!hasSeenOnboarding) {
              return const OnboardingPage();
            } else if (isLoggedIn) {
              return const HomePage(
                businessId: '',
              );
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    bool showHome = prefs.getBool('ShowHome') ?? false;

    if (!mounted) return;

    // Utilisation de Get.offAll de manière asynchrone
    Future.microtask(() => Get.offAll(() => const AuthHandler()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8C179E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Image.asset("images/LogoAnimeGoOn.gif", width: 300),
          ],
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Une erreur s\'est produite. Veuillez réessayer.'),
            ElevatedButton(
              onPressed: () => Get.offAll(() => const SplashScreen()),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
