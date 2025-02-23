import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedInterstitialAdExample extends StatefulWidget {
  const RewardedInterstitialAdExample({super.key});

  @override
  State<RewardedInterstitialAdExample> createState() =>
      _RewardedInterstitialAdExampleState();
}

class _RewardedInterstitialAdExampleState
    extends State<RewardedInterstitialAdExample> {
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isRewardedInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedInterstitialAd();
  }

  void _loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      // adUnitId: 'ca-app-pub-3940256099942544/5354046379', // ID de test pour Android
      adUnitId: 'ca-app-pub-1917025047521980/2032239765', // ID de test pour iOS
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedInterstitialAd = ad;
            _isRewardedInterstitialAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded interstitial ad: ${err.message}');
          _isRewardedInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showRewardedInterstitialAd() {
    if (_isRewardedInterstitialAdReady) {
      _rewardedInterstitialAd?.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
        },
      );
    } else {
      print('Rewarded interstitial ad is not ready yet.');
    }
  }

  @override
  void dispose() {
    _rewardedInterstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewarded Interstitial Ad Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showRewardedInterstitialAd,
          child: const Text('Show Rewarded Interstitial Ad'),
        ),
      ),
    );
  }
}
