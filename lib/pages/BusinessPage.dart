// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// class BusinessPage extends StatefulWidget {
//   final String businessName;

//   const BusinessPage({
//     super.key,
//     required this.businessName,
//     required List<String> carouselImages,
//     required List<String> categories,
//     required List<Map<String, String>> products,
//   });

//   @override
//   State<BusinessPage> createState() => _BusinessPageState();
// }

// class _BusinessPageState extends State<BusinessPage> {
//   late List<Map<String, String>> products;
//   late List<String> carouselImages;

//   @override
//   void initState() {
//     super.initState();
//     products = [];
//     carouselImages = [];
//     _loadData(); // Charger les données dès le début
//   }

//   Future<void> _loadData() async {
//     final businessRef = FirebaseFirestore.instance
//         .collection('businesses')
//         .doc(widget.businessName);

//     // Charger les produits
//     var productsSnapshot = await businessRef.collection('products').get();
//     setState(() {
//       // Conversion explicite des produits en List<Map<String, String>>
//       products = productsSnapshot.docs.map((doc) {
//         return {
//           'name': doc['name'] as String,
//           'image': doc['image'] as String,
//         };
//       }).toList();
//     });

//     // Charger les images du carrousel et les convertir en List<String>
//     var imagesSnapshot = await businessRef.collection('carousel').get();
//     setState(() {
//       carouselImages = imagesSnapshot.docs.map((doc) {
//         return doc['image'] as String;
//       }).toList();
//     });
//   }

//   void _addProduct(Map<String, String> newProduct) async {
//     try {
//       final businessRef = FirebaseFirestore.instance
//           .collection('businesses')
//           .doc(widget.businessName);

//       // Ajouter le produit à la collection Firestore
//       await businessRef.collection('products').add({
//         'name': newProduct['name']!,
//         'image': newProduct['image']!,
//       });

//       // Mettre à jour l'état local
//       setState(() {
//         products.add(newProduct);
//       });
//     } catch (e) {
//       print("Erreur lors de l'ajout du produit: $e");
//     }
//   }

//   void _updateCarouselImages(String newImage) async {
//     try {
//       final businessRef = FirebaseFirestore.instance
//           .collection('businesses')
//           .doc(widget.businessName);

//       // Ajouter l'image au carrousel dans Firestore
//       await businessRef.collection('carousel').add({
//         'image': newImage,
//       });

//       // Mettre à jour l'état local
//       setState(() {
//         carouselImages.add(newImage);
//       });
//     } catch (e) {
//       print("Erreur lors de l'ajout de l'image: $e");
//     }
//   }

//   void _removeProduct(int index) async {
//     try {
//       final product = products[index];
//       final businessRef = FirebaseFirestore.instance
//           .collection('businesses')
//           .doc(widget.businessName);

//       // Supprimer le produit de Firestore
//       var productQuery = await businessRef
//           .collection('products')
//           .where('name', isEqualTo: product['name'])
//           .get();

//       if (productQuery.docs.isNotEmpty) {
//         await productQuery.docs.first.reference.delete();
//       }

//       // Supprimer le produit de la liste locale
//       setState(() {
//         products.removeAt(index);
//       });
//     } catch (e) {
//       print("Erreur lors de la suppression du produit: $e");
//     }
//   }

//   void _removeCarouselImage(int index) async {
//     try {
//       final image = carouselImages[index];
//       final businessRef = FirebaseFirestore.instance
//           .collection('businesses')
//           .doc(widget.businessName);

//       // Supprimer l'image du carrousel dans Firestore
//       var imageQuery = await businessRef
//           .collection('carousel')
//           .where('image', isEqualTo: image)
//           .get();

//       if (imageQuery.docs.isNotEmpty) {
//         await imageQuery.docs.first.reference.delete();
//       }

//       // Supprimer l'image de la liste locale
//       setState(() {
//         carouselImages.removeAt(index);
//       });
//     } catch (e) {
//       print("Erreur lors de la suppression de l'image: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.businessName)),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Carousel
//             CarouselSlider(
//               items: carouselImages.map((image) {
//                 int index = carouselImages.indexOf(image);
//                 return Stack(
//                   children: [
//                     Image.network(
//                       image,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) {
//                           return child;
//                         } else {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                       },
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Center(
//                             child: Icon(Icons.error, color: Colors.red));
//                       },
//                     ),
//                     Positioned(
//                       top: 10,
//                       right: 10,
//                       child: IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.white),
//                         onPressed: () => _removeCarouselImage(index),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//               options: CarouselOptions(
//                 height: 120,
//                 autoPlay: true,
//                 enlargeCenterPage: true,
//               ),
//             ),

//             // Categories
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 'Catégories',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),

//             // List of products
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Produits',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) =>
//                             AddProductDialog(onAddProduct: _addProduct),
//                       );
//                     },
//                     child: const Text('Ajouter un produit'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) =>
//                             AddImageDialog(onAddImage: _updateCarouselImages),
//                       );
//                     },
//                     child: const Text('Ajouter une image'),
//                   ),
//                 ],
//               ),
//             ),

//             // GridView des produits
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 3 / 4,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemCount: products.length,
//               itemBuilder: (context, index) {
//                 final product = products[index];
//                 return Card(
//                   elevation: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Image.network(
//                           product['image']!,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) {
//                               return child;
//                             } else {
//                               return const Center(
//                                   child: CircularProgressIndicator());
//                             }
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return const Center(
//                                 child: Icon(Icons.error, color: Colors.red));
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           product['name']!,
//                           style: Theme.of(context).textTheme.titleMedium,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete),
//                         onPressed: () => _removeProduct(index),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AddProductDialog extends StatefulWidget {
//   final Function(Map<String, String>) onAddProduct;

//   const AddProductDialog({super.key, required this.onAddProduct});

//   @override
//   State<AddProductDialog> createState() => _AddProductDialogState();
// }

// class _AddProductDialogState extends State<AddProductDialog> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _imageController = TextEditingController();

//   void _submit() {
//     final name = _nameController.text.trim();
//     final image = _imageController.text.trim();
//     if (name.isNotEmpty && image.isNotEmpty) {
//       widget.onAddProduct({'name': name, 'image': image});
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Ajouter un produit'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: 'Nom du produit'),
//             ),
//             TextField(
//               controller: _imageController,
//               decoration: const InputDecoration(labelText: 'URL de l\'image'),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: _submit,
//           child: const Text('Ajouter'),
//         ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Annuler'),
//         ),
//       ],
//     );
//   }
// }

// class AddImageDialog extends StatefulWidget {
//   final Function(String) onAddImage;

//   const AddImageDialog({super.key, required this.onAddImage});

//   @override
//   State<AddImageDialog> createState() => _AddImageDialogState();
// }

// class _AddImageDialogState extends State<AddImageDialog> {
//   final TextEditingController _imageController = TextEditingController();

//   void _submit() {
//     final image = _imageController.text.trim();
//     if (image.isNotEmpty) {
//       widget.onAddImage(image);
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Ajouter une image'),
//       content: TextField(
//         controller: _imageController,
//         decoration: const InputDecoration(labelText: 'URL de l\'image'),
//       ),
//       actions: [
//         ElevatedButton(
//           onPressed: _submit,
//           child: const Text('Ajouter'),
//         ),
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Annuler'),
//         ),
//       ],
//     );
//   }
// }
