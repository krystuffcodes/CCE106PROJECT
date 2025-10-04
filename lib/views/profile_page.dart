// lib/views/profile_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_page.dart';
import 'my_reported_items_page.dart';
import 'login_page.dart'; // For logout redirection

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _email;
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // ✅ Load the saved user info from SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString("email") ?? "No email found";
      _name = prefs.getString("name") ?? "Unknown User";
    });
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // clear saved user data
              if (!context.mounted) return;

              Navigator.of(ctx).pop(); // close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFb71c1c),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _email == null
          ? const Center(child: CircularProgressIndicator()) // loading state
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 👤 Profile Picture
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/profile.jpg"),
                  ),
                  const SizedBox(height: 12),

                  // 🧑 Dynamic Name
                  Text(
                    _name ?? "User",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 📧 Dynamic Email
                  Text(
                    _email ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // ⚙️ Settings
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text("Settings"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage()),
                      );
                    },
                  ),

                  // 📦 My Reports
                  ListTile(
                    leading: const Icon(Icons.list, color: Colors.black),
                    title: const Text("My Reported Items"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyReportedItemsPage()),
                      );
                    },
                  ),

                  const Spacer(),

                  // 🚪 Logout
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb71c1c),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
    );
  }
}
