import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController photoUrlController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void addService() {
    String? finalPhotoUrl;

    // Priorité à l'URL si elle est renseignée
    if (photoUrlController.text.isNotEmpty) {
      finalPhotoUrl = photoUrlController.text;
    } else if (selectedImage != null) {
      finalPhotoUrl =
          selectedImage!.path; // Utilise le chemin local pour la photo
    }

    if (finalPhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Veuillez fournir une URL ou sélectionner une image.")),
      );
      return;
    }

    FirebaseFirestore.instance.collection('services').add({
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'photoUrl': finalPhotoUrl,
      'location': locationController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service ajouté avec succès!")),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $error")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un Service")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom")),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Prix")),
            TextField(
                controller: photoUrlController,
                decoration: const InputDecoration(labelText: "Photo URL")),
            TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Localisation")),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImage == null
                    ? const Center(
                        child: Text("Cliquez pour ajouter une image"))
                    : Image.file(selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addService,
              child: const Text("Ajouter le service"),
            ),
          ],
        ),
      ),
    );
  }
}
