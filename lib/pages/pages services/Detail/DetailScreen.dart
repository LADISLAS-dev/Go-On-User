import 'package:appointy/pages/pages%20services/Detail/product_detail_image.dart';
import 'package:appointy/pages/pages%20services/Detail/product_item_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appointy/pages/pages%20services/Model/data_model.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.product});

  final ProductModel product;

  // Fonction pour enregistrer la réservation dans Firestore
  void bookService(String userId) {
    FirebaseFirestore.instance.collection('bookings').add({
      'product': {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'localisation': product.localisation,
      },
      'userId': userId,
      'date': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image détaillée du produit avec un Hero pour une transition fluide
          ProductDetailImages(
            imageUrl: product.imageUrl,
            productId: product.id,
            productName: product.name,
            productData: {
              'id': product.id,
              'name': product.name,
              'price': product.price,
              'localisation': product.localisation,
            },
          ),

          // Détails du produit positionnés en bas de l'écran
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: ProductItemsDetail(product: product),
              ),
            ),
          ),

          // Bouton de retour en haut à gauche
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
