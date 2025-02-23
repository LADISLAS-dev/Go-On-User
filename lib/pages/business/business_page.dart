import 'dart:io';
import 'dart:ui';

import 'package:appointy/login/screen/chat/user_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:appointy/pages/business/BusinessDetailPage.dart';
import 'package:appointy/pages/business/create_business_page.dart';
import 'package:appointy/pages/business/models/business.dart';
import 'package:appointy/pages/business/models/service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'appointments_list_page.dart';
import 'edit_service_page.dart';
import 'service_detail_page.dart';
import 'package:get/get.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, required this.businessId});

  final String businessId;

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late List<Widget> _pages;
  int _selectedIndex = 0;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid ?? 'defaultUserId';
      _initializePages();
    });
  }

  void _initializePages() {
    _pages = [
      BusinessPage(businessId: widget.businessId),
      AppointmentsListPage(businessId: widget.businessId),
      const MessagingPage(),
      CreateBusinessPage(businessId: widget.businessId),
    ];
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          heroTag: 'mainNavigationFAB',
          onPressed: () {
            print('FAB Pressed');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessagingPage(),
                ));
          },
          backgroundColor: Colors.red,
          elevation: 8,
          child: const Icon(
            Icons.message_outlined,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 198, 22, 22),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home, 'Accueil'),
            _buildNavItem(
                1, Icons.calendar_month_outlined, Icons.calendar_month, 'RDV'),
            _buildNavItem(2, Icons.chat_outlined, Icons.chat, 'Messages'),
            _buildNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
          ],
        ),
      ),
    );
  }
}

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key, required this.businessId});

  final String businessId;

  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  List<String> carouselImages = [];
  // final TextEditingController _searchController = TextEditingController();
  late Stream<DocumentSnapshot> _businessStream;
  int _selectedIndex = 0; // Définissez _selectedIndex ici
  late Stream<QuerySnapshot> _servicesStream;

  @override
  void initState() {
    super.initState();
    _businessStream = FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.businessId)
        .snapshots();

    _servicesStream = FirebaseFirestore.instance
        .collection('services')
        .where('businessId', isEqualTo: widget.businessId)
        .snapshots();

    _loadCarouselImages();
  }

  Widget ServiceCard({required Service service}) {
    Future<void> pickAndUploadImage() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);

        if (image == null) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final String fileName =
            'services/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(File(image.path));
        final String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('services')
            .doc(service.id)
            .update({'photoUrl': downloadURL});

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image mise à jour avec succès')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'upload: $e')),
          );
        }
      }
    }

    return Transform.translate(
      offset: const Offset(0, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailPage(service: service),
          ),
        ),
        onLongPress: () => _showServiceOptions(service),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: service.photoUrl.isNotEmpty
                  ? Stack(
                      children: [
                        Image.network(
                          service.photoUrl,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultImageContainer();
                          },
                        ),
                        // Positioned(// icon edit dans le service
                        //   right: 5,
                        //   top: 5,
                        //   child: IconButton(
                        //     icon: const Icon(
                        //       Icons.edit_outlined,
                        //       color: Colors.white,
                        //     ),
                        //     onPressed: pickAndUploadImage,
                        //   ),
                        // ),
                      ],
                    )
                  : InkWell(
                      onTap: pickAndUploadImage,
                      child: _buildDefaultImageContainer(),
                    ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImageContainer() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 50,
              color: Colors.grey,
            ),
            Text(
              'Ajouter une image',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget MyCarousel() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // const Text('Images du carousel'),
                  const SizedBox(width: 8),
                  // Text(
                  //   '(${carouselImages.length}/3)',
                  //   style: TextStyle(
                  //     color:
                  //         carouselImages.length >= 3 ? Colors.red : Colors.grey,
                  //     fontSize: 12,
                  //   ),
                  // ),
                ],
              ),

              // if (carouselImages.length < 3) // icon ajouter dans le carousel
              //   IconButton(
              //     icon: const Icon(Icons.add),
              //     onPressed: () => _showImageSourceDialog(),
              //   ),
            ],
          ),
        ),
        if (carouselImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CarouselSlider(
                  items: carouselImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Positioned(// icon supprimer dans le carousel
                        //   right: 5,
                        //   top: 5,
                        //   child: IconButton(
                        //     icon: const Icon(Icons.delete, color: Colors.red),
                        //     onPressed: () => _deleteImage(image),
                        //   ),
                        // ),
                      ],
                    );
                  }).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    viewportFraction: 1,
                  ),
                ),
              ),
            ),
          ),
        if (carouselImages.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('Aucune image dans le carousel'),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _showImageSourceDialog(),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Ajouter une image'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _loadCarouselImages() async {
    final doc = await FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.businessId)
        .get();

    if (doc.exists && doc.data()?['carouselImages'] != null) {
      setState(() {
        carouselImages = List<String>.from(doc.data()?['carouselImages']);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppointmentsListPage(businessId: widget.businessId),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessagingPage(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessDetailPage(
              businessId: widget.businessId,
            ),
          ),
        );
        break;
    }
  }

  void _showQuickAppointmentDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    String selectedTime = '09:00';
    final TextEditingController nameController = TextEditingController();
    final TextEditingController serviceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau Rendez-vous'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du client',
                  icon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: serviceController,
                decoration: const InputDecoration(
                  labelText: 'Service',
                  icon: Icon(Icons.business_center),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure'),
                subtitle: Text(selectedTime),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      DateFormat('HH:mm').parse(selectedTime),
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  serviceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez remplir tous les champs')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .add({
                  'clientName': nameController.text,
                  'serviceName': serviceController.text,
                  'date': selectedDate,
                  'time': selectedTime,
                  'status': 'pending',
                  'businessId': widget.businessId,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rendez-vous créé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showServiceOptions(Service service) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        // children: [
        //   ListTile(
        //     leading: const Icon(Icons.edit),
        //     title: const Text('Modifier'),
        //     onTap: () {
        //       Navigator.pop(context);
        //       _editService(service);
        //     },
        //   ),
        //   ListTile(
        //     leading: const Icon(Icons.delete, color: Colors.red),
        //     title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        //     onTap: () {
        //       Navigator.pop(context);
        //       _confirmDeleteService(service);
        //     },
        //   ),
        // ],
      ),
    );
  }

  void _editService(Service service) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServicePage(service: service),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _confirmDeleteService(Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${service.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService(service);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(Service service) async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(service.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  Future<void> _showImageSourceDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Ajouter par URL'),
              onTap: () {
                Navigator.pop(context);
                _addImageByUrl();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choisir une image locale'),
              onTap: () {
                Navigator.pop(context);
                _addLocalImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addImageByUrl() async {
    final TextEditingController urlController = TextEditingController();

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrer l\'URL de l\'image'),
        content: TextField(controller: urlController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, urlController.text),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      await _saveImage(url);
    }
  }

  Future<void> _addLocalImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      final String fileName =
          'carousel/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);

      await storageRef.putFile(File(image.path));
      final String downloadURL = await storageRef.getDownloadURL();

      await _saveImage(downloadURL);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image ajoutée avec succès')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'image: $e')),
        );
      }
    }
  }

  Future<void> _saveImage(String imageUrl) async {
    if (carouselImages.length >= 3) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Maximum de 3 images atteint. Supprimez une image avant d\'en ajouter une nouvelle.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final List<String> updatedImages = [...carouselImages, imageUrl];
    await FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.businessId)
        .update({'carouselImages': updatedImages});

    setState(() {
      carouselImages = updatedImages;
    });
  }

  Future<void> _deleteImage(String imageUrl) async {
    final List<String> updatedImages =
        carouselImages.where((image) => image != imageUrl).toList();

    await FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.businessId)
        .update({'carouselImages': updatedImages});

    setState(() {
      carouselImages = updatedImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _businessStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'Erreur de chargement'.tr,
                style: const TextStyle(color: Colors.white),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(
                'Business non trouvé'.tr,
                style: const TextStyle(color: Colors.white),
              );
            }

            final business = Business.fromFirestore(snapshot.data!);
            return Text(
              overflow: TextOverflow.ellipsis,
              business.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        elevation: 3,
        backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareApp();
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _businessStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: Center(child: Text('Erreur: ${snapshot.error}')),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: const Text('Non trouvé')),
              body: const Center(child: Text('Cette entreprise n\'existe pas')),
            );
          }

          final business = Business.fromFirestore(snapshot.data!);

          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // const MySearchBar(),
                            MyCarousel(),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9C27B0),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFCE93D8),
                                          width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Services',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.supervised_user_circle,
                                            color: Color(0xFFFFFFFF), size: 26),
                                        SizedBox(width: 28),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _navigateToGallery,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.purple.shade200,
                                          width: 1),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Gallery',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF9C27B0),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.photo_library,
                                            color: Color(0xFF9C27B0), size: 20),
                                        SizedBox(width: 28),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _servicesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return SliverToBoxAdapter(
                              child: Center(
                                  child: Text('Erreur: ${snapshot.error}')),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SliverToBoxAdapter(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final services = snapshot.data?.docs ?? [];

                          if (services.isEmpty) {
                            return const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Aucun service disponible'),
                                ),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final service =
                                      Service.fromFirestore(services[index]);
                                  return ServiceCard(service: service);
                                },
                                childCount: services.length,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const BannerAdWidget(), // Affichez la bannière publicitaire ici
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                  backgroundColor: Color.fromRGBO(156, 39, 176, 1),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Booking',
                  backgroundColor: Color.fromRGBO(156, 39, 176, 1),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message_outlined),
                  label: 'Conversation',
                  backgroundColor: Color.fromRGBO(156, 39, 176, 1),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business_outlined),
                  label: 'About us',
                  backgroundColor: Color.fromRGBO(156, 39, 176, 1),
                ),
              ],
              currentIndex: _selectedIndex, // Utilisez _selectedIndex ici
              selectedItemColor: Colors.white,
              showSelectedLabels:
                  true, // Assurez-vous que les labels sélectionnés sont visibles
              showUnselectedLabels:
                  true, // Assurez-vous que les labels non sélectionnés sont visibles
              onTap: (index) {
                setState(() {
                  _selectedIndex = index; // Mettez à jour _selectedIndex
                });

                // Ajoutez la logique de navigation ici
                switch (index) {
                  case 0:
                    // Naviguer vers la page d'accueil
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BusinessPage(businessId: widget.businessId),
                      ),
                    );
                    break;
                  case 1:
                    // Naviguer vers la page de rendez-vous
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AppointmentsListPage(businessId: widget.businessId),
                      ),
                    );
                    break;
                  case 2:
                    // Naviguer vers la page de conversation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MessagingPage(),
                      ),
                    );
                    break;
                  case 3:
                    // Naviguer vers la page "À propos"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusinessDetailPage(
                          businessId: widget.businessId,
                        ),
                      ),
                    );
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPage(businessId: widget.businessId),
      ),
    );
  }

  void _shareApp() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String storeUrl = '';

    if (Platform.isAndroid) {
      storeUrl =
          'https://play.google.com/store/apps/details?id=votre.package.name';
    } else if (Platform.isIOS) {
      storeUrl = 'https://apps.apple.com/app/id123456789';
    } else {
      storeUrl = 'https://votre-site-web.com';
    }

    final String message =
        "discover_app_message".trParams({'storeUrl': storeUrl});

    Share.share(message);
  }
}

