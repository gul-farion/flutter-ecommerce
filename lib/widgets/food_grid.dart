import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import 'food_card.dart';

class FoodGrid extends StatelessWidget {
  final List<FoodItem> foodItems; 
  final bool isLoading;
  final String debugMessage;

  const FoodGrid({
    super.key,
    required this.foodItems,
    required this.isLoading,
    required this.debugMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (foodItems.isEmpty) {
      return Center(
        child: Text(
          "Ошибка с запросом: $debugMessage",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 4 / 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final foodItem = foodItems[index];
        return FoodCard(
          foodItem: foodItem,
          onTap: () {
            _showFoodDetails(context, foodItem, cartProvider);
          },
          onAddToBasket: () {
            cartProvider.addItem(foodItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${foodItem.name} добавлен в корзину')),
            );
          },
        );
      },
    );
  }

  void _showFoodDetails(
    BuildContext context,
    FoodItem foodItem,
    CartProvider cartProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Image.network(
                    foodItem.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                foodItem.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (foodItem.body.isNotEmpty)
                Text(
                  foodItem.body,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              Text(
                '${foodItem.price.toStringAsFixed(2)} ₸',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  cartProvider.addItem(foodItem); 
                  Navigator.of(context).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${foodItem.name} добавлен в корзину')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
                child: const Text(
                  'Добавить в корзину',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
