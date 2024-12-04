import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pizzeria_app/firebase_options.dart';
import 'package:pizzeria_app/pages/account_page.dart';
import 'package:pizzeria_app/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'providers/cart_provider.dart';
import 'providers/category_provider.dart'; 
import 'pages/home_page.dart';
import 'pages/cart_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final categoryProvider = CategoryProvider();
  await categoryProvider.fetchCategories(); 

      WidgetsFlutterBinding.ensureInitialized();
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        setWindowTitle("Пиццерия Джоннис");
        setWindowMinSize(const Size(1900, 900));
      }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => categoryProvider), 
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Пиццерия Джоннис',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/account': (context) => const AccountPage(),
      },
    );
  }
}