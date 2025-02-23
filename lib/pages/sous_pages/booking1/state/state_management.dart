import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userLogger = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userTokene = StateProvider((ref) => "");

final forceReaload = StateProvider((ref) => false);

//booking

final currentStep = StateProvider((ref) => 1);
final selectdCity = StateProvider((ref) => '');
final selectedSalon = StateProvider((ref) => '');
