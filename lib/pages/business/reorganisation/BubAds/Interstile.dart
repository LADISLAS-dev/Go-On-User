import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

///---------------------
class Interstile extends StatefulWidget {
  const Interstile({super.key});

  @override
  _InterstileState createState() => _InterstileState();
}

class _InterstileState extends State<Interstile> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/4411468910', // ID de test
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Flutter Ads Demo'),
      // ),
      body: Column(
        children: [
          const Expanded(
            child: Center(
              child: Text('Banner Ad will show here KKKK'),
              // child: ElevatedButton(onPressed: (){}, child: cosnt Text ("show ads")),
            ),
          ),
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
