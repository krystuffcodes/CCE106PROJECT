import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailC.dispose();
    _pwC.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Sign in the user
      final userCred = await _auth.signInWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _pwC.text.trim(),
      );

      final user = userCred.user;
      if (user == null) {
        setState(() {
          _errorMessage = 'Login failed: user not found.';
        });
        return;
      }

      // Fetch Firestore user data (document ID must match the UID)
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        setState(() {
          _errorMessage =
              'No Firestore data found for this account. Contact administrator.';
        });
        return;
      }

      final data = doc.data();
      print('📄 Firestore data: $data'); // For debugging

      if (data == null || !data.containsKey('role')) {
        setState(() {
          _errorMessage = 'No role found. Please contact administrator.';
        });
        return;
      }

      final role = (data['role'] ?? '').toString().toLowerCase();

      // Navigate based on role
      if (role == 'admin') {
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/admin', (route) => false);
      } else {
        if (!mounted) return;
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = "No account found for this email.";
        } else if (e.code == 'wrong-password') {
          _errorMessage = "Invalid password. Please try again.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "Invalid email format.";
        } else {
          _errorMessage = "Login failed. ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong. Please try again.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/backgroundclean.png', fit: BoxFit.cover),

          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', height: 160),
                  const SizedBox(height: 80),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email field
                          TextFormField(
                            controller: _emailC,
                            validator: (val) =>
                                val == null || val.isEmpty
                                    ? "Enter your email"
                                    : null,
                            decoration: const InputDecoration(
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.black87),
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Colors.black),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          // Password field
                          TextFormField(
                            controller: _pwC,
                            obscureText: _obscurePassword,
                            validator: (val) =>
                                val == null || val.isEmpty
                                    ? "Enter your password"
                                    : null,
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.black87),
                              hintText: 'Password',
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black54,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 18),

                          // Error message
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, top: 4),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFb71c1c),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Register link
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              "Don't have an account? Register",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
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
