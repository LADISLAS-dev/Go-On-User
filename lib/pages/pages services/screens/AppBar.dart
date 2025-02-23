import 'dart:async';
import 'dart:io';
import 'package:appointy/login/Services/authentification.dart';
import 'package:appointy/login/screen/login.dart';
import 'package:appointy/pages/sous_pages/admin/profileSettting.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart'; // Importez Get pour utiliser les traductions

class EditProfilePage extends StatefulWidget {
  final Function() onProfileUpdated;

  const EditProfilePage({super.key, required this.onProfileUpdated});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class ProfileScreen extends StatefulWidget {
  final Function() onProfileUpdated;

  const ProfileScreen({super.key, required this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = '';
  String userEmail = '';
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists && mounted) {
          setState(() {
            userName = userData.data()?['name'] ?? '';
            userEmail = userData.data()?['email'] ?? '';
            profileImageUrl = userData.data()?['profileImage'];
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('error_message'.trParams({'error': e.toString()}))),
        );
      }
    }
  }

  Stream<DocumentSnapshot> get _userDataStream {
    final User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData != null) {
            userName = userData['name'] ?? '';
            profileImageUrl = userData['profileImage'];
          }
        }

        return Container(
          decoration: const BoxDecoration(),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Aligne à gauche
                children: [
                  // Avatar sans interaction de clic
                  Hero(
                    tag: 'profileImage',
                    child: CircleAvatar(
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : const AssetImage('images/Profile3.png')
                              as ImageProvider,
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 10), // Espace entre l'image et le texte
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Texte à gauche
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Hello !".tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileDrawer extends StatelessWidget {
  final Function() onProfileUpdated;

  const ProfileDrawer({
    super.key,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'profile_settings'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text('edit_profile'.tr),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    onProfileUpdated: onProfileUpdated,
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('settings'.tr),
            onTap: () {
              // Navigation vers la page des paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: Text('admin'.tr),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSetting(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text('share'.tr),
            onTap: () {
              _shareApp();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                Text('sign_out'.tr, style: const TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.example.yourapp';
    final String text = 'discover_app_message'.trParams({'appLink': appLink});

    Share.share(text);
  }
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  File? _image;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists && mounted) {
          setState(() {
            _nameController.text = userData.data()?['name'] ?? '';
            _emailController.text = userData.data()?['email'] ?? '';
            _contactController.text = userData.data()?['contact'] ?? '';
            _currentProfileImageUrl = userData.data()?['profileImage'];
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('error_message'.trParams({'error': e.toString()}))),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text("take_photo".tr),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text("choose_from_gallery".tr),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('saving_changes'.tr),
            duration: const Duration(seconds: 1),
          ),
        );

        Map<String, dynamic> updateData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'contact': _contactController.text,
        };

        if (_image != null) {
          final storageRef = _storage.ref().child('profile_images/${user.uid}');
          await storageRef.putFile(_image!);
          final imageUrl = await storageRef.getDownloadURL();
          updateData['profileImage'] = imageUrl;
        }

        await _firestore.collection('users').doc(user.uid).update(updateData);

        if (user.email != _emailController.text) {
          await user.updateEmail(_emailController.text);
        }

        widget.onProfileUpdated();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('changes_saved_successfully'.tr),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error updating user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_message'.trParams({'error': e.toString()})),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "edit_profile".tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Hero(
                              tag: 'profileImage',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _image != null
                                    ? FileImage(
                                        _image!) // Use FileImage if _image is not null
                                    : (_currentProfileImageUrl != null
                                        ? NetworkImage(
                                            _currentProfileImageUrl!) // Use NetworkImage if URL is available
                                        : null), // Set to null if neither _image nor _currentProfileImageUrl is available
                                backgroundColor: Colors.grey[
                                    200], // Background color for the CircleAvatar
                                child: _image == null &&
                                        _currentProfileImageUrl == null
                                    ? const Icon(Icons.camera_alt,
                                        size: 40,
                                        color: Colors.grey) // Fallback icon
                                    : null, // No child if image is available
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "name".tr,
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "email".tr,
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: "contact_phone".tr,
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "save_changes".tr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
