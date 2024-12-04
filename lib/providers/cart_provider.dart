import 'package:flutter/material.dart';
import '../models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<FoodItem, int> _items = {}; // Хранение уникальных товаров с количеством.

  // Получить все товары корзины.
  List<FoodItem> get items => _items.keys.toList();

  // Получить общее количество определённого товара.
  int getQuantity(FoodItem item) => _items[item] ?? 0;

  // Получить общую стоимость.
  double get totalPrice {
    return _items.entries
        .map((entry) => entry.key.price * entry.value)
        .fold(0.0, (sum, item) => sum + item);
  }

  // Добавить товар в корзину.
  void addItem(FoodItem item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
  }

  // Уменьшить количество товара или удалить его.
  void removeSingleItem(FoodItem item) {
    if (_items.containsKey(item)) {
      if (_items[item]! > 1) {
        _items[item] = _items[item]! - 1;
      } else {
        _items.remove(item);
      }
    }
    notifyListeners();
  }

  // Очистить корзину.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
