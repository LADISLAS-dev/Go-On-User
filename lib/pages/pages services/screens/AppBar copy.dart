// import 'package:flutter/material.dart';

// class MyAppBar extends StatefulWidget {
//   const MyAppBar({super.key});

//   @override
//   State<MyAppBar> createState() => _MyAppBartState();
// }

// class _MyAppBartState extends State<MyAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white, // Fond transparent
//       elevation: 0, // Pas d'ombre
//       title: const Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Spacer(),
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     "Hello !",
//                     style: TextStyle(color: Colors.black87, fontSize: 14),
//                   ),
//                   Text(
//                     "John Doe",
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 10),
//               CircleAvatar(
//                 backgroundImage: AssetImage('images/as.jpeg'),
//                 radius: 20,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

///////_____________________________
///
///
///
///Ok Ok Ok Ok
///
// ///
// import 'package:appointy/login/Services/authentification.dart';
// import 'package:appointy/login/screen/login.dart';
// import 'package:appointy/pages/sous_pages/admin/profileSettting.dart';
// import 'package:appointy/pages/sous_pages/booking1/AppointmentListPage.dart';
// import 'package:flutter/material.dart';

// class MyAppBar extends StatefulWidget {
//   const MyAppBar({super.key});

//   @override
//   State<MyAppBar> createState() => _MyAppBartState();
// }

// class _MyAppBartState extends State<MyAppBar> {
//   void _showProfileDrawer() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _ProfileDrawer(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 3, // Pas d'ombre
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Spacer(),
//           Row(
//             children: [
//               const Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     "Hello !",
//                     style: TextStyle(color: Colors.black87, fontSize: 14),
//                   ),
//                   Text(
//                     "John Doe",
//                     style: TextStyle(
//                       color: Colors.black87,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 10),
//               GestureDetector(
//                 onTap: _showProfileDrawer,
//                 child: const CircleAvatar(
//                   backgroundImage: AssetImage('images/as.jpeg'),
//                   radius: 20,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ProfileDrawer extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             'Profile Settings',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Edit Profile'),
//             onTap: () {
//               // Action pour modifier le profil
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Settings'),
//             onTap: () {
//               // Navigator.push(
//               // context,
//               // MaterialPageRoute(builder: (context) => const ProfileSetting()),
//               // ); // Action pour aller dans les paramètres
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.settings),
//             title: const Text('Appointment List'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const AppointmentListPage()),
//               ); // Action pour aller dans les paramètres
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.admin_panel_settings),
//             title: const Text('Admin'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfileSetting()),
//               ); // Action pour aller dans les paramètres
//             },
//           ),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
//             onTap: () async {
//               await AuthService().signOut(); // Déconnexion
//               if (context.mounted) {
//                 // Vérifier si le contexte est toujours valide
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) => const LoginScreen(),
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
