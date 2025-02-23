import 'package:appointy/Language/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appointy/Language/SettingsPage.dart';
import 'package:appointy/main.dart';
import 'package:appointy/pages/business/carousel_page1.dart';
import 'package:appointy/pages/business/reorganisation/CategoryPage.dart';
import 'package:appointy/pages/pages%20services/screens/AppBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String businessId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Color> containerColors = [
    Colors.blueAccent,
    Colors.green,
    Colors.redAccent,
    Colors.deepPurple,
    Colors.orange,
    Colors.teal,
    Colors.pinkAccent,
    Colors.cyan,
  ];

  final Map<String, IconData> categoryIcons = {
    'Restaurant': Icons.restaurant,
    'Food and Beverages': Icons.fastfood,
    'Art and Entertainment': Icons.theater_comedy,
    'Health and Wellness': Icons.local_hospital,
    'Fashion and Beauty': Icons.checkroom,
    'Technology and IT': Icons.computer,
    'Commerce and Retail': Icons.store,
    'Professional Services': Icons.business_center,
    'Real Estate and Construction': Icons.house,
    'Education and Training': Icons.school,
    'Transport and Logistics': Icons.directions_car,
    'Events': Icons.event,
    'Media and Communication': Icons.movie,
    'Agriculture and Agro-industry': Icons.grain,
    'Tourism and Leisure': Icons.location_on,
    'Energy and Environment': Icons.eco,
    'Legal Services': Icons.gavel,
    'Financial Services': Icons.account_balance,
  };

  RewardedAd? _rewardedAd;
  final bool _isRewardedAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _showDeleteAccountDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_account'.tr,
              style: const TextStyle(color: Colors.red)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Are you sure you want to delete your account? This action is irreversible.'
                      .tr),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  Text('Cancel'.tr, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                String password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter your password'.tr)),
                  );
                  return;
                }
                await _deleteAccount(context, password);
                Navigator.of(context).pop();
              },
              child:
                  Text('Delete'.tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context, String password) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
        await user.delete();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        await FirebaseAuth.instance.signOut();
        Get.offAll(() => const SplashScreen());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: $e')),
      );
    }
  }

  void _shareApp() {
    // Implémentez la logique de partage ici
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in")),
      );
    }

    return Scaffold(
      endDrawer: _buildDrawer(context, user),
      appBar: AppBar(
        automaticallyImplyLeading: false, // Désactive la flèche de retour
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: ProfileScreen(
                onProfileUpdated: () {
                  // Logique pour mettre à jour le profil
                },
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                height: 270,
                child: CarouselPage1(
                  businessId: 'business_id',
                  carouselImages: const [],
                  onDeleteImage: (String imageUrl) async {
                    // Logic to delete an image
                  },
                  onAddImage: () async {
                    // Logic to add an image
                  },
                ),
              ),
            ),
          ),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User user) {
    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('user_not_found'.tr));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'Nom de l\'utilisateur';
          final userEmail = userData['email'] ?? 'email@example.com';
          final profileImageUrl = userData['profileImage'];

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundImage:
                      profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                  backgroundColor: Colors.grey,
                  child: profileImageUrl == null || profileImageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text('edit_profile'.tr),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        onProfileUpdated: () {
                          // Logique pour mettre à jour le profil
                        },
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text('share'.tr),
                onTap: _shareApp,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text('delete_account'.tr,
                    style: const TextStyle(color: Colors.red)),
                onTap: () => _showDeleteAccountDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.purple),
                title: const Text('Logout'),
                onTap: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    await prefs.setBool('ShowHome', false);
                    await FirebaseAuth.instance.signOut();
                    Get.offAll(() => const SplashScreen());
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('businesses').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No categories found.')),
          );
        }

        final Set<String> categories = {};
        for (var doc in snapshot.data!.docs) {
          final List<String> businessCategories =
              List<String>.from(doc['categories'] ?? []);
          categories.addAll(businessCategories);
        }

        final categoryList = categories.toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 3 / 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categoryList[index];
                final icon = categoryIcons[category] ?? Icons.category;
                final color = containerColors[index % containerColors.length];

                return GestureDetector(
                  onTap: () {
                    print("Selected category: $category");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage2(category: category),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: categoryList.length,
            ),
          ),
        );
      },
    );
  }
}
