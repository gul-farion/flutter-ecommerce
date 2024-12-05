import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/payment_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Корзина', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Ваша корзина пуста!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  
                  flex: 4,
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      final quantity = cart.getQuantity(item);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          ),
                          
                        ),
                        
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              item.imageUrl,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body, 
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.price.toStringAsFixed(2)} ₸',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: TextFormField(
  initialValue: quantity.toString(),
  textAlign: TextAlign.center,
  keyboardType: TextInputType.number,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly, // Разрешить только цифры
    FilteringTextInputFormatter.allow(RegExp(r'^([1-9]|1[0-5])$')), // Ограничение до 15
  ],
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
  ),
  onChanged: (value) {
    final newQuantity = int.tryParse(value) ?? 1;
    cart.updateItemQuantity(item, newQuantity);
  },
),

                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    cart.removeItem(item);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Обзор заказа',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final item = cart.items[index];
                              final quantity = cart.getQuantity(item);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '${(item.price * quantity).toStringAsFixed(2)} ₸',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Итого: ${cart.totalPrice.toStringAsFixed(2)} ₸',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Заказ успешно оформлен!'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12), 
                          ),
                          child: const Text(
                            'Оформить заказ',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
