import 'package:appointy/pages/business/business_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Assurez-vous d'importer correctement la page de détails

void main() => runApp(const CarouselPage1(
      businessId:
          'your_business_id', // Remplacez par l'ID réel de votre entreprise
      carouselImages: [],
      onDeleteImage: null,
      onAddImage: null,
    ));

class CarouselPage1 extends StatelessWidget {
  final String businessId;
  final List<String> carouselImages;
  final Future<void> Function(String imageUrl)? onDeleteImage;
  final Future<void> Function()? onAddImage;

  const CarouselPage1({
    super.key,
    required this.businessId,
    required this.carouselImages,
    required this.onDeleteImage,
    required this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CarouselExample(businessId: businessId),
        backgroundColor: const Color.fromARGB(255, 255, 240, 255), // Fond noir-gris
      ),
    );
  }
}

class CarouselExample extends StatefulWidget {
  final String businessId;

  const CarouselExample({super.key, required this.businessId});

  @override
  State<CarouselExample> createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  List<QueryDocumentSnapshot> businesses = [];
  final controller = CarouselController();

  Future<void> _loadBusinesses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('businesses').get();
      setState(() {
        businesses = snapshot.docs;
      });
    } catch (e) {
      print('Erreur de chargement des entreprises : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // StreamBuilder pour récupérer les promotions depuis Firestore
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('promotions').snapshots(),
          builder: (context, snapshot) {
            final defaultImages = [
              {
                'imageUrl': 'images/11.png',
                'title': 'Votre Espace Publicitaire'
              },
              {
                'imageUrl': 'images/22.jpg',
                'title': 'Communication visuelle',
              },
              {
                'imageUrl': 'images/55.jpg',
                'title': 'Your space for promotions',
              },
            ];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final promotions =
                snapshot.hasData && snapshot.data!.docs.isNotEmpty
                    ? snapshot.data!.docs
                    : defaultImages;

            return CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.96,
                autoPlayAnimationDuration: const Duration(seconds: 2),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: promotions.map((data) {
                final imageUrl =
                    (data is Map<String, dynamic>) ? data['imageUrl'] : '';
                final title =
                    (data is Map<String, dynamic>) ? data['title'] : '';

                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl.isNotEmpty
                                ? Image.asset(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print(
                                          "Erreur de chargement de l'image: $error");
                                      return const Icon(Icons.image, size: 50);
                                    },
                                  )
                                : const Icon(Icons.image, size: 50),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 10),
        // Carrousel des entreprises
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 60),
          child: CarouselView.weighted(
            flexWeights: const <int>[
              1,
              2,
              3,
              2,
              1
            ], // Ajustez les poids si nécessaire
            consumeMaxWeight: false,
            children: List<Widget>.generate(businesses.length, (int index) {
              final business = businesses[index];
              final data = business.data() as Map<String, dynamic>?;
              final businessName = data?['name'] ?? 'Entreprise sans nom';
              final businessImageUrl = data?['imageUrl'];

              return GestureDetector(
                onTap: () {
                  // Ajoutez un print pour déboguer
                  print("Business ID tapped: ${business.id}");

                  // Lorsque l'entreprise est cliquée, naviguez vers la page de détails
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusinessPage(businessId: business.id),
                    ),
                  );
                },
                child: ColoredBox(
                  color: Colors.primaries[index % Colors.primaries.length]
                      .withOpacity(0.8),
                  child: SizedBox.expand(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Assurez-vous que le Row rétrécit pour s'adapter au contenu
                        children: [
                          // Image dans un cercle parfait
                          Container(
                            margin: const EdgeInsets.all(8.0),
                            width: 30, // Image légèrement plus grande
                            height:
                                30, // Même largeur et hauteur pour la forme circulaire
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromRGBO(156, 39, 176, 1),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: businessImageUrl != null &&
                                      businessImageUrl.isNotEmpty
                                  ? Image.network(
                                      businessImageUrl,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.business,
                                          size: 25, color: Colors.white),
                                    ),
                            ),
                          ),
                          // Utilisation du widget Flexible avec un ajustement lâche
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              businessName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow
                                  .ellipsis, // Truncate si trop long
                              maxLines:
                                  1, // Assurez-vous que le texte tient sur une ligne
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
