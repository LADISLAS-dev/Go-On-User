// import 'package:appointy/pages/business/business_page.dart';
// import 'package:appointy/pages/business/create_business_page.dart';
// import 'package:appointy/pages/business/models/business.dart';
// import 'package:appointy/pages/sous_pages/AlarmPage.dart';
// import 'package:appointy/pages/sous_pages/CalendarPage.dart';
// import 'package:appointy/pages/sous_pages/CameraPage.dart';
// import 'package:appointy/pages/sous_pages/ContactsPage.dart';
// import 'package:appointy/pages/sous_pages/MailPage.dart';
// import 'package:appointy/pages/sous_pages/MapsPage.dart';
// import 'package:appointy/pages/sous_pages/MusicPage.dart';
// import 'package:appointy/pages/sous_pages/SettingsPage.dart';
// import 'package:appointy/pages/sous_pages/messagespage.dart';
// import 'package:appointy/pages/sous_pages/phonepage.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// void main() {
//   runApp(const Home());
// }

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
//   final List<Map<String, dynamic>> _defaultApps = [
//     {
//       "icon": Icons.business,
//       "name": "Entreprises",
//       "page": const PhonePage(),
//       "color": Colors.blue,
//     },
//     {
//       "icon": Icons.phone,
//       "name": "Legend M",
//       "page": const PhonePage(),
//       "color": Colors.green,
//     },
//     {
//       "icon": Icons.message,
//       "name": "Messages",
//       "page": const MessagesPage(),
//       "color": Colors.orange,
//     },
//     {
//       "icon": Icons.camera_alt,
//       "name": "Camera",
//       "page": const CameraPage(),
//       "color": Colors.purple,
//     },
//     {
//       "icon": Icons.settings,
//       "name": "Settings",
//       "page": const SettingsPage(),
//       "color": Colors.grey,
//     },
//     {
//       "icon": Icons.map,
//       "name": "Maps",
//       "page": const MapsPage(),
//       "color": Colors.red,
//     },
//     {
//       "icon": Icons.music_note,
//       "name": "Mathematic SP",
//       "page": const MusicPage(),
//       "color": Colors.teal,
//     },
//     {
//       "icon": Icons.mail,
//       "name": "Mail",
//       "page": const MailPage(),
//       "color": Colors.indigo,
//     },
//     {
//       "icon": Icons.calendar_today,
//       "name": "Calendar",
//       "page": const CalendarPage(),
//       "color": Colors.brown,
//     },
//     {
//       "icon": Icons.access_alarm,
//       "name": "Alarm",
//       "page": const AlarmPage(),
//       "color": Colors.deepOrange,
//     },
//     {
//       "icon": Icons.contacts,
//       "name": "Contacts",
//       "page": const ContactsPage(),
//       "color": Colors.cyan,
//     },
//   ];

//   List<Map<String, dynamic>> _businessApps = [];
//   bool _isLoading = true;
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 20),
//       vsync: this,
//     )..repeat();
//     _loadBusinesses();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBusinesses() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('businesses').get();
//       final businesses =
//           snapshot.docs.map((doc) => Business.fromFirestore(doc)).toList();

