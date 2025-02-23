import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final String photoUrl;
  final double price;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.price,
    required this.createdAt,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Service(
      id: doc.id,
      businessId: data['businessId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'price': price,
      'createdAt': createdAt,
    };
  }
}
