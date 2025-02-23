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
// import 'package:another_carousel_pro/another_carousel_pro.dart';

// void main() {
//   runApp(const Home());
// }

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> with TickerProviderStateMixin {
//   Offset _gridOffset = Offset.zero; // Position globale de la grille
//   final List<bool> _isDraggableList = List.generate(_apps.length, (_) => false);
//   Size screenSize = Size.zero;

//   late AnimationController _animationController;
//   late Animation<Offset> _backgroundAnimation;

//   @override
//   void initState() {
//     super.initState();
//     // Animation pour le fond
//     _animationController = AnimationController(
//       duration: const Duration(seconds: 10),
//       vsync: this,
//     )..repeat(reverse: true); // Boucle l'animation

//     _backgroundAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(1.0, 0.0), // Déplace l'image horizontalement
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.linear,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _resetPositions() {
//     setState(() {
//       _gridOffset = Offset.zero; // Réinitialiser le déplacement global
//     });
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     setState(() {
//       _gridOffset += details.delta; // Déplacement global de la grille
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     screenSize = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset(
//           'images/Bookme.png', // Remplacez par le chemin de votre logo
//           height: 40, // Ajustez la taille du logo
//           fit: BoxFit.contain,
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               height: 150,
//               width: double.infinity,
//               child: ClipRRect(
//                 borderRadius:
//                     BorderRadius.circular(16), // Définit le rayon des coins
//                 child: AnotherCarousel(
//                   images: const [
//                     AssetImage('images/pubA.jpg'),
//                     AssetImage('images/pubB.jpg'),
//                     AssetImage('images/pub+.png'),
//                     NetworkImage(
//                         'https://cdn6.aptoide.com/imgs/f/f/9/ff988f213b537489489653d7178a2525_fgraphic.jpg')
//                   ],
//                   dotSize: 3,
//                   indicatorBgPadding: 0.0,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: GestureDetector(
//               onPanUpdate: _onPanUpdate,
//               onDoubleTap: () {
//                 setState(() {
//                   for (int i = 0; i < _isDraggableList.length; i++) {
//                     _isDraggableList[i] = false;
//                   }
//                 });
//               },
//               child: Stack(
//                 children: [
//                   // Image d'arrière-plan animée
//                   AnimatedBuilder(
//                     animation: _animationController,
//                     builder: (context, child) {
//                       return Opacity(
//                         opacity: 0.1,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: const AssetImage('images/map2.jpg'),
//                               fit: BoxFit.cover,
//                               alignment: Alignment(
//                                 _backgroundAnimation.value.dx,
//                                 _backgroundAnimation.value.dy,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   ...List.generate(_apps.length, (index) {
//                     final app = _apps[index];
//                     return MovableIcon(
//                       app: app,
//                       index: index,
//                       gridOffset: _gridOffset,
//                       screenSize: screenSize,
//                       isDraggable: _isDraggableList[index],
//                       onDoubleTap: () {
//                         setState(() {
//                           _isDraggableList[index] = !_isDraggableList[index];
//                         });
//                       },
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => app["page"]),
//                         );
//                       },
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _resetPositions,
//         tooltip: 'Reset Positions',
//         backgroundColor: Colors.blue, // Couleur bleue pour le FAB
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }

// class MovableIcon extends StatefulWidget {
//   final Map<String, dynamic> app;
//   final int index;
//   final Offset gridOffset;
//   final bool isDraggable;
//   final VoidCallback onDoubleTap;
//   final VoidCallback onTap;
//   final Size screenSize;

//   const MovableIcon({
//     required this.app,
//     required this.index,
//     required this.gridOffset,
//     required this.isDraggable,
//     required this.onDoubleTap,
//     required this.onTap,
//     required this.screenSize,
//     super.key,
//   });

//   @override
//   _MovableIconState createState() => _MovableIconState();
// }

// class _MovableIconState extends State<MovableIcon> {
//   late Offset position;

//   @override
//   void initState() {
//     super.initState();

//     position = Offset(
//       widget.screenSize.width / 1.3 - (widget.index % -4) * 100,
//       widget.screenSize.height / 18 - (widget.index ~/ -4) * 120,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: position.dy + widget.gridOffset.dy,
//       left: position.dx + widget.gridOffset.dx,
//       child: GestureDetector(
//         onPanUpdate: widget.isDraggable
//             ? (details) {
//                 setState(() {
//                   position += details.delta;
//                 });
//               }
//             : null,
//         onDoubleTap: widget.onDoubleTap,
//         onTap: widget.onTap,
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color:
//                       widget.isDraggable ? Colors.blue : Colors.grey.shade400,
//                   width: 3,
//                 ),
//               ),
//               child: CircleAvatar(
//                 radius: 30,
//                 backgroundColor: Colors.grey.shade200,
//                 child: ClipOval(
//                   child: Image.asset(
//                     widget.app["image"],
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return const Icon(
//                         Icons.error,
//                         color: Colors.red,
//                         size: 40,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.app["name"],
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// final List<Map<String, dynamic>> _apps = [
//   {
//     "image": "images/legend.jpeg",
//     "name": "Legend M",
//     "page": const PhonePage(),
//   },
//   {
//     "image": "images/mecano.jpg",
//     "name": "Messages",
//     "page": const MessagesPage(),
//   },
//   {"image": "images/camera1.jpg", "name": "Camera", "page": const CameraPage()},
//   {
//     "image": "images/tresse.jpeg",
//     "name": "Settings",
//     "page": const SettingsPage(),
//   },
//   {"image": "images/mecano.jpg", "name": "Maps", "page": const MapsPage()},
//   {
//     "image": "images/maths.jpeg",
//     "name": "Mathematic SP",
//     "page": const MusicPage(),
//   },
//   {"image": "images/consulting.jpg", "name": "Mail", "page": const MailPage()},
//   {
//     "image": "images/tresse.jpeg",
//     "name": "Calendar",
//     "page": const CalendarPage(),
//   },
//   {"image": "images/barber.jpeg", "name": "Alarm", "page": const AlarmPage()},
//   {
//     "image": "images/Food.jpg",
//     "name": "Contacts",
//     "page": const ContactsPage(),
//   },
// ];

// // //-------------------

// // import 'package:flutter/material.dart';
// // import 'dart:io';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'dart:convert';

// // void main() {
// //   runApp(const MaterialApp(home: Home()));
// // }

// // class Home extends StatefulWidget {
// //   const Home({super.key});

// //   @override
// //   State<Home> createState() => _HomeState();
// // }

// // class _HomeState extends State<Home> {
// //   List<Map<String, dynamic>> _apps = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadApps();
// //   }

// //   Future<void> _loadApps() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String? storedApps = prefs.getString('apps');
// //     if (storedApps != null) {
// //       List<dynamic> decodedApps = json.decode(storedApps);
// //       setState(() {
// //         _apps = List<Map<String, dynamic>>.from(decodedApps);
// //       });
// //     }
// //   }

// //   Future<void> _saveApps() async {
// //     SharedPreferences prefs = await SharedPreferences.getInstance();
// //     String encodedApps = json.encode(_apps);
// //     await prefs.setString('apps', encodedApps);
// //   }

// //   void _addApp(Map<String, dynamic> newApp) {
// //     setState(() {
// //       _apps.add(newApp);
// //     });
// //     _saveApps();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Gestion des entreprises'),
// //         centerTitle: true,
// //       ),
// //       body: GridView.builder(
// //         padding: const EdgeInsets.all(8),
// //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: 4,
// //           childAspectRatio: 3 / 4,
// //           crossAxisSpacing: 10,
// //           mainAxisSpacing: 10,
// //         ),
// //         itemCount: _apps.length,
// //         itemBuilder: (context, index) {
// //           final app = _apps[index];
// //           return GestureDetector(
// //             onTap: () {
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                   builder: (context) => BusinessPage(
// //                     businessName: app['name'],
// //                     imageUrl: app['image'],
// //                     categories: [
// //                       'Catégorie 1',
// //                       'Catégorie 2'
// //                     ], // Exemple de catégories
// //                     carouselImages: [
// //                       'https://example.com/image1.jpg'
// //                     ], // Exemple d'images
// //                     products: [
// //                       {
// //                         'name': 'Produit 1',
// //                         'description': 'Description du produit 1'
// //                       },
// //                       {
// //                         'name': 'Produit 2',
// //                         'description': 'Description du produit 2'
// //                       },
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //             child: Column(
// //               children: [
// //                 CircleAvatar(
// //                   radius: 40,
// //                   backgroundImage: app['image'].startsWith('http')
// //                       ? NetworkImage(app['image']) as ImageProvider
// //                       : FileImage(File(app['image'].startsWith('file://')
// //                           ? app['image'].substring(7)
// //                           : app['image'])),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   app['name'],
// //                   style: const TextStyle(fontSize: 16),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           showDialog(
// //             context: context,
// //             builder: (BuildContext context) {
// //               return AddAppDialog(onAddApp: _addApp);
// //             },
// //           );
// //         },
// //         child: const Icon(Icons.add),
// //       ),
// //     );
// //   }
// // }

// // class AddAppDialog extends StatefulWidget {
// //   final Function(Map<String, dynamic>) onAddApp;

// //   const AddAppDialog({super.key, required this.onAddApp});

// //   @override
// //   State<AddAppDialog> createState() => _AddAppDialogState();
// // }

// // class _AddAppDialogState extends State<AddAppDialog> {
// //   final TextEditingController _nameController = TextEditingController();
// //   String _imageUrl = '';
// //   File? _imageFile;
// //   final ImagePicker _picker = ImagePicker();

// //   void _chooseImage() async {
// //     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         _imageFile = File(pickedFile.path);
// //         _imageUrl = '';
// //       });
// //     }
// //   }

// //   void _chooseUrl() {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         final TextEditingController urlController = TextEditingController();
// //         return AlertDialog(
// //           title: const Text('Saisir une URL d\'image'),
// //           content: TextField(
// //             controller: urlController,
// //             decoration: const InputDecoration(labelText: 'URL d\'image'),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _imageUrl = urlController.text;
// //                   _imageFile = null;
// //                 });
// //                 Navigator.pop(context);
// //               },
// //               child: const Text('OK'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   void _addApp() {
// //     if (_nameController.text.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //             content: Text('Veuillez saisir un nom pour l\'entreprise')),
// //       );
// //       return;
// //     }

// //     if (_imageFile == null && _imageUrl.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //             content: Text('Veuillez choisir une image pour l\'entreprise')),
// //       );
// //       return;
// //     }

// //     widget.onAddApp({
// //       'image': _imageFile != null ? _imageFile : File(_imageUrl),
// //       'name': _nameController.text,
// //     });
// //     Navigator.pop(context);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return AlertDialog(
// //       title: const Text('Ajouter une entreprise'),
// //       content: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           TextField(
// //             controller: _nameController,
// //             decoration:
// //                 const InputDecoration(labelText: 'Nom de l\'entreprise'),
// //           ),
// //           const SizedBox(height: 16),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: Text(
// //                   _imageFile == null && _imageUrl.isEmpty
// //                       ? 'Choisissez une image'
// //                       : (_imageFile != null ? _imageFile!.path : _imageUrl),
// //                 ),
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.image),
// //                 onPressed: _chooseImage,
// //               ),
// //               IconButton(
// //                 icon: const Icon(Icons.link),
// //                 onPressed: _chooseUrl,
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //       actions: [
// //         TextButton(
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //           child: const Text('Annuler'),
// //         ),
// //         TextButton(
// //           onPressed: _addApp,
// //           child: const Text('Ajouter'),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class BusinessPage extends StatelessWidget {
// //   final String businessName;
// //   final String imageUrl;
// //   final List<String> categories;
// //   final List<String> carouselImages;
// //   final List<Map<String, String>> products;

// //   const BusinessPage({
// //     super.key,
// //     required this.businessName,
// //     required this.imageUrl,
// //     required this.categories,
// //     required this.carouselImages,
// //     required this.products,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(businessName)),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Image de l'entreprise
// //             imageUrl.isNotEmpty
// //                 ? Image.network(imageUrl, height: 200, fit: BoxFit.cover)
// //                 : const SizedBox(height: 200, child: Placeholder()),

// //             const SizedBox(height: 16),

// //             // Catégories
// //             const Text(
// //               'Catégories',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             Wrap(
// //               spacing: 8,
// //               runSpacing: 8,
// //               children: categories
// //                   .map((category) => Chip(label: Text(category)))
// //                   .toList(),
// //             ),

// //             const SizedBox(height: 16),

// //             // Carousel d'images
// //             const Text(
// //               'Images',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             carouselImages.isEmpty
// //                 ? const Text('Aucune image')
// //                 : SizedBox(
// //                     height: 150,
// //                     child: ListView.builder(
// //                       scrollDirection: Axis.horizontal,
// //                       itemCount: carouselImages.length,
// //                       itemBuilder: (context, index) {
// //                         return Padding(
// //                           padding: const EdgeInsets.only(right: 8),
// //                           child: Image.network(carouselImages[index]),
// //                         );
// //                       },
// //                     ),
// //                   ),

// //             const SizedBox(height: 16),

// //             // Produits
// //             const Text(
// //               'Produits',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             products.isEmpty
// //                 ? const Text('Aucun produit')
// //                 : Column(
// //                     children: products.map((product) {
// //                       return ListTile(
// //                         title: Text(product['name'] ?? 'Nom non disponible'),
// //                         subtitle: Text(product['description'] ??
// //                             'Description non disponible'),
// //                       );
// //                     }).toList(),
// //                   ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
