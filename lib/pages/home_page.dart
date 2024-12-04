import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/food_grid.dart';
import '../widgets/topbar.dart';
import '../widgets/footer.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const Topbar(),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Sidebar(
                  categories: categoryProvider.categories,
                  activeCategory: categoryProvider.activeCategory,
                  onCategorySelect: (category) {
                    categoryProvider.setActiveCategory(category);
                  },
                  width: screenWidth * 0.12,
                ),
                Expanded(
                  child: FoodGrid(
                    foodItems: categoryProvider.foodItems,
                    isLoading: categoryProvider.isLoading,
                    debugMessage: categoryProvider.debugMessage,
                  ),
                ),
              ],
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
