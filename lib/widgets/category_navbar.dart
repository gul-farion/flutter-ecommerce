import 'package:flutter/material.dart';

class CategoryNavbar extends StatelessWidget {
  final List<Map<String, String>> categories;

  const CategoryNavbar({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                final targetKey = GlobalObjectKey(category['key']!);
                Scrollable.ensureVisible(
                  targetKey.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                category['title']!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
