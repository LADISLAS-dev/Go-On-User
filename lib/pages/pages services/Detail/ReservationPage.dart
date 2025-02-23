import 'package:appointy/pages/pages%20services/Model/data_model.dart';
import 'package:flutter/material.dart';

class MoreInfoPage extends StatelessWidget {
  final ProductModel product;

  const MoreInfoPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plus d'informations"),
      ),
      body: Center(
        child: Text(
          "Plus d'informations sur : ${product.name}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
