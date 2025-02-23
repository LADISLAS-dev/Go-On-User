import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifyProductPage extends StatefulWidget {
  final String productId;
  const ModifyProductPage({super.key, required this.productId});

  @override
  State<ModifyProductPage> createState() => _ModifyProductPageState();
}

class _ModifyProductPageState extends State<ModifyProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController photoUrlController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    // Dispose les contrôleurs pour libérer les ressources.
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    photoUrlController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _loadProductData() async {
    try {
      final productDoc = await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        final productData = productDoc.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = productData['name'] ?? '';
          descriptionController.text = productData['description'] ?? '';
          priceController.text = productData['price']?.toString() ?? '';
          photoUrlController.text = productData['photoUrl'] ?? '';
          locationController.text = productData['location'] ?? '';
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des données : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des données')),
      );
    }
  }

  void _updateProduct() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final price = priceController.text.trim();
    final photoUrl = photoUrlController.text.trim();
    final location = locationController.text.trim();

    if (name.isNotEmpty && price.isNotEmpty && photoUrl.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.productId)
            .update({
          'name': name,
          'description': description,
          'price':
              double.tryParse(price) ?? 0, // Conversion en double pour les prix
          'photoUrl': photoUrl,
          'location': location,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit mis à jour avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        print("Erreur lors de la mise à jour : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier Produit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom du produit'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: photoUrlController,
                decoration: const InputDecoration(labelText: 'URL de l\'image'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localisation'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: const Text('Mettre à jour le produit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
