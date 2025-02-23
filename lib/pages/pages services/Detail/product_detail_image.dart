import 'package:flutter/material.dart';

class ProductDetailImages extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String imageUrl;
  final String productId;
  final String productName;

  const ProductDetailImages({
    super.key,
    required this.productData,
    required this.imageUrl,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
      ),
      body: Column(
        children: [
          Hero(
            tag: productId, // Utilisation de l'ID pour la transition Hero
            child: Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 50);
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              productData['description'] ?? 'Pas de description disponible',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
