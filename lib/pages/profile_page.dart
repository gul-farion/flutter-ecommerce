import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true; 
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0A78D6),
        title: const Text(
          'Авторизация',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),color: Colors.white,),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0a78d6), Color(0xFFffffff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child:
              isLoading ? const CircularProgressIndicator() : _buildAuthForm(),
        ),
      ),
    );
  }

  Widget _buildAuthForm() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.symmetric(horizontal: 560.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLogin ? "Кіру" : "Тіркелу",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Email Field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "example@mail.com",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Құпия сөз",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: isLogin ? _login : _register,
            style: ElevatedButton.styleFrom(
              // primary: const Color(0xFF4A148C),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isLogin ? "Кіру" : "Тіркелу",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              setState(() {
                isLogin = !isLogin;
              });
            },
            child: Text(
              isLogin
                  ? "Аккаунт жоқ? Тіркелу"
                  : "Аккаунт бар? Кіру",
              style: const TextStyle(color: Color(0xFF4A148C)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Барлық мәтін өрістерін толтырыңыз");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacementNamed(context, '/'); 
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Қате: ${e.message}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Барлық мәтін өрістерін толтырыңыз");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      _showSnackBar("Қате: ${e.message}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
