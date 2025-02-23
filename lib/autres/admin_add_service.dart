import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddService extends StatelessWidget {
  const AdminAddService({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController photoUrlController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    void addService() {
      FirebaseFirestore.instance.collection('services').add({
        'name': nameController.text,
        'description': descriptionController.text,
        'price': double.parse(priceController.text),
        'photoUrl': photoUrlController.text, // Photo URL
        'location': locationController.text, // Location
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Add Service")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description")),
            TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price")),
            TextField(
                controller: photoUrlController,
                decoration: const InputDecoration(labelText: "Photo URL")),
            TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: "Location")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addService();
                Navigator.pop(context);
              },
              child: const Text("Add Service"),
            ),
          ],
        ),
      ),
    );
  }
}
