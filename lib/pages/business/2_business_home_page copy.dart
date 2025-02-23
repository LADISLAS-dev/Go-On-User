// import 'package:appointy/pages/business/CategoryPage.dart';
// import 'package:appointy/pages/business/carousel_page1.dart';
// import 'package:appointy/pages/business/create_business_page.dart';
// import 'package:appointy/pages/screens/AppBar.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Liste des couleurs prédéfinies
//   final List<Color> containerColors = [
//     Colors.blueAccent,
//     Colors.green,
//     Colors.redAccent,
//     Colors.deepPurple,
//     Colors.orange,
//     Colors.teal,
//     Colors.pinkAccent,
//     Colors.cyan,
//   ];

//   // Map des catégories et leurs icônes associées
//   final Map<String, IconData> categoryIcons = {
//     'Restaurant': Icons.restaurant,
//     'Alimentation et Boissons': Icons.fastfood,
//     'Art et Divertissement': Icons.theater_comedy,
//     'Santé et Bien-être': Icons.local_hospital,
//     'Mode et Beauté': Icons.checkroom,
//     'Technologie et Informatique': Icons.computer,
//     'Commerce et Retail': Icons.store,
//     'Services professionnels': Icons.business_center,
//     'Immobilier et Construction': Icons.house,
//     'Éducation et Formation': Icons.school,
//     'Transport et Logistique': Icons.directions_car,
//     'Événementiel': Icons.event,
//     'Médias et Communication': Icons.movie,
//     'Agriculture et Agro-industrie': Icons.grain,
//     'Tourisme et Loisirs': Icons.location_on,
//     'Energie et Environnement': Icons.eco,
//     'Services juridiques': Icons.gavel,
//     'Services financiers': Icons.account_balance,
//   };

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text("Veuillez vous connecter")),
//       );
//     }

//     return Scaffold(
//       drawer: Drawer(
//         child: StreamBuilder<DocumentSnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return const Center(child: Text('Utilisateur non trouvé'));
//             }

//             final userData = snapshot.data!.data() as Map<String, dynamic>;
//             final userName = userData['name'] ?? 'Nom de l\'utilisateur';
//             final userEmail = userData['email'] ?? 'email@example.com';
//             final profileImageUrl =
//                 userData['profileImage']; // URL de l'image de profil

//             return ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 UserAccountsDrawerHeader(
//                   accountName: Text(userName),
//                   accountEmail: Text(userEmail),
//                   currentAccountPicture: CircleAvatar(
//                     backgroundImage: profileImageUrl != null &&
//                             profileImageUrl.isNotEmpty
//                         ? NetworkImage(profileImageUrl) // Si l'URL est valide
//                         : const AssetImage('assets/default-avatar.png')
//                             as ImageProvider, // Image par défaut
//                     backgroundColor: Colors.grey,
//                   ),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.home, color: Colors.purple),
//                   title: const Text('Accueil'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.settings, color: Colors.purple),
//                   title: const Text('Paramètres'),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//       appBar: AppBar(
//         title: const Row(
//           mainAxisAlignment: MainAxisAlignment.end, // Aligne le profil à droite
//           children: [
//             SizedBox(
//               width: 120,
//               child: ProfileScreen(),
//             ),
//           ],
//         ),
//         backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
//         iconTheme: const IconThemeData(
//             color: Colors.white), // Ajoutez ceci pour rendre l'icône blanche
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: SizedBox(
//                 height: 380,
//                 child: CarouselPage1(
//                   businessId: 'business_id',
//                   carouselImages: const [],
//                   onDeleteImage: (String imageUrl) async {
//                     // Ajoutez ici la logique pour supprimer une image
//                   },
//                   onAddImage: () async {
//                     // Ajoutez ici la logique pour ajouter une image
//                   },
//                 ),
//               ),
//             ),
//           ),
//           StreamBuilder<QuerySnapshot>(
//             stream:
//                 FirebaseFirestore.instance.collection('businesses').snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const SliverToBoxAdapter(
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return const SliverToBoxAdapter(
//                   child: Center(child: Text('Aucune catégorie trouvée.')),
//                 );
//               }

//               final Set<String> categories = {};
//               for (var doc in snapshot.data!.docs) {
//                 final List<String> businessCategories =
//                     List<String>.from(doc['categories'] ?? []);
//                 categories.addAll(businessCategories);
//               }

//               final categoryList = categories.toList();

//               return SliverPadding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 sliver: SliverGrid(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 6,
//                     mainAxisSpacing: 6,
//                     childAspectRatio: 3 / 2,
//                   ),
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final category = categoryList[index];
//                       final icon = categoryIcons[category] ?? Icons.category;
//                       final color =
//                           containerColors[index % containerColors.length];

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   CategoryPage(category: category),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: color,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(2, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(icon, size: 40, color: Colors.white),
//                               const SizedBox(height: 8),
//                               Text(
//                                 category,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                     childCount: categoryList.length,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const CreateBusinessPage(businessId: 'new'),
//             ),
//           );
//         },
//         backgroundColor: const Color.fromARGB(255, 156, 39, 176),
//         child: const Icon(Icons.add_business, color: Colors.white),
//       ),
//     );
//   }
// }
