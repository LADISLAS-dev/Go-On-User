import 'package:appointy/pages/pages%20services/Model/data_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductItemsDetail extends StatelessWidget {
  final ProductModel product;

  const ProductItemsDetail({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductHeader(),
        const SizedBox(height: 20),
        _buildRatingRow(),
        const SizedBox(height: 20),
        _buildAttributesRow(),
        const SizedBox(height: 20),
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () => bookService(
            context,
            product.id,
            'user123', // Remplacer par l'ID de l'utilisateur actuel
            product.localisation,
          ),
          child: const Text(
            'Réserver',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.manufacturer,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Text(
          '\$${product.price}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 5),
        Text(
          '${product.rating}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 20),
        Text(
          '(${product.reviews} reviews)',
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAttributesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildAttributeColumn('Style', product.style),
        _buildAttributeColumn('Made In', product.madeIn),
        _buildAttributeColumn('Location', product.localisation),
      ],
    );
  }

  Widget _buildAttributeColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void bookService(BuildContext context, String serviceId, String userId,
      String localisation) {
    FirebaseFirestore.instance.collection('bookings').add({
      'serviceId': serviceId,
      'userId': userId,
      'localisation': localisation,
      'date': DateTime.now(),
      'status': 'pending',
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation effectuée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la réservation: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}
