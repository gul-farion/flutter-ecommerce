import 'package:flutter/material.dart';
import 'package:pizzeria_app/pages/category_page.dart';
import 'package:pizzeria_app/pages/products_page.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'delivery_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  const Topbar({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return AppBar(
      backgroundColor: const Color(0xff0A78D6),
      title: Image.network(
        'https://www.sportmoda.ru/upload/CMax/b1c/b1cd13d45d961856478987564a4c93a2.png',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // Список категорий
   List<String> categories = [];
  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();

      setState(() {
        categories = querySnapshot.docs
            .map((doc) => doc['title'] as String)
            .toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
      // Optionally show an error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить категории')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xff0A78D6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.email ?? "Қонақ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user != null
                                  ? "Қош келдіңіз!"
                                  : "Аккаунтка кіру",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/account');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text("Профильға кіру"),
                  ),
                ),
              ],
            ),
          ),

          // Категории товаров
          ExpansionTile(
            leading: const Icon(Icons.shopping_cart_checkout_outlined,
                color: Colors.black),
            title: const Text(
              "Категориялар",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: categories
                .map(
                  (category) => ListTile(
                    contentPadding: const EdgeInsets.only(left: 52),
                    title: Text(category),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategoryPage(categoryName: category),
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
          ListTile(
            leading: const Icon(Icons.location_pin, color: Colors.black),
            title: const Text("Біздің адрестеріміз"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const DeliveryModal(),
              );
            },
          ),

          // Управление товарами (показывается только для зарегистрированных пользователей)
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                return const SizedBox(); // Не отображать, если пользователь не вошел
              }
              return ListTile(
                leading:
                    const Icon(Icons.admin_panel_settings, color: Colors.black),
                title: const Text("Тауарлармен жұмыс"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPage(),
                    ),
                  );
                },
              );
            },
          ),

          const Divider(),

          // Вход или выход из аккаунта
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                return ListTile(
                  leading: const Icon(Icons.login, color: Colors.black),
                  title: const Text("Аккаунтқа кіру"),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                );
              }
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.black),
                title: const Text("Шығу"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Сіз аккаунтыңыздан шықтыңыз'),
                    ),
                  );
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

