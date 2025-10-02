// lib/views/login_page.dart
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();

  @override
  void dispose() {
    _emailC.dispose();
    _pwC.dispose();
    super.dispose();
  }

  void _login() {
    // simple local login: navigate to home
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background image
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgroundclean.png', fit: BoxFit.cover),

          /// Align to push content up
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // logo
                  Image.asset('assets/logo.png', height: 180),
                  const SizedBox(height: 100),

                  // login box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailC,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email, color: Colors.black87), // ✅ force visible
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black), // ✅ input text visible
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pwC,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Colors.black87), // ✅ force visible
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFb71c1c),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Login',
                          style: TextStyle(
                          color: Colors.white,  
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,    ),
                          )
                        ),
                      ],
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
}
