import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdExample extends StatefulWidget {
  const RewardedAdExample({super.key});

  @override
  State<RewardedAdExample> createState() => _RewardedAdExampleState();
}

class _RewardedAdExampleState extends State<RewardedAdExample> {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      // adUnitId: 'ca-app-pub-3940256099942544/5224354917', // ID de test pour Android
      adUnitId: 'ca-app-pub-3940256099942544/1712485313', // ID de test pour iOS
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady) {
      _rewardedAd?.show(onUserEarnedReward: (ad, reward) {
        print('User earned reward: ${reward.amount} ${reward.type}');
      });
    } else {
      print('Rewarded ad is not ready yet.');
    }
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rewarded Ad Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _showRewardedAd,
          child: const Text('Show Rewarded Ad'),
        ),
      ),
    );
  }
}