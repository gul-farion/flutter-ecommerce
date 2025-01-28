import 'package:flutter/material.dart';
import 'package:pizzeria_app/widgets/topbar.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../widgets/food_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      categoryProvider.fetchFoodItems(); // Загружаем все продукты
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: const Topbar(),
      drawer: const AppDrawer(),
      body: FoodGrid(
        // foodItems: categoryProvider.foodItems,
        // isLoading: categoryProvider.isLoading,
        // debugMessage: categoryProvider.debugMessage,
      ),
    );
  }
}
