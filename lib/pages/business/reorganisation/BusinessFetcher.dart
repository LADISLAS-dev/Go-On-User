import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusinessFetcher extends StatelessWidget {
  final String category;
  final String searchQuery;
  final Widget Function(BuildContext, QueryDocumentSnapshot) itemBuilder;

  const BusinessFetcher({
    super.key,
    required this.category,
    required this.searchQuery,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('businesses')
          .where('categories', arrayContains: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune entreprise trouvée pour $category.'));
        }

        final businesses = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name']?.toString().toLowerCase() ?? '';
          return name.contains(searchQuery);
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 5 / 5,
          ),
          itemCount: businesses.length,
          itemBuilder: (context, index) {
            return itemBuilder(context, businesses[index]);
          },
        );
      },
    );
  }
}