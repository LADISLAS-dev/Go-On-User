import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AnchoredAdaptiveBannerAdExample extends StatefulWidget {
  const AnchoredAdaptiveBannerAdExample({super.key});

  @override
  State<AnchoredAdaptiveBannerAdExample> createState() =>
      _AnchoredAdaptiveBannerAdExampleState();
}

class _AnchoredAdaptiveBannerAdExampleState
    extends State<AnchoredAdaptiveBannerAdExample> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    // Obtenez la taille adaptative de la bannière pour l'orientation actuelle
    final AdSize adSize = (await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.toInt(),
    )) as AdSize;

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // ID de test pour Android
      // adUnitId: 'ca-app-pub-3940256099942544/2934735716', // ID de test pour iOS
      size: adSize, // Utilisez la taille adaptative
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anchored Adaptive Banner Ad Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isBannerAdReady)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}