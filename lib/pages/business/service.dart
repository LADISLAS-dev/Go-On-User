import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String photoUrl;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.photoUrl,
    required this.createdAt,
  });

  // Optionnel : Ajoutez une méthode pour créer un objet Service à partir d'un document Firestore
  factory Service.fromFirestore(Map<String, dynamic> data) {
    return Service(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? 0.0,
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}