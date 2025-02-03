import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/food_item.dart';
import 'food_card.dart';

class FoodGrid extends StatelessWidget {
  const FoodGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Список категорий
    final List<String> categories = [
      'Аяқ киім',
      'Киім',
      // 'Спортивный инвентарь',
      'Аксессуарлар',
      'Экипировка'
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((category) {
          return _buildCategorySection(context, category);
        }).toList(),
      ),
    );
  }

  // Построение секции для категории
  Widget _buildCategorySection(BuildContext context, String category) {
    final Stream<QuerySnapshot> categoryStream = FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .limit(4) // Ограничиваем до 4 элементов
        .snapshots();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Название секции
          Text(
            category,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Сетка товаров
          StreamBuilder<QuerySnapshot>(
            stream: categoryStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  "Бұл категорияда тауарлар жоқ.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                );
              }

              final products = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return FoodItem(
                  name: data['name'] as String,
                  body: data['body'] ?? '',
                  price: (data['price'] as num).toDouble(),
                  imageUrl: data['image'] as String,
                );
              }).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,  
                  childAspectRatio: 4 / 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  return FoodCard(
                    foodItem: product,
                    onTap: () {
                      _showFoodDetails(context, product, cartProvider);
                    },
                    onAddToBasket: () {
                      cartProvider.addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} себетке қосылды'),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // Кнопка перехода в каталог
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A78D6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Каталогты қарау',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

 void _showFoodDetails(BuildContext context, FoodItem foodItem, CartProvider cartProvider) {
  String? selectedSize;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: SizedBox(
              width: 500,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      foodItem.imageUrl,
                      fit: BoxFit.contain,
                      width: 250,
                      height: 250,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text(
                        //   foodItem.body,
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     // fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        if (foodItem.body.isNotEmpty)
                          Text(
                            foodItem.body,
                            style: const TextStyle(fontSize: 16),
                          ),
                        
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('products')
                              .where('name', isEqualTo: foodItem.name)
                              .get()
                              .then((snapshot) => snapshot.docs.first),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            
                            final data = snapshot.data?.data() as Map<String, dynamic>?;
                            final List<dynamic> sizes = data?['vars'] ?? [];
                            
                            return sizes.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: sizes.map((size) => 
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedSize = size.toString();
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: selectedSize == size.toString() 
                                              ? const Color(0xFF0A78D6) 
                                              : Colors.grey[200],
                                            foregroundColor: selectedSize == size.toString() 
                                              ? Colors.white 
                                              : Colors.black,
                                            minimumSize: const Size(40, 40),
                                          ),
                                          child: Text(size.toString()),
                                        )
                                      ).toList(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'Баға: ${foodItem.price.toStringAsFixed(2)} ₸',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            final itemToAdd = FoodItem(
                              name: foodItem.name,
                              body: foodItem.body,
                              price: foodItem.price,
                              imageUrl: foodItem.imageUrl,
                              selectedSize: selectedSize,
                            );

                            cartProvider.addItem(itemToAdd);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${foodItem.name} себетке қосылды'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A78D6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                          child: const Text(
                            'Себетке қосу',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

}
