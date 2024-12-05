import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final List<String> categories;
  final String? activeCategory;
  final Function(String) onCategorySelect;
  final double width;

  const Sidebar({
    super.key,
    required this.categories,
    required this.activeCategory,
    required this.onCategorySelect,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: const Color.fromARGB(255, 0, 0, 0),
      
      child: ListView.builder(
        itemCount: categories.length,
        
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category == activeCategory;

          return GestureDetector(
            onTap: () => onCategorySelect(category),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: isActive ? Colors.white : Colors.transparent,
              alignment: Alignment.center,
              child: Text(
                
                category,
                style: TextStyle(
                  
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
