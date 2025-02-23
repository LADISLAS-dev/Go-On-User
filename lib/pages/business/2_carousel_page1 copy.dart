// import 'package:appointy/pages/business/business_page.dart';
// import 'package:appointy/pages/business/carousel_page.dart' as appointy;
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // Assurez-vous d'importer correctement la page de détails

// void main() => runApp(const CarouselPage1(
//       businessId: 'your_business_id', // Replace with your actual business ID
//       carouselImages: [],
//       onDeleteImage: null,
//       onAddImage: null,
//     ));

// class CarouselPage1 extends StatelessWidget {
//   final String businessId;
//   final List<String> carouselImages;
//   final Future<void> Function(String imageUrl)? onDeleteImage;
//   final Future<void> Function()? onAddImage;

//   const CarouselPage1({
//     super.key,
//     required this.businessId,
//     required this.carouselImages,
//     required this.onDeleteImage,
//     required this.onAddImage,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: CarouselExample(businessId: businessId),
//       ),
//     );
//   }
// }

// class CarouselExample extends StatefulWidget {
//   final String businessId;

//   const CarouselExample({super.key, required this.businessId});

//   @override
//   State<CarouselExample> createState() => _CarouselExampleState();
// }

// class _CarouselExampleState extends State<CarouselExample> {
//   List<QueryDocumentSnapshot> businesses = [];
//   final controller = CarouselController();

//   Future<void> _loadBusinesses() async {
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance.collection('businesses').get();
//       setState(() {
//         businesses = snapshot.docs;
//       });
//     } catch (e) {
//       print('Error loading businesses: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadBusinesses();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         //////// Premier carousel
//         // Add the carousel at the top
//         // ConstrainedBox(
//         //   constraints:
//         //       BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
//         //   child: CarouselView.weighted(
//         //     controller: controller,
//         //     itemSnapping: true,
//         //     flexWeights: const <int>[1, 7, 1],
//         //     children: appointy.ImageInfo.values.map((appointy.ImageInfo image) {
//         //       return appointy.HeroLayoutCard(imageInfo: image);
//         //     }).toList(),
//         //   ),
//         // ),
//         ////_-----------------
//         ///
//         StreamBuilder<QuerySnapshot>(
//           stream:
//               FirebaseFirestore.instance.collection('promotions').snapshots(),
//           builder: (context, snapshot) {
//             final defaultImages = [
//               {'imageUrl': 'images/11.png', 'title': 'Image par défaut 1'},
//               {'imageUrl': 'images/22.jpg', 'title': 'Image par défaut 2'},
//               {'imageUrl': 'images/55.jpg', 'title': 'Image par défaut 3'},
//             ];

//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final promotions =
//                 snapshot.hasData && snapshot.data!.docs.isNotEmpty
//                     ? snapshot.data!.docs
//                     : defaultImages;

//             return CarouselSlider(
//               options: CarouselOptions(
//                 height: 200,
//                 autoPlay: true,
//                 enlargeCenterPage: true,
//                 aspectRatio: 16 / 9,
//                 viewportFraction: 0.96,
//                 autoPlayAnimationDuration: const Duration(seconds: 2),
//                 autoPlayCurve: Curves.easeInOut,
//               ),
//               items: promotions.map((data) {
//                 final imageUrl = (data as Map<String, dynamic>)['imageUrl'];
//                 final title = (data as Map<String, dynamic>)['title'];

//                 return Builder(
//                   builder: (BuildContext context) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 8.0),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: const Offset(2, 4),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(15),
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             Image.network(
//                               imageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(Icons.image, size: 50);
//                               },
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.bottomCenter,
//                                   end: Alignment.topCenter,
//                                   colors: [
//                                     Colors.black.withOpacity(0.6),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                               child: Align(
//                                 alignment: Alignment.bottomLeft,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(10.0),
//                                   child: Text(
//                                     title,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }).toList(),
//             );
//           },
//         ),

//         // Your existing business carousel
//         ConstrainedBox(
//           constraints: const BoxConstraints(maxHeight: 60),
//           child: CarouselView.weighted(
//             flexWeights: const <int>[1, 2, 3, 2, 1], // Adjust weights as needed
//             consumeMaxWeight: false,
//             children: List<Widget>.generate(businesses.length, (int index) {
//               final business = businesses[index];
//               final data = business.data() as Map<String, dynamic>?;
//               final businessName = data?['name'] ?? 'Entreprise sans nom';
//               final businessImageUrl = data?['imageUrl'];

//               return GestureDetector(
//                 onTap: () {
//                   // Ajoutez un print pour déboguer
//                   print("Business ID tapped: ${business.id}");

//                   // When a business is clicked, navigate to the detail page
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           BusinessPage(businessId: business.id),
//                     ),
//                   );
//                 },
//                 child: ColoredBox(
//                   color: Colors.primaries[index % Colors.primaries.length]
//                       .withOpacity(0.8),
//                   child: SizedBox.expand(
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         mainAxisSize: MainAxisSize
//                             .min, // Ensures Row shrinks to fit its content
//                         children: [
//                           // Image inside a perfect circle
//                           Container(
//                             margin: const EdgeInsets.all(8.0),
//                             width: 30, // Slightly bigger image
//                             height:
//                                 30, // Same width and height for circular shape
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
//                               child: businessImageUrl != null &&
//                                       businessImageUrl.isNotEmpty
//                                   ? Image.network(
//                                       businessImageUrl,
//                                       width: 30,
//                                       height: 30,
//                                       fit: BoxFit
//                                           .cover, // Keep image within the circle
//                                     )
//                                   : Container(
//                                       color: Colors.grey[300],
//                                       child: const Icon(Icons.business,
//                                           size: 25, color: Colors.white),
//                                     ),
//                             ),
//                           ),
//                           // Use Flexible widget with loose fit
//                           Flexible(
//                             fit: FlexFit
//                                 .loose, // Allows the text to take up as much space as needed
//                             child: Text(
//                               businessName,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.left,
//                               overflow:
//                                   TextOverflow.ellipsis, // Truncate if too long
//                               maxLines: 1, // Ensure text fits in one line
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // class BusinessPage extends StatelessWidget {
// //   final String businessId;

// //   const BusinessPage({super.key, required this.businessId});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Business Details'),
// //       ),
// //       body: FutureBuilder<DocumentSnapshot>(
// //         future: FirebaseFirestore.instance
// //             .collection('businesses')
// //             .doc(businessId)
// //             .get(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           }

// //           if (!snapshot.hasData || snapshot.data == null) {
// //             return const Center(child: Text('Business not found'));
// //           }

// //           final data = snapshot.data!.data() as Map<String, dynamic>?;
// //           final businessName = data?['name'] ?? 'Entreprise sans nom';
// //           final businessDescription = data?['description'] ?? 'No description';

// //           return Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Business Name: $businessName',
// //                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Text(
// //                   'Description: $businessDescription',
// //                   style: const TextStyle(fontSize: 16),
// //                 ),
// //                 // Add more details here
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
