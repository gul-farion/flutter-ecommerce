import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class CategoryProvider extends ChangeNotifier {
  List<String> categories = [];
  String? activeCategory;
  List<FoodItem> foodItems = [];
  bool isLoading = false;
  String debugMessage = "";

  Future<void> fetchAllFoodItems() async {
  try {
    isLoading = true;
    debugMessage = "Загрузка всех товаров...";
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance.collection('products').get();

    foodItems = snapshot.docs.map((doc) {
      return FoodItem(
        name: doc['name'] as String,
        body: doc['body'] ?? '',
        price: (doc['price'] as num).toDouble(),
        imageUrl: doc['imageUrl'] as String,
      );
    }).toList();

    debugMessage = "Fetched ${foodItems.length} items.";
    notifyListeners();
  } catch (e) {
    debugMessage = "Error fetching items: $e";
    foodItems = [];
    notifyListeners();
  } finally {
    isLoading = false;
    notifyListeners();
  }
}


  Future<void> fetchCategories() async {
    try {
      debugMessage = "Fetching categories...";
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

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

  Future<void> fetchFoodItems([String? category]) async {
  try {
    isLoading = true;
    debugMessage = category == null
        ? "Fetching all products..."
        : "Fetching products for category: $category...";
    notifyListeners();

    // Формируем запрос
    Query query = FirebaseFirestore.instance.collection('products');
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();

    // Если данные пустые
    if (snapshot.docs.isEmpty) {
      debugMessage = category == null
          ? "No products found in 'products' collection."
          : "No products found for category: $category.";
      foodItems = [];
      notifyListeners();
      return;
    }

    // Преобразуем документы в FoodItem
    foodItems = snapshot.docs.map((doc) {
      debugPrint("Document data: ${doc.data()}");
      return FoodItem(
        name: doc['name'] as String,
        body: doc['body'] ?? '',
        price: (doc['price'] as num).toDouble(),
        imageUrl: doc['image'] as String,
      );
    }).toList();

    debugMessage = category == null
        ? "Fetched ${foodItems.length} products."
        : "Fetched ${foodItems.length} products for category: $category.";
    notifyListeners();
  } catch (e) {
    debugMessage = "Error fetching products: $e";
    foodItems = [];
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
