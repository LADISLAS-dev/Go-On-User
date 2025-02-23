import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  const MySearchBar({super.key});

  @override
  State<MySearchBar> createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            fillColor: Colors.white,
            hintText: "Search...",
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black26,
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 25,
              color: Colors.black26,
            ),
          ),
        ),
      ),
    );
  }
}
