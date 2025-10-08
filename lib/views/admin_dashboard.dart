import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedModule = 'Dashboard';
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  // 🔒 Verify if the current user is an admin
  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['isAdmin'] == true) {
        setState(() {
          _isAdmin = true;
          _loading = false;
        });
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access denied: Admins only')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFb71c1c),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),

      // 🧭 Sidebar Navigation
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFb71c1c)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Manage system operations',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Dashboard', Icons.dashboard),
            _buildDrawerItem('Item Management', Icons.inventory_2_outlined),
            _buildDrawerItem('User Management', Icons.people_outline),
            _buildDrawerItem('Claims', Icons.assignment_turned_in_outlined),
            _buildDrawerItem('Reports', Icons.bar_chart),
            _buildDrawerItem('Settings', Icons.settings),
          ],
        ),
      ),

      // 🧩 Main Content Area
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Padding(
          key: ValueKey(_selectedModule),
          padding: const EdgeInsets.all(16.0),
          child: _buildModuleContent(),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon) {
    final isSelected = _selectedModule == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFb71c1c) : Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFb71c1c) : Colors.black87,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() => _selectedModule = title);
      },
    );
  }

  Widget _buildModuleContent() {
    switch (_selectedModule) {
      case 'Item Management':
        return _buildItemManagement();
      case 'User Management':
        return _buildUserManagement();
      case 'Claims':
        return _buildClaims();
      case 'Reports':
        return _buildReports();
      case 'Settings':
        return _buildSettings();
      default:
        return _buildDashboardOverview();
    }
  }

  // 📊 Dashboard Overview
  Widget _buildDashboardOverview() {
    return FutureBuilder(
      future: Future.wait([
        FirebaseFirestore.instance.collection('items').get(),
        FirebaseFirestore.instance.collection('users').get(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final itemCount = snapshot.data![0].docs.length;
        final userCount = snapshot.data![1].docs.length;

        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard('Total Items', itemCount.toString(), Icons.inventory_2),
            _buildStatCard('Registered Users', userCount.toString(), Icons.people),
            _buildStatCard('Pending Claims', '3', Icons.assignment_late),
            _buildStatCard('Resolved Reports', '12', Icons.verified),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFb71c1c).withOpacity(0.1),
              radius: 28,
              child: Icon(icon, color: const Color(0xFFb71c1c), size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // 📦 Item Management
  Widget _buildItemManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final items = snapshot.data!.docs;

        return ListView(
          children: items.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(data['title'] ?? 'Unnamed Item'),
                subtitle: Text(data['description'] ?? 'No description'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    FirebaseFirestore.instance.collection('items').doc(doc.id).delete();
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 👥 User Management (with Promote to Admin)
  Widget _buildUserManagement() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;

        return ListView(
          children: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final bool isAdmin = data['isAdmin'] == true;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['email'] ?? 'No email'),
                subtitle: Text(isAdmin ? 'Admin' : 'User'),
                trailing: !isAdmin
                    ? TextButton(
                        child: const Text('Promote'),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(doc.id)
                              .update({'isAdmin': true});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User promoted to admin!')),
                          );
                        },
                      )
                    : const Icon(Icons.verified, color: Colors.green),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 📋 Claims Module
  Widget _buildClaims() {
    return const Center(
      child: Text('Claims Management — Coming Soon',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }

  // 📈 Reports Module
  Widget _buildReports() {
    return const Center(
      child: Text('Reports Module — Coming Soon',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }

  // ⚙️ Settings (Add new admin manually)
  Widget _buildSettings() {
    final TextEditingController emailController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Admin Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'User Email to Promote',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Promote to Admin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFb71c1c),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              final query = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .get();

              if (query.docs.isNotEmpty) {
                await query.docs.first.reference.update({'isAdmin': true});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User promoted to admin successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not found!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
