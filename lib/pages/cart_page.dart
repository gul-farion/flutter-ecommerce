import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/payment_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Себет',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff0A78D6),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Себетіңіз бос!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            )
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff0A78D6), Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          final quantity = cart.getQuantity(item);

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (item.selectedSize != null)
                                          Text(
                                            'Өлшемі: ${item.selectedSize}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.body,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${item.price.toStringAsFixed(2)} ₸',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xff0A78D6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove,
                                              color: Colors.red,
                                            ),
                                            onPressed: quantity > 1
                                                ? () {
                                                    cart.updateItemQuantity(
                                                        item, quantity - 1);
                                                  }
                                                : null,
                                          ),
                                          Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.green,
                                            ),
                                            onPressed: quantity < 15
                                                ? () {
                                                    cart.updateItemQuantity(
                                                        item, quantity + 1);
                                                  }
                                                : null,
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () {
                                          cart.removeItem(item);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildOrderSummary(context, cart),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Тапсырысқа шолу',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: cart.items.map((item) {
              final quantity = cart.getQuantity(item);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.name} x$quantity',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${(item.price * quantity).toStringAsFixed(2)} ₸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Divider(),
          Text(
            'Барлығы: ${cart.totalPrice.toStringAsFixed(2)} ₸',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0A78D6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: cart.totalPrice < 1000
                ? null
                : () => showDialog(
                      context: context,
                      builder: (context) => PaymentModal(
                        onOrderSuccess: () async {
                          await _saveOrderToFirestore(cart);
                          cart.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Тапсырыс жіберілді!'),
                            ),
                          );
                        },
                      ),
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0A78D6),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Тапсырыс ету',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveOrderToFirestore(CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      await orderRef.set({
        'userId': user?.uid,
        'items': cart.items
            .map((item) => {
                  'name': item.name,
                  'quantity': cart.getQuantity(item),
                  'price': item.price,
                })
            .toList(),
        'totalPrice': cart.totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Order saved successfully!");
    } catch (e) {
      print("Error saving order: $e");
    }
  }
}
