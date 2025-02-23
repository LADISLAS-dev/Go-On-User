import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/service.dart';

class EditServicePage extends StatefulWidget {
  final Service service;

  const EditServicePage({super.key, required this.service});

  @override
  _EditServicePageState createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  String currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController =
        TextEditingController(text: widget.service.description);
    _priceController =
        TextEditingController(text: widget.service.price.toString());
    _imageUrlController = TextEditingController();
    currentImageUrl = widget.service.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le service'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveService,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: currentImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          currentImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 50),
                        ),
                      )
                    : const Icon(Icons.add_photo_alternate, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom du service'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Changer par URL'),
            onTap: () {
              Navigator.pop(context);
              _changeImageByUrl();
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Choisir une image locale'),
            onTap: () {
              Navigator.pop(context);
              _changeImageLocally();
            },
          ),
          if (currentImageUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer l\'image',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                setState(() => currentImageUrl = '');
              },
            ),
        ],
      ),
    );
  }

  Future<void> _changeImageByUrl() async {
    _imageUrlController.text = currentImageUrl;
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrer l\'URL de l\'image'),
        content: TextField(controller: _imageUrlController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _imageUrlController.text),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() => currentImageUrl = url);
    }
  }

  Future<void> _changeImageLocally() async {
    // Implémentez ici la logique pour sélectionner une image locale
    // et l'uploader vers Firebase Storage
  }

  Future<void> _saveService() async {
    try {
      await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.service.id)
          .update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'photoUrl': currentImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service modifié avec succès')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
