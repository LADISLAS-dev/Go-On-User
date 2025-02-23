import 'package:appointy/autres/service_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_add_service.dart';

class AdminServiceList extends StatelessWidget {
  const AdminServiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminAddService()),
              ),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('services').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator()); // Chargement en cours
            }

            if (snapshot.hasError) {
              print(
                  'Error: ${snapshot.error}'); // Affiche l'erreur dans la console
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                      'No services available')); // Aucune donnée disponible
            }

            final services = snapshot.data!.docs;
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ListTile(
                  title: Text(service['name']),
                  subtitle: Text('\$${service['price']}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceDetail(serviceId: service.id),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
