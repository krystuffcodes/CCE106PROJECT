// lib/views/my_reported_items_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item.dart';
import 'item_detail_page.dart';

class MyReportedItemsPage extends StatelessWidget {
  const MyReportedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reported Items'),
        backgroundColor: const Color(0xFFb71c1c),
      ),
      body: userId == null
          ? const Center(
              child: Text(
                'No user logged in',
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('reporterId', isEqualTo: userId)
                  .orderBy('dateTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reported items yet.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final reports = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final doc = reports[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    // ✅ Safely get fields with defaults
                    final title = (data['title']?.toString().trim().isNotEmpty ?? false)
                        ? data['title'].toString()
                        : 'Unnamed Item';

                    final description =
                        (data['description']?.toString().trim().isNotEmpty ?? false)
                            ? data['description'].toString()
                            : 'No description';

                    final imagePath = data['imagePath']?.toString() ?? 'assets/default.jpg';

                    final item = Item.fromMap(data, doc.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage: imagePath.startsWith('http')
                              ? NetworkImage(imagePath)
                              : AssetImage(imagePath) as ImageProvider,
                          onBackgroundImageError: (_, __) {},
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailPage(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
