import 'package:appointy/pages/business/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointy/pages/business/models/business.dart';
import 'package:appointy/pages/business/models/service.dart';
import 'package:url_launcher/url_launcher.dart'; // For phone and map functionality
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For File handling

class BusinessDetailPage extends StatefulWidget {
  final String businessId;

  const BusinessDetailPage({
    super.key,
    required this.businessId,
  });

  @override
  _BusinessDetailPageState createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  bool _isDescriptionExpanded = false;
  final TextEditingController _descriptionController = TextEditingController();
  File? _newImage; // To store the new image file

  // Function to update the description
  void _updateDescription(String description) async {
    await FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.businessId)
        .update({'description': description});
  }

  // Function to launch a phone call
  void _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  // Function to open a map for the location
  void _openMap(String address) async {
    final Uri mapUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {'query': address},
    );
    if (await canLaunch(mapUri.toString())) {
      await launch(mapUri.toString());
    } else {
      throw 'Could not launch $mapUri';
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
      _uploadImage(); // Upload the new image
    }
  }

  // Function to upload the new image to Firestore
  Future<void> _uploadImage() async {
    if (_newImage == null) return;

    // Here you can implement the logic to upload the image to Firebase Storage
    // and update the `imageUrl` field in Firestore.
    // For simplicity, this example assumes you have a function to handle the upload.

    // Example:
    // final String imageUrl = await uploadImageToFirebaseStorage(_newImage!);
    // await FirebaseFirestore.instance
    //     .collection('businesses')
    //     .doc(widget.businessId)
    //     .update({'imageUrl': imageUrl});

    // For now, we'll just update the local state
    setState(() {
      // Update the image URL (replace with actual logic)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(221, 60, 60, 60), // Black background
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        flexibleSpace: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              'Business Info',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .doc(widget.businessId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child: Text('Business not found',
                    style: TextStyle(color: Colors.white)));
          }

          final business = Business.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Image
                GestureDetector(
                  onTap: _pickImage, // Allow image change on tap
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: _newImage != null
                            ? FileImage(_newImage!) // Use new image if selected
                            : NetworkImage(business.imageUrl) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    // child: business.imageUrl.isEmpty || _newImage == null
                    //     ? Center(
                    //         child: Icon(
                    //           Icons.business,
                    //           size: 50,
                    //           color: Colors.white.withOpacity(0.7),
                    //         ),
                    //       )
                    //     : null,
                  ),
                ),
                const SizedBox(height: 16),

                // Business Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Name
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Categories
                      Wrap(
                        spacing: 8,
                        children: business.categories.map((category) {
                          return Chip(
                            label: Text(category,
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: const Color(0xFF9C27B0),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Business Description
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9C27B0),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isDescriptionExpanded
                                    ? business.description
                                    : (business.description.length > 200
                                        ? '${business.description.substring(0, 200)}...'
                                        : business.description),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(179, 50, 50, 50),
                                ),
                              ),
                              if (business.description.length > 200)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isDescriptionExpanded
                                        ? 'Read less'
                                        : 'Read more',
                                    style: const TextStyle(
                                        color: Color(0xFF9C27B0)),
                                  ),
                                ),
                              // Button to edit description
                              // IconButton(
                              //   icon: const Icon(Icons.edit,
                              //       color: Color(0xFF9C27B0)),
                              //   onPressed: () {
                              //     // Open a dialog to update description
                              //     showDialog(
                              //       context: context,
                              //       builder: (context) {
                              //         return AlertDialog(
                              //           title: const Text('Update Description'),
                              //           content: TextField(
                              //             controller: _descriptionController,
                              //             decoration: const InputDecoration(
                              //               hintText: 'Enter new description',
                              //             ),
                              //           ),
                              //           actions: [
                              //             TextButton(
                              //               onPressed: () {
                              //                 _updateDescription(
                              //                     _descriptionController.text);
                              //                 Navigator.pop(context);
                              //               },
                              //               child: const Text('Save'),
                              //             ),
                              //             TextButton(
                              //               onPressed: () {
                              //                 Navigator.pop(context);
                              //               },
                              //               child: const Text('Cancel'),
                              //             ),
                              //           ],
                              //         );
                              //       },
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),

                      // Contact Information
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9C27B0),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Color(0xFF9C27B0)),
                                title: Text(business.address,
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 50, 50, 50))),
                                onTap: () {
                                  _openMap(business.address); // Open map
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.phone,
                                    color: Color(0xFF9C27B0)),
                                title: Text(business.phone,
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 50, 50, 50))),
                                onTap: () {
                                  _launchPhoneCall(
                                      business.phone); // Launch call
                                },
                              ),
                              // Button to edit contact information
                              // IconButton(
                              //   icon: const Icon(Icons.edit,
                              //       color: Color(0xFF9C27B0)),
                              //   onPressed: () {
                              //     // Here you can implement a method to update contact info
                              //     showDialog(
                              //       context: context,
                              //       builder: (context) {
                              //         return AlertDialog(
                              //           title:
                              //               const Text('Update Contact Info'),
                              //           content: Column(
                              //             children: [
                              //               TextField(
                              //                 controller: TextEditingController(
                              //                     text: business.address),
                              //                 decoration: const InputDecoration(
                              //                     hintText:
                              //                         'Enter new address'),
                              //               ),
                              //               TextField(
                              //                 controller: TextEditingController(
                              //                     text: business.phone),
                              //                 decoration: const InputDecoration(
                              //                     hintText:
                              //                         'Enter new phone number'),
                              //               ),
                              //             ],
                              //           ),
                              //           actions: [
                              //             TextButton(
                              //               onPressed: () {
                              //                 // Save new contact info here
                              //                 Navigator.pop(context);
                              //               },
                              //               child: const Text('Save'),
                              //             ),
                              //             TextButton(
                              //               onPressed: () {
                              //                 Navigator.pop(context);
                              //               },
                              //               child: const Text('Cancel'),
                              //             ),
                              //           ],
                              //         );
                              //       },
                              //     );
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingPage(
                                    businessId: business.id,
                                    businessName: business.name,
                                    service: Service(
                                      id: '',
                                      businessId: business.id,
                                      name: '',
                                      description: '',
                                      price: 0,
                                      photoUrl: '',
                                      createdAt: DateTime.now(),
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                              elevation: 4,
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
