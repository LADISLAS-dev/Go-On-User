import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdExample extends StatefulWidget {
  const InterstitialAdExample({super.key});

  @override
  State<InterstitialAdExample> createState() => _InterstitialAdExampleState();
}

class _InterstitialAdExampleState extends State<InterstitialAdExample> {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/4411468910', // ID de test pour iOS
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
          });

          // Définir les callbacks pour le contenu plein écran
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('Annonce fermée.');
              ad.dispose();
              _loadInterstitialAd(); // Charger une nouvelle annonce après fermeture
            },
            onAdFailedToShowFullScreenContent: (
              InterstitialAd ad,
              AdError error,
            ) {
              print('Échec de l\'affichage de l\'annonce : $error');
              ad.dispose();
              _loadInterstitialAd(); // Charger une nouvelle annonce après échec
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print(
            'Échec du chargement de l\'annonce interstitielle : ${error.message}',
          );
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdReady) {
      _interstitialAd?.show();
    } else {
      print('L\'annonce interstitielle n\'est pas encore prête.');
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exemple d\'Annonce Interstitielle')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showInterstitialAd,
          child: const Text('Afficher l\'Annonce Interstitielle'),
        ),
      ),
    );
  }
}
