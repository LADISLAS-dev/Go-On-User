// import 'dart:io';

// import 'package:appointy/pages/business/business_page.dart';
// import 'package:appointy/pages/business/carousel_page1.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';

// class CategoryPage extends StatefulWidget {
//   final String category;

//   const CategoryPage({super.key, required this.category});

//   @override
//   _CategoryPageState createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Category Page'),
//         backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: CustomScrollView(
//               slivers: [
//                 SliverGrid(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       return FutureBuilder<QuerySnapshot>(
//                         future: FirebaseFirestore.instance
//                             .collection('businesses')
//                             .where('categories', arrayContains: widget.category)
//                             .get(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           }
//                           if (!snapshot.hasData ||
//                               snapshot.data!.docs.isEmpty) {
//                             return Center(
//                                 child: Text(
//                                     'Aucune entreprise trouvée pour ${widget.category}.'));
//                           }

//                           final businesses = snapshot.data!.docs;

//                           if (index >= businesses.length) {
//                             return Container();
//                           }

//                           final business = businesses[index];
//                           final data = business.data() as Map<String, dynamic>?;
//                           final imageUrl =
//                               data != null && data.containsKey('imageUrl')
//                                   ? data['imageUrl']
//                                   : null;
//                           final businessName =
//                               data != null && data.containsKey('name')
//                                   ? data['name']
//                                   : 'Entreprise sans nom';

//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => BusinessPage(
//                                     businessId: business.id,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Stack(
//                                   children: [
//                                     Container(
                                      
//                                       width: 70,
//                                       height: 70,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: const Color.fromRGBO(
//                                               156, 39, 176, 1),
//                                           width: 2,
//                                         ),
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color:
//                                                 Colors.black.withOpacity(0.1),
//                                             spreadRadius: 1,
//                                             blurRadius: 3,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ],
//                                       ),
//                                       child: ClipOval(
//                                         child: imageUrl != null &&
//                                                 imageUrl.isNotEmpty
//                                             ? Image.network(
//                                                 imageUrl,
//                                                 width: 70,
//                                                 height: 70,
//                                                 fit: BoxFit.cover,
//                                               )
//                                             : Container(
//                                                 color: Colors.grey[300],
//                                                 child: const Icon(
//                                                     Icons.business,
//                                                     size: 35,
//                                                     color: Colors.white),
//                                               ),
//                                       ),
//                                     ),
//                                     // Positioned(
//                                     //   top: 0,
//                                     //   right: 0,
//                                     //   child: PopupMenuButton<String>(
//                                     //     onSelected: (String value) async {
//                                     //       if (value == 'edit') {
//                                     //         _editBusiness(business.id, data);
//                                     //       } else if (value == 'delete') {
//                                     //         await _deleteBusiness(business.id);
//                                     //       }
//                                     //     },
//                                     //     itemBuilder: (BuildContext context) => [
//                                     //       const PopupMenuItem<String>(
//                                     //         value: 'edit',
//                                     //         child: Text('Modifier'),
//                                     //       ),
//                                     //       const PopupMenuItem<String>(
//                                     //         value: 'delete',
//                                     //         child: Text('Supprimer'),
//                                     //       ),
//                                     //     ],
//                                     //     icon: const Icon(Icons.more_vert,
//                                     //         size: 16),
//                                     //   ),
//                                     // ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 3),
//                                 Text(
//                                   businessName,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w300,
//                                     color: Colors.black87,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     childCount: 10,
//                   ),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     crossAxisSpacing: 8,
//                     mainAxisSpacing: 8,
//                     childAspectRatio: 3 / 4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
