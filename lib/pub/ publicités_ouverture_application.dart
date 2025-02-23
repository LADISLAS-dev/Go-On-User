import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdExample extends StatefulWidget {
  const AppOpenAdExample({super.key});

  @override
  State<AppOpenAdExample> createState() => _AppOpenAdExampleState();
}

class _AppOpenAdExampleState extends State<AppOpenAdExample> {
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadAppOpenAd();
  }

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/3419835294', // ID de test pour Android
      // adUnitId: 'ca-app-pub-3940256099942544/5662855259', // ID de test pour iOS
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _appOpenAd = ad;
            _isAppOpenAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an app open ad: ${err.message}');
          _isAppOpenAdReady = false;
        },
      ),
    );
  }

  void _showAppOpenAd() {
    if (_isAppOpenAdReady) {
      _appOpenAd?.show();
    } else {
      print('App open ad is not ready yet.');
    }
  }

  @override
  void dispose() {
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Open Ad Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showAppOpenAd,
          child: const Text('Show App Open Ad'),
        ),
      ),
    );
  }
}
