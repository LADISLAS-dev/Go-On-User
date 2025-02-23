import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdExample extends StatefulWidget {
  const NativeAdExample({super.key});

  @override
  State<NativeAdExample> createState() => _NativeAdExampleState();
}

class _NativeAdExampleState extends State<NativeAdExample> {
  NativeAd? _nativeAd;
  bool _isNativeAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      // adUnitId: 'ca-app-pub-3940256099942544/2247696110', // ID de test pour Android
      adUnitId: 'ca-app-pub-3940256099942544/3986624511', // ID de test pour iOS
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isNativeAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a native ad: ${err.message}');
          _isNativeAdReady = false;
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium, // Choisissez un type de template
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Ad Example')),
      body: Center(
        child:
            _isNativeAdReady
                ? AdWidget(ad: _nativeAd!)
                : const CircularProgressIndicator(),
      ),
    );
  }
}
