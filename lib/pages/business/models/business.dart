import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String imageUrl;
  final String logoUrl;
  final List<String> categories;
  final String manufacturer;
  final double rating;
  final String style;
  final String madeIn;
  final String ownerId;
  final DateTime createdAt;
  final String category; // New field
  final String location; // New field

  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.imageUrl,
    required this.logoUrl,
    required this.categories,
    required this.manufacturer,
    required this.rating,
    required this.style,
    required this.madeIn,
    required this.ownerId,
    required this.createdAt,
    required this.category, // New field
    required this.location, // New field
  });

  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Business(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      manufacturer: data['manufacturer'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      style: data['style'] ?? '',
      madeIn: data['madeIn'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '', // New field
      location: data['location'] ?? '', // New field
    );
  }

  // You can also add a factory constructor to create a Business instance from JSON
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      imageUrl: json['imageUrl'],
      logoUrl: json['logoUrl'],
      categories: List<String>.from(json['categories']),
      manufacturer: json['manufacturer'],
      rating: json['rating'],
      style: json['style'],
      madeIn: json['madeIn'],
      ownerId: json['ownerId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      category: json['category'], // New field
      location: json['location'], // New field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'categories': categories,
      'manufacturer': manufacturer,
      'rating': rating,
      'style': style,
      'madeIn': madeIn,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'category': category, // New field
      'location': location, // New field
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'categories': categories,
      'manufacturer': manufacturer,
      'rating': rating,
      'style': style,
      'madeIn': madeIn,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category, // New field
      'location': location, // New field
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? imageUrl,
    String? logoUrl,
    List<String>? categories,
    String? manufacturer,
    double? rating,
    String? style,
    String? madeIn,
    String? ownerId,
    DateTime? createdAt,
    String? category, // New field
    String? location, // New field
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      categories: categories ?? this.categories,
      manufacturer: manufacturer ?? this.manufacturer,
      rating: rating ?? this.rating,
      style: style ?? this.style,
      madeIn: madeIn ?? this.madeIn,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category, // New field
      location: location ?? this.location, // New field
    );
  }
}

Map<String, dynamic> jsonData = {
  "id": "1",
  "name": "Exemple Business",
  "description": "Description of the business",
  "address": "123 Main St",
  "phone": "123-456-7890",
  "imageUrl": "http://example.com/image.jpg",
  "logoUrl": "http://example.com/logo.jpg",
  "categories": ["Category1", "Category2"],
  "manufacturer": "Manufacturer Name",
  "rating": 4.5,
  "style": "Modern",
  "madeIn": "Country",
  "ownerId": "owner123",
  "createdAt": Timestamp.now(),
  "category": "Santé et Bien-être",
  "location": "Paris",
};

Business business = Business.fromJson(jsonData);
