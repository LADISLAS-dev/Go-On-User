import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List Page')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun produit disponible."));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productData =
                  products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;

              return ListTile(
                leading: productData['photoUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          productData['photoUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
                title: Text(productData['name'] ?? ''),
                subtitle: Text('Prix: ${productData['price'] ?? "N/A"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateProductPage(productId: productId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Supprimer ce produit ?'),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer ce produit ?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false); // Annuler
                                  },
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true); // Confirmer
                                  },
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != null && confirm) {
                          FirebaseFirestore.instance
                              .collection('services')
                              .doc(productId)
                              .delete()
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Produit supprimé !')),
                            );
                          }).catchError((e) {
                            print(
                                "Erreur lors de la suppression du produit: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Erreur lors de la suppression')),
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UpdateProductPage extends StatefulWidget {
  final String productId;
  const UpdateProductPage({super.key, required this.productId});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  File? _localImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
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
          locationController.text = productData['location'] ?? '';
          _currentImageUrl = productData['photoUrl'];
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des données : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des données')),
      );
    }
  }

  Future<void> _pickLocalImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _localImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }

  void _updateProduct() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final price = priceController.text.trim();
    final location = locationController.text.trim();

    if (name.isNotEmpty && price.isNotEmpty) {
      try {
        String? newImageUrl = _currentImageUrl;

        if (_localImage != null) {
          newImageUrl = 'local_image_placeholder_url/${_localImage!.path}';
        }

        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.productId)
            .update({
          'name': name,
          'description': description,
          'price': double.tryParse(price) ?? 0,
          'location': location,
          'photoUrl': newImageUrl,
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
              if (_currentImageUrl != null && _localImage == null)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _currentImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Erreur lors du chargement de l\'image',
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (_localImage != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _localImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localisation'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickLocalImage,
                child: const Text('Choisir une image locale'),
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
