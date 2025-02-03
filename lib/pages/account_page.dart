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
        debugMessage = "Қолданушы кірілмеді.";
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
        title: const Text(
          "Менің аккаунтым",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xff0A78D6),
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
                    _buildUserInfoTile(),

                    const SizedBox(height: 24),

                    // Order History Section
                    const Text(
                      "Тапсырыстар тарихы",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (orderHistory.isEmpty)
                      Center(
                        child: Text(
                          "Сізде әзір тапсырыстар жоқ.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    else
                      _buildOrderHistoryTiles(),
                  ],
                ),
              ),
            ),
      backgroundColor: Color(0xff0a78d6),
    );
  }

  Widget _buildUserInfoTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        
        children: [
          Row(
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? "Қонақ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Статус: Қосулы",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Регистрация датасы: ${user?.metadata.creationTime?.toLocal().toString().split(' ')[0] ?? '-'}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryTiles() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orderHistory.length,
      itemBuilder: (context, index) {
        final order = orderHistory[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Заказ: ${order['createdAt']?.toDate().toLocal()}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: (order['items'] as List<dynamic>).map((item) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item['name']} x${item['quantity']}",
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        "${item['price']} ₸",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                "Барлығының суммасы: ${order['totalPrice'].toStringAsFixed(2)} ₸",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
