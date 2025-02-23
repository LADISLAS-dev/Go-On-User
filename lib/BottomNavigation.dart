// import 'package:appointy/pages/home1.dart';
// import 'package:appointy/pages/sous_pages/AlarmPage.dart';
// import 'package:appointy/pages/sous_pages/ContactsPage.dart';
// import 'package:appointy/pages/sous_pages/phonepage.dart';
// import 'package:flutter/material.dart';

// class BottomN extends StatefulWidget {
//   const BottomN({super.key});

//   @override
//   State<BottomN> createState() => _BottomNState();
// }

// class _BottomNState extends State<BottomN> {
//   late List<Widget> pages;
//   int currentTabIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     // Initialiser les pages
//     pages = [
//       const Home(), // Assurez-vous que cette page existe
//        const ContactsPage(), // Assurez-vous que cette page existe
//       const AlarmPage(), // Assurez-vous que cette page existe
//       const PhonePage(), // Assurez-vous que cette page existe
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: CurvedNavigationBar(
//         buttonBackgroundColor: Colors.black,
//         backgroundColor: Colors.transparent,
//         height: 65,
//         color: const Color.fromARGB(255, 84, 87, 93),
//         animationDuration: const Duration(
//             milliseconds: 500), // microseconds remplacé par milliseconds
//         onTap: (int index) {
//           setState(() {
//             currentTabIndex = index; // Mettre à jour l'onglet actif
//           });
//         },
//         items: const [
//           Icon(
//             Icons.home_outlined,
//             color: Colors.white,
//           ),
//           Icon(
//             Icons.settings_outlined,
//             color: Colors.white,
//           ),
//           Icon(
//             Icons.message_outlined,
//             color: Colors.white,
//           ),
//           Icon(
//             Icons.history_outlined,
//             color: Colors.white,
//           ),
//         ],
//       ),
//       body: pages[
//           currentTabIndex], // Afficher la page correspondant à l'onglet sélectionné
//     );
//   }
// }

// CurvedNavigationBar(
//     {required Color buttonBackgroundColor,
//     required Color backgroundColor,
//     required int height,
//     required Color color,
//     required Duration animationDuration,
//     required Null Function(int index) onTap,
//     required List<Icon> items}) {}
