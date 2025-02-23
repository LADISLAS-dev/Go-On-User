import 'package:appointy/pages/sous_pages/admin/AdminPanelPage.dart';
import 'package:appointy/pages/sous_pages/admin/ModifyProductPage.dart';
import 'package:appointy/pages/sous_pages/admin/ProductListPage.dart';
import 'package:flutter/material.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminPanelPage()),
                  );
                },
                child: const Text("Add a Service"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductListPage()),
                  );
                },
                child: const Text("Modif or delate"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ModifyProductPage(
                              productId: 'id',
                            )),
                  );
                },
                child: const Text("Admin Panel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
