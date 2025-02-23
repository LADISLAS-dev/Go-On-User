import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant un produit
class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final String manufacturer;
  final String description;
  final String fabricColor;
  final int rating;
  final int reviews;
  final String style;
  final String madeIn;
  final String localisation;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.manufacturer,
    required this.description,
    required this.fabricColor,
    required this.rating,
    this.reviews = 0,
    required this.style,
    required this.madeIn,
    required this.localisation,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['photoUrl'] ?? '',
      price: data['price'] ?? 0,
      manufacturer: data['manufacturer'] ?? '',
      description: data['description'] ?? '',
      fabricColor: data['fabricColor'] ?? '',
      rating: data['rating'] ?? 0,
      reviews: data['reviews'] ?? 0,
      style: data['style'] ?? '',
      madeIn: data['madeIn'] ?? '',
      localisation: data['localisation'] ?? '',
    );
  }
}

/// Liste des produits disponibles
List<ProductModel> productItems = [
  ProductModel(
    id: '1', // Unique ID for this product
    name: 'Hanging Chair',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/hanging chair.png',
    price: 2222,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Japan',
    rating: 4,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '2', // Another unique ID
    name: 'Tune Sofa',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/Tune Sofa.png',
    price: 1695,
    fabricColor: 'Silver',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 5,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '3',
    name: 'EMKO Naive',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/EMKO Naive.png',
    price: 1111,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 3,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '4',
    name: 'Reform',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/Reform.png',
    price: 120,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 2,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '5',
    name: 'Ella Armchair',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/Ella Armchair.png',
    price: 1695,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 4,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '6',
    name: 'Wooden Chair',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/Wooden Chair.png',
    price: 1200,
    fabricColor: 'Wooden',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 9,
    reviews: 0,
    style: 'Classic',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '7',
    name: ' Naive',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/EMKO Naive.png',
    price: 1111,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 6,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '8',
    name: 'EMKO ',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/EMKO Naive.png',
    price: 1111,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 6,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '9',
    name: 'T Naive',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/EMKO Naive.png',
    price: 1111,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 6,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '10',
    name: 'Colon Naive',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/EMKO Naive.png',
    price: 1111,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 6,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  ProductModel(
    id: '11',
    name: 'Eko Naive',
    manufacturer: 'by Carl MH Barenbrug',
    imageUrl: 'images/EMKO Naive.png',
    price: 1111,
    fabricColor: 'White',
    description:
        'Sound absorption is a key concept in room acoustics, which may not often be considered in furniture design',
    madeIn: 'Russia',
    rating: 7,
    reviews: 0,
    style: 'Modern',
    localisation: '2101 Mayfield villa dr',
  ),
  // Add the rest similarly
];

/// Modèle représentant une réservation
class Booking {
  final String id;
  final String productId;
  final String userId;
  final DateTime date;
  final String localisation;

  Booking({
    required this.id,
    required this.productId,
    required this.userId,
    required this.date,
    required this.localisation,
  });

  /// Convertit une réservation en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'date': date.toIso8601String(),
      'localisation': localisation,
    };
  }

  /// Crée une instance de réservation à partir d'une Map Firestore
  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      productId: map['productId'] as String,
      userId: map['userId'] as String,
      date: DateTime.parse(map['date'] as String),
      localisation: map['localisation'] as String,
    );
  }
}

/// Récupère les catégories depuis Firestore
Future<List<String>> fetchCategories() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('categories').get();
  return snapshot.docs.map((doc) => doc['name'] as String).toList();
}
