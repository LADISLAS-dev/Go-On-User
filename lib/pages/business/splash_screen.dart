// import 'dart:async';

// import 'package:appointy/login/screen/login.dart';
// import 'package:appointy/pages/business/business_home_page.dart';
// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   // for navigtion and transaction
//   void initState() {
//     super.initState();
//     Timer(
//       const Duration(seconds: 6),
//       () {
//         Navigator.of(context).pushReplacement(
//           PageRouteBuilder(
//             pageBuilder: (context, animation, secondaryAnimation) =>
//                 const HomePage(),
//             transitionsBuilder:
//                 (context, animation, secondaryAnimation, child) {
//               return ScaleTransition(scale: animation, child: child);
//             },
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF8C179E),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(
//               height: 30,
//             ),
//             Image.asset("images/LogoAnimeGoOn.gif", width: 300),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'dart:async';
// // import 'package:flutter/material.dart';

// // class Splash extends StatefulWidget {
// //   const Splash({super.key});

// //   @override
// //   State<Splash> createState() => _SplashState();
// // }

// // class _SplashState extends State<Splash> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     startTime();
// //   }

// //   startTime() {
// //     var duration = const Duration(seconds: 6);
// //     return Timer(duration, route);
// //   }

// //   route() {
// //     Navigator.of(context).pushReplacementNamed('/LoginScreen');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //         color: const Color.fromARGB(255, 140, 23, 158),
// //         child: Center(
// //           child: Transform.scale(
// //             scale: 1,
// //             child: Image.asset("images/LogoAnimeGoOn.gif", width: 300),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
