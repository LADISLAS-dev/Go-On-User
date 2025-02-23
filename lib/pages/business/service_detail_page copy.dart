// import 'package:flutter/material.dart';
// import 'package:appointy/pages/business/models/service.dart';
// import 'package:appointy/pages/business/booking_page.dart';

// class ServiceDetailPage extends StatefulWidget {
//   final Service service;

//   const ServiceDetailPage({
//     super.key,
//     required this.service,
//   });

//   @override
//   _ServiceDetailPageState createState() => _ServiceDetailPageState();
// }

// class _ServiceDetailPageState extends State<ServiceDetailPage> {
//   bool isLiked = false;
//   Color? selectedColor;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           // Partie supérieure avec image et retour
//           Stack(
//             children: [
//               Hero(
//                 tag: widget.service.name,
//                 child: Container(
//                   height: MediaQuery.of(context).size.height * 0.5,
//                   decoration: const BoxDecoration(
//                     color: Colors.deepPurpleAccent,
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(50),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 6,
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.only(
//                             bottomLeft: Radius.circular(50),
//                           ),
//                           child: Image.network(
//                             widget.service.photoUrl,
//                             height: double.infinity,
//                             width: double.infinity,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return const Center(
//                                 child: Icon(
//                                   Icons.image_not_supported,
//                                   size: 100,
//                                   color: Colors.white,
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 1,
//                         child: Container(
//                           color: Colors.purple.shade900,
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const SizedBox(height: 10),
//                                 Column(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           selectedColor = Colors.red;
//                                         });
//                                       },
//                                       child: const CircleAvatar(
//                                         radius: 8,
//                                         backgroundColor: Colors.red,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           selectedColor =
//                                               Colors.deepPurpleAccent;
//                                         });
//                                       },
//                                       child: const CircleAvatar(
//                                         radius: 8,
//                                         backgroundColor:
//                                             Colors.deepPurpleAccent,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           selectedColor = Colors.blueGrey;
//                                         });
//                                       },
//                                       child: const CircleAvatar(
//                                         radius: 8,
//                                         backgroundColor: Colors.blueGrey,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           selectedColor = Colors.green;
//                                         });
//                                       },
//                                       child: const CircleAvatar(
//                                         radius: 8,
//                                         backgroundColor: Colors.green,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       isLiked = !isLiked;
//                                     });
//                                   },
//                                   child: Icon(
//                                     isLiked
//                                         ? Icons.favorite
//                                         : Icons.favorite_border,
//                                     color: isLiked ? Colors.red : Colors.white,
//                                     size: 35,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 left: 10,
//                 top: MediaQuery.of(context).padding.top + 10,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // Partie inférieure avec défilement
//           Expanded(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(30.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.service.name,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 35,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       widget.service.description,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.black54,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Price",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 23,
//                       ),
//                     ),
//                     Text(
//                       '€${widget.service.price.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 35,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Fixed "Book Now" button
//           Container(
//             alignment: Alignment.center,
//             height: 80,
//             decoration: BoxDecoration(
//               color: selectedColor ?? Colors.deepPurple,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(60),
//                 topRight: Radius.circular(60),
//               ),
//             ),
//             child: TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => BookingPage(
//                       service: widget.service,
//                       businessId: widget.service.businessId,
//                       businessName: widget.service.name,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text(
//                 "Book Now",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 25,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
