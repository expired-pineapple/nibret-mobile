import 'package:flutter/material.dart';

class CategorySlider extends StatelessWidget {
  final List<Map<String, String>> categories;

  const CategorySlider({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Fixed height for the slider
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Using Icons for demonstration
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(
                    Icons.category, // Replace with appropriate icons
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  categories[index]['title'] ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
