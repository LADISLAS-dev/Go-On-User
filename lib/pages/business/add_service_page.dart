import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddServicePage extends StatefulWidget {
  final String businessId;

  const AddServicePage({super.key, required this.businessId});

  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _useImageUrl = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _useImageUrl = false;
        _imageUrlController.clear();
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_useImageUrl && _imageUrlController.text.isNotEmpty) {
      return _imageUrlController.text;
    }

    if (_imageFile == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('services').child(
          '${widget.businessId}_${DateTime.now().millisecondsSinceEpoch}');

      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors du téléchargement de l\'image: $e')),
      );
      return null;
    }
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_useImageUrl && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Veuillez sélectionner une image ou fournir une URL')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrl = await _uploadImage();
      if (imageUrl == null) {
        throw Exception('Impossible d\'obtenir l\'URL de l\'image');
      }

      await FirebaseFirestore.instance.collection('services').add({
        'businessId': widget.businessId,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'photoUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service ajouté avec succès')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du service: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un service'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Image du service',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('Upload'),
                                    value: false,
                                    groupValue: _useImageUrl,
                                    onChanged: (value) {
                                      setState(() {
                                        _useImageUrl = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('URL'),
                                    value: true,
                                    groupValue: _useImageUrl,
                                    onChanged: (value) {
                                      setState(() {
                                        _useImageUrl = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_useImageUrl)
                              TextFormField(
                                controller: _imageUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'URL de l\'image',
                                  hintText: 'https://example.com/image.jpg',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (_useImageUrl) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer une URL';
                                    }
                                    final uri = Uri.tryParse(value);
                                    if (uri == null || !uri.hasAbsolutePath) {
                                      return 'Veuillez entrer une URL valide';
                                    }
                                  }
                                  return null;
                                },
                              )
                            else
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _imageFile != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Cliquez pour ajouter une image',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du service',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Prix',
                        border: OutlineInputBorder(),
                        prefixText: '€ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveService,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter le service'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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
