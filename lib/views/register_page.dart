import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _pwC = TextEditingController();
  final _confirmPwC = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _pwC.dispose();
    _confirmPwC.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // ✅ Create user with email & password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailC.text.trim(),
        password: _pwC.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) throw Exception("User not found after registration.");

      // ✅ Update FirebaseAuth profile
      await user.updateDisplayName(_nameC.text.trim());
      await user.reload();

      // ✅ Save user details to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameC.text.trim(),
        'email': _emailC.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ✅ Success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage = "This email is already registered.";
        } else if (e.code == 'invalid-email') {
          _errorMessage = "Invalid email format.";
        } else if (e.code == 'weak-password') {
          _errorMessage = "Password must be at least 6 characters.";
        } else {
          _errorMessage = "Registration failed: ${e.message}";
        }
      });
    } catch (e) {
      debugPrint("Registration error: $e");
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
          // 🖼️ Background
          Image.asset('assets/backgroundclean.png', fit: BoxFit.cover),

          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌿 Logo
                  Image.asset('assets/logo.png', height: 140),
                  const SizedBox(height: 60),

                  // 🧾 Registration Form
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 👤 Full Name
                          TextFormField(
                            controller: _nameC,
                            validator: (val) =>
                                val == null || val.isEmpty ? "Enter your name" : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person, color: Colors.black87),
                              hintText: 'Full Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 12),

                          // 📧 Email
                          TextFormField(
                            controller: _emailC,
                            validator: (val) => val == null || val.isEmpty
                                ? "Enter your email"
                                : null,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.black87),
                              hintText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 12),

                          // 🔒 Password
                          TextFormField(
                            controller: _pwC,
                            obscureText: _obscurePassword,
                            validator: (val) => val == null || val.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                              hintText: 'Password',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
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
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 12),

                          // ✅ Confirm Password
                          TextFormField(
                            controller: _confirmPwC,
                            obscureText: _obscureConfirm,
                            validator: (val) =>
                                val != _pwC.text ? "Passwords do not match" : null,
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.lock_outline, color: Colors.black87),
                              hintText: 'Confirm Password',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirm = !_obscureConfirm);
                                },
                              ),
                            ),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 18),

                          // ⚠️ Error Message
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, top: 4),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // 🔘 Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFb71c1c),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🔙 Go to Login
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Already have an account? Login",
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
