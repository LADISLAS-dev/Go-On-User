import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:appointy/pages/business/business_page.dart';
import 'package:appointy/pages/business/reorganisation/BusinessCard.dart';
import 'package:appointy/pages/business/reorganisation/BusinessFetcher.dart';
import 'package:get/get.dart'; // Importez GetX pour la traduction

class CategoryPage2 extends StatefulWidget {
  final String category;

  const CategoryPage2({super.key, required this.category});

  @override
  _CategoryPage2State createState() => _CategoryPage2State();
}

class _CategoryPage2State extends State<CategoryPage2> {
  String searchQuery = '';
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  // Variables pour l'annonce native
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;
  bool _isNativeAdVisible = true;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadNativeAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1917025047521980/7433311079', // ID de test
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd!.setImmersiveMode(true);
          _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded) {
      _interstitialAd!.show();
    }
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-1917025047521980/8409945857', // ID de test
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _isNativeAdLoaded = false;
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        cornerRadius: 10.0,
      ),
    )..load();
  }

  void _hideNativeAd() {
    setState(() {
      _isNativeAdVisible = false;
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.tr, // Utilisez .tr pour la traduction
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 3,
        backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 240, 255),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BusinessFetcher(
                category: widget.category,
                searchQuery: searchQuery,
                itemBuilder: (context, business) {
                  final data = business.data() as Map<String, dynamic>;
                  final businessName = data['name'] ?? '';
                  final imageUrl = data['imageUrl'] ?? '';

                  return BusinessCard(
                    businessId: business.id,
                    businessName:
                        businessName, // Utilisez .tr pour la traduction
                    imageUrl: imageUrl,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessPage(
                            businessId: business.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Afficher l'annonce native en bas de la page avec un bouton de fermeture
            if (_isNativeAdLoaded && _isNativeAdVisible && _nativeAd != null)
              _buildNativeAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search for a business...'
              .tr
              .tr, // Utilisez .tr pour la traduction
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 128, 0, 178)),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeAd() {
    return Container(
      height: 450, // Hauteur de l'annonce native
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Annonce native
          AdWidget(ad: _nativeAd!),
          // Bouton de fermeture
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: _hideNativeAd,
            ),
          ),
        ],
      ),
    );
  }
}
