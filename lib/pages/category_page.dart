import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../widgets/food_card.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    final Stream<QuerySnapshot> categoryStream = FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: categoryName)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Color(0xff0A78D6),
        title: Text(categoryName,
            style: const TextStyle(color: Colors.white, fontSize: 20)
        ),
        actions: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
            ),
            Text(
              "${cartProvider.totalPrice.toStringAsFixed(2)} ₸",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoryStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Бұл категорияда әзір тауарлар жоқ",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            
            padding: const EdgeInsets.all(28.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final foodItem = FoodItem(
                name: product['name'],
                body: product['body'] ?? '',
                price: (product['price'] as num).toDouble(),
                imageUrl: product['image'],
              );

              return FoodCard(
                foodItem: foodItem,
                onTap: () {
                  _showProductDetails(context, foodItem, cartProvider);
                },
                onAddToBasket: () {
                  cartProvider.addItem(foodItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${foodItem.name} себетке қосылды'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDetails(BuildContext context, FoodItem foodItem, CartProvider cartProvider) {
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
                            // Create a new FoodItem with selected size
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
                                content: Text('${foodItem.name} добавлен в корзину'),
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
