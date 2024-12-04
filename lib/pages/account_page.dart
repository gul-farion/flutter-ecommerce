import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> orderHistory = [];
  bool isLoading = true;
  String debugMessage = "";

  @override
  void initState() {
    super.initState();
    fetchOrderHistory();
  }

  Future<void> fetchOrderHistory() async {
    if (user == null) {
      setState(() {
        debugMessage = "No user logged in.";
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: user!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        orderHistory = snapshot.docs.map((doc) {
          return doc.data();
        }).toList();
        debugMessage =
            "Fetched ${orderHistory.length} orders for user ${user!.email}.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        debugMessage = "Error fetching order history: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мой аккаунт", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Section
                    _buildUserInfoCard(),

                    const SizedBox(height: 24),

                    // Order History Section
                    const Text(
                      "История заказов",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (orderHistory.isEmpty)
                      Center(
                        child: Text(
                          "У вас пока нет заказов.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderHistory.length,
                        itemBuilder: (context, index) {
                          final order = orderHistory[index];
                          return _buildOrderCard(order);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? "Неизвестный пользователь",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  user?.email ?? "-",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items = order['items'] as List<dynamic>;
    final totalPrice = order['totalPrice'] as num;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Заказ: ${order['createdAt']?.toDate().toLocal()}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              return Text(
                "- ${item['name']} x ${item['quantity']}",
                style: const TextStyle(fontSize: 14),
              );
            }),
            const SizedBox(height: 8),
            Text(
              "Общая сумма: ${totalPrice.toStringAsFixed(2)} ₸",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
