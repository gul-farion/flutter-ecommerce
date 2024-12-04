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
        title: const Text('Корзина'),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Ваша корзина пуста!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final quantity = cart.getQuantity(item);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name, style: const TextStyle(fontSize: 16)),
                    subtitle: Text(
                        '${item.price.toStringAsFixed(2)} ₸ x $quantity'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.black),
                          onPressed: () {
                            cart.removeSingleItem(item);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            cart.addItem(item);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Итого: ${cart.totalPrice.toStringAsFixed(2)} ₸',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
                                content: Text('Заказ успешно оформлен!'),
                              ),
                            );
                          },
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    cart.totalPrice < 1000 ? Colors.grey : Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Оформить заказ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrderToFirestore(CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();

      await orderRef.set({
        'userId': user?.uid,
        'items': cart.items.map((item) => {
              'name': item.name,
              'quantity': cart.getQuantity(item),
              'price': item.price,
            }).toList(),
        'totalPrice': cart.totalPrice,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Order saved successfully!");
    } catch (e) {
      print("Error saving order: $e");
    }
  }
}
