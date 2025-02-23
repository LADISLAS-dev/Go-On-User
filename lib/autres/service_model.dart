import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String photoUrl; // URL de la photo
  final String location; // Localisation

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.photoUrl, // URL de la photo
    required this.location, // Localisation
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'photoUrl': photoUrl, // URL de la photo
      'location': location, // Localisation
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? 'default_id', // Valeur par défaut si elle est absente
      name: map['name'] ??
          'Default Service Name', // Valeur par défaut si elle est absente
      description: map['description'] ??
          'No description available', // Valeur par défaut si elle est absente
      price: map['price'] ?? 0.0, // Valeur par défaut si elle est absente
      photoUrl: map['photoUrl'] ??
          'https://example.com/default_image.png', // URL par défaut si elle est absente
      location: map['location'] ??
          'Unknown location', // Localisation par défaut si elle est absente
    );
  }

  static fromFirestore(QueryDocumentSnapshot<Object?> servic) {}
}

class Booking {
  final String id;
  final String serviceId;
  final String userId;
  final DateTime date;
  final String serviceName; // Nom du service
  final String servicePhotoUrl; // URL de la photo du service
  final String serviceLocation; // Localisation du service

  Booking({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.date,
    required this.serviceName, // Nom du service
    required this.servicePhotoUrl, // URL de la photo du service
    required this.serviceLocation, // Localisation du service
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'userId': userId,
      'date': date.toIso8601String(),
      'serviceName': serviceName, // Nom du service
      'servicePhotoUrl': servicePhotoUrl, // URL de la photo du service
      'serviceLocation': serviceLocation, // Localisation du service
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] ?? 'default_booking_id', // Valeur par défaut
      serviceId: map['serviceId'] ?? 'default_service_id', // Valeur par défaut
      userId: map['userId'] ?? 'default_user_id', // Valeur par défaut
      date: DateTime.parse(map['date'] ??
          DateTime.now()
              .toIso8601String()), // Valeur par défaut (date actuelle)
      serviceName: map['serviceName'] ?? 'Unknown Service', // Valeur par défaut
      servicePhotoUrl: map['servicePhotoUrl'] ??
          'https://example.com/default_service_image.png', // URL par défaut
      serviceLocation:
          map['serviceLocation'] ?? 'Unknown Location', // Valeur par défaut
    );
  }
}