//       setState(() {
//         _businessApps = businesses
//             .map((business) => {
//                   "image": business.imageUrl,
//                   "name": business.name,
//                   "page": BusinessPage(businessId: business.id),
//                   "isNetwork": true, // Pour indiquer que c'est une image réseau
//                   "businessId": business.id,
//                   "description": business.description,
//                   "address": business.address,
//                   "phone": business.phone,
//                   "categories": business.categories,
//                   "ownerId": business.ownerId,
//                   "createdAt": business.createdAt,
//                 })
//             .toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Erreur lors du chargement des entreprises: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allApps = [..._businessApps, ..._defaultApps];

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
//         title: Image.asset(
//           'images/Bookme.png',
//           height: 40,
//           fit: BoxFit.contain,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add_business),
//             color: Colors.white,
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       const CreateBusinessPage(businessId: 'new'),
//                 ),
//               );
//               if (result != null) {
//                 _loadBusinesses(); // Recharger les entreprises après création
//               }
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Positioned.fill(
//           //   child: AnimatedBuilder(
//           //     animation: _controller,
//           //     builder: (context, child) {
//           //       return Transform.rotate(
//           //         angle: _controller.value * 2 * 3.14159,
//           //         child: Opacity(
//           //           opacity: 0.2,
//           //           child: Image.asset(
//           //             'images/planet.webp',
//           //             fit: BoxFit.cover,
//           //           ),
//           //         ),
//           //       );
//           //     },
//           //   ),
//           // ),
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : GridView.builder(
//                   padding: const EdgeInsets.all(16),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     childAspectRatio: 1,
//                     crossAxisSpacing: 9,
//                     mainAxisSpacing: 9,
//                   ),
//                   itemCount: allApps.length,
//                   itemBuilder: (context, index) {
//                     final app = allApps[index];
//                     final bool isNetwork = app['isNetwork'] ?? false;

//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 BusinessPage(businessId: app['businessId']),
//                           ),
//                         );
//                       },
//                       onLongPress: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text(
//                                 app['name'],
//                                 style: const TextStyle(
//                                   fontSize: 23,
//                                   // fontFamily: ,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple,
//                                 ),
//                               ),
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   ListTile(
//                                     leading: const Icon(Icons.edit,
//                                         color: Colors.deepPurple),
//                                     title: const Text(
//                                       'Modifier',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         // fontFamily: ,
//                                         color: Colors.black87,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               CreateBusinessPage(
//                                             businessId: app['businessId'],
//                                           ),
//                                         ),
//                                       ).then((_) => _loadBusinesses());
//                                     },
//                                   ),
//                                   ListTile(
//                                     leading: const Icon(Icons.delete,
//                                         color: Colors.red),
//                                     title: const Text(
//                                       'Supprimer',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         // fontFamily: ,
//                                         color: Colors.red,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                     onTap: () async {
//                                       final confirm = await showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           return AlertDialog(
//                                             title: const Text(
//                                                 'Confirmer la suppression'),
//                                             content: const Text(
//                                                 'Êtes-vous sûr de vouloir supprimer cette entreprise ?'),
//                                             actions: [
//                                               TextButton(
//                                                 onPressed: () => Navigator.pop(
//                                                     context, false),
//                                                 child: const Text('Annuler'),
//                                               ),
//                                               TextButton(
//                                                 onPressed: () => Navigator.pop(
//                                                     context, true),
//                                                 child: const Text(
//                                                   'Supprimer',
//                                                   style: TextStyle(
//                                                       color: Colors.red),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );

//                                       if (confirm == true) {
//                                         try {
//                                           await FirebaseFirestore.instance
//                                               .collection('businesses')
//                                               .doc(app['businessId'])
//                                               .delete();
//                                           if (!context.mounted) return;
//                                           Navigator.pop(context);
//                                           _loadBusinesses();
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             const SnackBar(
//                                               content: Text(
//                                                   'Entreprise supprimée avec succès'),
//                                             ),
//                                           );
//                                         } catch (e) {
//                                           if (!context.mounted) return;
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                   'Erreur lors de la suppression: $e'),
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: const Color.fromRGBO(156, 39, 176, 1),
//                                 width: 2,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   spreadRadius: 1,
//                                   blurRadius: 3,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: ClipOval(
//                               child: isNetwork
//                                   ? Image.network(
//                                       app['image'],
//                                       width: 70,
//                                       height: 70,
//                                       fit: BoxFit.cover,
//                                       loadingBuilder:
//                                           (context, child, loadingProgress) {
//                                         if (loadingProgress == null) {
//                                           return child;
//                                         }
//                                         return Center(
//                                           child: CircularProgressIndicator(
//                                             value: loadingProgress
//                                                         .expectedTotalBytes !=
//                                                     null
//                                                 ? loadingProgress
//                                                         .cumulativeBytesLoaded /
//                                                     loadingProgress
//                                                         .expectedTotalBytes!
//                                                 : null,
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                         return Container(
//                                           color: Colors.grey[300],
//                                           child: const Icon(Icons.business,
//                                               size: 35, color: Colors.grey),
//                                         );
//                                       },
//                                     )
//                                   : Container(
//                                       color: app['color'],
//                                       child: Icon(app['icon'],
//                                           size: 35, color: Colors.white),
//                                     ),
//                             ),
//                           ),
//                           const SizedBox(height: 3),
//                           Text(
//                             app['name'],
//                             style: const TextStyle(
//                               fontSize: 12,
//                               // fontFamily: ,
//                               fontWeight: FontWeight.w300,
//                               color: Colors.black87,
//                             ),
//                             textAlign: TextAlign.center,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }

// //56677888888888
// ////)))))))0000
// ///