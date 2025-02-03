import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pizzeria_app/firebase_options.dart';
import 'package:pizzeria_app/pages/account_page.dart';
import 'package:pizzeria_app/pages/category_page.dart';
import 'package:pizzeria_app/pages/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'providers/cart_provider.dart';
import 'providers/category_provider.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_window/desktop_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final categoryProvider = CategoryProvider();
  await categoryProvider.fetchCategories();
  await windowManager.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    setWindowTitle("SPORTMODA");
    WindowManager.instance.setMinimumSize(const Size(1700, 800));
    setWindowMaxSize(const Size(1440, 1200));
    setWindowMinSize(const Size(1440, 900));
    DesktopWindow.setWindowSize(Size(1440, 900));
    await DesktopWindow.setMinWindowSize(Size(1440, 900));
    DesktopWindow.setFullScreen(true);
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
      title: 'SPORTMODA',
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.white),
        fontFamily: 'Raleway',
        listTileTheme: const ListTileThemeData(
          iconColor: Colors.white
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),   
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/account': (context) => const AccountPage(),
        // '/category': (context) =>  CategoryPage(),
      },
    );
  }
}
