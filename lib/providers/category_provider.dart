// lib/providers/category_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class CategoryProvider extends ChangeNotifier {
  List<String> categories = [];
  String? activeCategory;
  List<FoodItem> foodItems = [];
  bool isLoading = false;
  String debugMessage = "";

  Future<void> fetchCategories() async {
    try {
      debugMessage = "Fetching categories...";
      notifyListeners();

      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      categories = snapshot.docs.map((doc) => doc['title'].toString()).toList();
      activeCategory = categories.isNotEmpty ? categories[0] : null;

      debugMessage = "Fetched ${categories.length} categories.";
      notifyListeners();

      if (activeCategory != null) {
        await fetchFoodItems(activeCategory!);
      }
    } catch (e) {
      debugMessage = "Error fetching categories: $e";
      notifyListeners();
    }
  }

Future<void> fetchFoodItems(String category) async {
  try {
    isLoading = true;
    debugMessage = "Fetching items for $category...";
    notifyListeners();

    // Map category titles to Firestore collection names
    final collectionMap = {
      'Пиццы': 'pizzas',
      'Комбо': 'combos',
      'Соусы': 'sauces',
      'Напитки': 'drinks',
      'Закуски': 'snacks',
      'Десерты': 'desserts',
    };

    final collectionName = collectionMap[category];
    if (collectionName == null) {
      debugMessage = "No matching collection for $category.";
      foodItems = []; // Clear items
      notifyListeners();
      return;
    }

    // Fetch documents from the collection
    final snapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    // Convert documents to FoodItem list
    foodItems = snapshot.docs.map((doc) {
      return FoodItem(
        name: doc['name'] as String,
        body: doc['body'] ?? '', // Handle missing 'body' field
        price: (doc['price'] as num).toDouble(),
        imageUrl: doc['imageUrl'] as String,
      );
    }).toList();

    debugMessage = "Fetched ${foodItems.length} items for $category.";
    notifyListeners();
  } catch (e) {
    debugMessage = "Error fetching food items: $e";
    foodItems = []; // Clear items on error
    notifyListeners();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  void setActiveCategory(String category) async {
    activeCategory = category;
    notifyListeners();
    await fetchFoodItems(category);
  }
}
