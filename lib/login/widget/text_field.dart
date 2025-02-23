import 'package:flutter/material.dart';

class TextFieldInpute extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isObscure; // Renommé pour cohérence
  final String hintText;
  final IconData icon;

  const TextFieldInpute({
    super.key,
    required this.textEditingController,
    this.isObscure = false, // Valeur par défaut définie ici
    required this.hintText,
    required this.icon, required Null Function(String password) onChanged, required Null Function(dynamic hasFocus) onFocusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        obscureText: isObscure, // Correction ici
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 18,
          ),
          prefixIcon: Icon(icon, color: Colors.black45),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: InputBorder.none,
          filled: true,
          fillColor: const Color(0xffedf0f8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.blue),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