class GalleryPage extends StatefulWidget {
  final String businessId;

  const GalleryPage({super.key, required this.businessId});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addImage() async {
    try {
      // Sélectionner plusieurs images
      final List<XFile>? images = await _picker.pickMultiImage();

      if (images == null || images.isEmpty) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Téléverser chaque image sélectionnée
      for (final image in images) {
        final String fileName =
            'gallery/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(fileName);

        await storageRef.putFile(File(image.path));
        final String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('gallery').add({
          'url': downloadURL,
          'businessId': widget.businessId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${images.length} images ajoutées avec succès')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout des images: $e')),
        );
      }
    }
  }

  Future<void> _deleteImage(String imageId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('gallery')
          .doc(imageId)
          .delete();

      final Reference storageRef =
          FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image supprimée avec succès')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  void _openFullScreenGallery(BuildContext context, int initialIndex,
      List<DocumentSnapshot> galleryImages) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          initialIndex: initialIndex,
          galleryImages: galleryImages,
          onDeleteImage: _deleteImage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          //icon add dans la guallerie
          // IconButton(
          //   icon: const Icon(Icons.add, color: Colors.white),
          //   onPressed: _addImage,
          // ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gallery')
            .where('businessId', isEqualTo: widget.businessId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final galleryImages = snapshot.data?.docs ?? [];

          if (galleryImages.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucune image dans la galerie',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                final imageDoc = galleryImages[index];
                final imageUrl = imageDoc['url'];
                final imageId = imageDoc.id;

                return GestureDetector(
                  onTap: () =>
                      _openFullScreenGallery(context, index, galleryImages),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                          // Positioned(
                          //   // icon delete dans la galerie
                          //   top: 8,
                          //   right: 8,
                          //   child: IconButton(
                          //     icon: const Icon(Icons.delete, color: Colors.red),
                          //     onPressed: () => _deleteImage(imageId, imageUrl),
                          //   ),
                          // ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FullScreenGallery extends StatelessWidget {
  final int initialIndex;
  final List<DocumentSnapshot> galleryImages;
  final Function(String imageId, String imageUrl) onDeleteImage;

  const FullScreenGallery({
    super.key,
    required this.initialIndex,
    required this.galleryImages,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF9C27B0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: PageView.builder(
        itemCount: galleryImages.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          final imageUrl = galleryImages[index]['url'];
          final imageId = galleryImages[index].id;

          return GestureDetector(
            onTap: () {},
            child: Center(
              child: Stack(
                children: [
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 1,
                    maxScale: 4,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        onDeleteImage(imageId, imageUrl);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
/////_______-----------_________________
///

////---------------------------
///
///
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-1917025047521980/2688492101', // ID de test pour Android
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBannerAdReady && _bannerAd != null) {
      return Container(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox
          .shrink(); // Cachez le widget si la bannière n'est pas prête
    }
  }
}
