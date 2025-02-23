import 'dart:io';
import 'package:appointy/pages/business/models/business.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage({super.key, required String businessId});

  @override
  _CreateBusinessPageState createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _styleController = TextEditingController();
  final _madeInController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final List<String> _categories = [];
  final List<String> _predefinedCategories = [
    'Food and Beverages',
    'Art and Entertainment',
    'Health and Wellness',
    'Fashion and Beauty',
    'Technology and IT',
    'Commerce and Retail',
    'Professional Services',
    'Real Estate and Construction',
    'Education and Training',
    'Transport and Logistics',
    'Events',
    'Media and Communication',
    'Agriculture and Agro-industry',
    'Tourism and Leisure',
    'Energy and Environment',
  ];

  XFile? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _manufacturerController.dispose();
    _styleController.dispose();
    _madeInController.dispose();
    _logoUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<String> _uploadImage(String businessId) async {
    if (_imageFile == null) return '';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('businesses')
        .child('$businessId.jpg');

    try {
      final File imageFile = File(_imageFile!.path);
      await storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'businessId': businessId},
        ),
      );
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  void _addCategory(String category) {
    if (category.isNotEmpty && !_categories.contains(category)) {
      setState(() {
        _categories.add(category.trim());
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
  }

  Future<void> _createBusiness() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('businesses').doc();
      String imageUrl = '';

      if (_imageFile != null) {
        imageUrl = await _uploadImage(docRef.id);
      } else if (_imageUrlController.text.isNotEmpty) {
        imageUrl = _imageUrlController.text.trim();
      }

      // Create the Business object
      final business = Business(
        id: docRef.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        imageUrl: imageUrl,
        logoUrl: '',
        categories: _categories,
        manufacturer: _manufacturerController.text.trim(),
        rating: 0.0,
        style: _styleController.text.trim(),
        madeIn: _madeInController.text.trim(),
        ownerId: FirebaseAuth.instance.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
        category: '',
        location: '',
      );

      // Save to Firestore with a transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(docRef, business.toFirestore());
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business created successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating business: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildCategoriesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_categories.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories
                    .map((category) => Chip(
                          label: Text(category),
                          onDeleted: () => _removeCategory(category),
                          backgroundColor: Colors.blue[100],
                          deleteIconColor: Colors.blue[900],
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Add a category'),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _predefinedCategories
                      .map((category) => FilterChip(
                            label: Text(category),
                            selected: _categories.contains(category),
                            onSelected: (bool selected) {
                              if (selected) {
                                _addCategory(category);
                              } else {
                                _removeCategory(category);
                              }
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Add a custom category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.add_circle_outline),
                hintText: 'Enter a new category',
              ),
              onFieldSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addCategory(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Create a Business',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
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
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Add image'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose image'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.link),
                                  title: const Text('Add link'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Add an image link'),
                                        content: TextField(
                                          controller: _imageUrlController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter the image URL',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _imageFile = null;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Confirm'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey[400]!, width: 1),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(File(_imageFile!.path),
                                    fit: BoxFit.cover),
                              )
                            : _imageUrlController.text.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Text('Error loading image'),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add an image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _styleController,
                      decoration: InputDecoration(
                        labelText: 'Style',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.style),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _madeInController,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoriesSection(),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: ElevatedButton(
                        onPressed: _createBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Create Business',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
