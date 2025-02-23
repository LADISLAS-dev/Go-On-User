import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceDetail extends StatelessWidget {
  final String serviceId;
  const ServiceDetail({super.key, required this.serviceId});

  void bookService(String userId) {
    FirebaseFirestore.instance.collection('bookings').add({
      'serviceId': serviceId,
      'userId': userId,
      'date': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service Detail")),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('services')
            .doc(serviceId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final service = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                service['photoUrl'] != null
                    ? Image.network(service['photoUrl'])
                    : const Icon(Icons.image),
                Text(service['name'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(service['description']),
                const SizedBox(height: 10),
                Text('Location: ${service['location']}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    bookService('currentUserId'); // Replace with current user ID
                    Navigator.pop(context);
                  },
                  child: const Text("Book Now"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
