// import 'dart:io';

// import 'package:appointy/pages/business/business_page.dart';
// import 'package:appointy/pages/business/carousel_page1.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'carousel_page.dart' as carousel;

// class CategoryPage extends StatefulWidget {
//   final String category;

//   const CategoryPage({super.key, required this.category});

//   @override
//   _CategoryPageState createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   List<String> carouselImages = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCarouselImages();
//   }

//   Future<void> _loadCarouselImages() async {
//     try {
//       // Remplacez 'your_business_id' par l'ID dynamique de l'entreprise
//       final doc = await FirebaseFirestore.instance
//           .collection('businesses')
//           .doc('business_id_here') // Utilisez un ID d'entreprise correct ici
//           .get();

//       if (doc.exists && doc.data()?['carouselImages'] != null) {
//         setState(() {
//           carouselImages = List<String>.from(doc.data()?['carouselImages']);
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Document not found or no images available.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading carousel images: $e')),
//       );
//     }
//   }

//   Future<void> _showImageSourceDialog(BuildContext context) async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController urlController = TextEditingController();
//         return AlertDialog(
//           title: const Text('Ajouter une image'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: urlController,
//                 decoration: const InputDecoration(
//                     hintText: 'Entrez l\'URL de l\'image'),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.photo_library),
//                 label: const Text('Choisir depuis la galerie'),
//                 onPressed: () async {
//                   final XFile? pickedFile = await ImagePicker()
//                       .pickImage(source: ImageSource.gallery);
//                   if (pickedFile != null) {
//                     final String fileName =
//                         'carousel/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
//                     final Reference storageRef =
//                         FirebaseStorage.instance.ref().child(fileName);

//                     await storageRef.putFile(File(pickedFile.path));
//                     final String downloadURL =
//                         await storageRef.getDownloadURL();

//                     await _saveImage(downloadURL);
//                   }
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 if (urlController.text.isNotEmpty) {
//                   await _saveImage(urlController.text);
//                 }
//                 Navigator.pop(context);
//               },
//               child: const Text('Ajouter'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Annuler'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _saveImage(String imageUrl) async {
//     if (carouselImages.length >= 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//               'Maximum de 3 images atteint. Supprimez une image avant d\'en ajouter une nouvelle.'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     final List<String> updatedImages = [...carouselImages, imageUrl];
//     try {
//       await FirebaseFirestore.instance
//           .collection('businesses')
//           .doc('business_id_here') // Remplacez avec l'ID de votre entreprise
//           .update({'carouselImages': updatedImages});

//       setState(() {
//         carouselImages = updatedImages;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving image: $e')),
//       );
//     }
//   }

//   Future<void> _deleteImage(String imageUrl) async {
//     final List<String> updatedImages =
//         carouselImages.where((image) => image != imageUrl).toList();

//     try {
//       await FirebaseFirestore.instance
//           .collection('businesses')
//           .doc('business_id_here') // Remplacez avec l'ID de votre entreprise
//           .update({'carouselImages': updatedImages});

//       setState(() {
//         carouselImages = updatedImages;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error deleting image: $e')),
//       );
//     }
//   }

//   Future<void> _deleteBusiness(String businessId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('businesses')
//           .doc(businessId)
//           .delete();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Business supprimé avec succès')),
//       );

//       setState(() {});
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur lors de la suppression : $e')),
//       );
//     }
//   }

//   void _editBusiness(String businessId, Map<String, dynamic>? currentData) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         TextEditingController nameController = TextEditingController(
//           text: currentData?['name'] ?? '',
//         );
//         TextEditingController imageUrlController = TextEditingController(
//           text: currentData?['imageUrl'] ?? '',
//         );

//         return AlertDialog(
//           title: const Text('Modifier le business'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Nom'),
//               ),
//               TextField(
//                 controller: imageUrlController,
//                 decoration: const InputDecoration(labelText: 'Image URL'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 try {
//                   await FirebaseFirestore.instance
//                       .collection('businesses')
//                       .doc(businessId)
//                       .update({
//                     'name': nameController.text,
//                     'imageUrl': imageUrlController.text,
//                   });

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text('Business mis à jour avec succès')),
//                   );

//                   Navigator.pop(context);
//                   setState(() {});
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Erreur : $e')),
//                   );
//                 }
//               },
//               child: const Text('Sauvegarder'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Annuler'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Category Page'),
//         backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
//       ),
//       body: Column(
//         children: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: SizedBox(
//                 height: 270,
//                 child: CarouselPage1(
//                   businessId: 'business_id_here', // Assurez-vous d'utiliser un ID dynamique
//                   carouselImages: carouselImages,
//                   onDeleteImage: _deleteImage,
//                   onAddImage: _showImageSourceDialog,
//                 ),
//               ),
//             ),
//           ),
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
//                                     Positioned(
//                                       top: 0,
//                                       right: 0,
//                                       child: PopupMenuButton<String>(
//                                         onSelected: (String value) async {
//                                           if (value == 'edit') {
//                                             _editBusiness(business.id, data);
//                                           } else if (value == 'delete') {
//                                             await _deleteBusiness(business.id);
//                                           }
//                                         },
//                                         itemBuilder: (BuildContext context) => [
//                                           const PopupMenuItem<String>(
//                                             value: 'edit',
//                                             child: Text('Modifier'),
//                                           ),
//                                           const PopupMenuItem<String>(
//                                             value: 'delete',
//                                             child: Text('Supprimer'),
//                                           ),
//                                         ],
//                                         icon: const Icon(Icons.more_vert),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   businessName,
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     childCount: 50, // Modifier si nécessaire
//                   ),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 8,
//                     mainAxisSpacing: 8,
//                     childAspectRatio: 0.8,
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
