import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTab;
  final String text;

  const MyButton({
    super.key,
    required this.onTab,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTab,
      borderRadius:
          BorderRadius.circular(30), // Ajout d'un effet visuel au clic
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 20), // Ajout d'un espacement extérieur
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: const Color(0xFF9C27B0),
        ),
        child: Text(
          text.isNotEmpty ? text : "Button", // Vérification de texte vide
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
