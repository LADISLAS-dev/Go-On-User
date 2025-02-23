import 'package:flutter/material.dart';
import 'package:appointy/pages/business/carousel_page1.dart';

class BusinessCarousel extends StatelessWidget {
  final String businessId;
  final List<String> carouselImages;
  final Future<void> Function(String) onDeleteImage;
  final Future<void> Function()? onAddImage;

  const BusinessCarousel({
    super.key,
    required this.businessId,
    required this.carouselImages,
    required this.onDeleteImage,
    required this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        height: 270,
        child: CarouselPage1(
          businessId: businessId,
          carouselImages: carouselImages,
          onDeleteImage: onDeleteImage,
          onAddImage: onAddImage,
        ),
      ),
    );
  }
}
