import 'package:flutter/material.dart';
import '../models/food_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<FoodItem, int> _items = {}; // Хранение предметов и их количества

  // Получение списка всех предметов в корзине
  List<FoodItem> get items => _items.keys.toList();

  // Получение количества конкретного предмета
  int getQuantity(FoodItem item) => _items[item] ?? 0;

  // Расчет общей стоимости корзины
  double get totalPrice {
    return _items.entries
        .map((entry) => entry.key.price * entry.value)
        .fold(0.0, (sum, item) => sum + item);
  }

  // Добавление предмета в корзину
  void addItem(FoodItem item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
  }

  // Удаление одного экземпляра предмета
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

  // Удаление предмета полностью
  void removeItem(FoodItem item) {
    if (_items.containsKey(item)) {
      _items.remove(item);
      notifyListeners();
    }
  }

  // Обновление количества конкретного предмета
  void updateItemQuantity(FoodItem item, int quantity) {
    if (quantity <= 0) {
      removeItem(item); // Удаление предмета, если количество меньше или равно 0
    } else {
      _items[item] = quantity;
    }
    notifyListeners();
  }

  // Проверка, находится ли предмет в корзине
  bool hasItem(FoodItem item) => _items.containsKey(item);

  // Подсчет общего количества предметов в корзине
  int get itemCount {
    return _items.values.fold(0, (sum, quantity) => sum + quantity);
  }

  // Очистка всей корзины
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
