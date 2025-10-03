// lib/views/item_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ for date formatting
import '../models/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Pick image source
    final img = item.imagePath.startsWith('assets/')
        ? Image.asset(item.imagePath)
        : Image.file(File(item.imagePath));

    // ✅ Format date into readable format (e.g. October 3, 2025 – 2:35 PM)
    String formattedDate;
    try {
      final dt = DateTime.parse(item.dateTime.toString());
      formattedDate = DateFormat('MMMM d, yyyy – h:mm a').format(dt);
    } catch (e) {
      formattedDate = item.dateTime.toString(); // fallback if parse fails
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white, // ✅ White header text
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: const Color(0xFFb71c1c),
        iconTheme: const IconThemeData(color: Colors.white), // ✅ white back arrow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align left
          children: [
            // Item Image
            Center(
              child: SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: img,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status + Category
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Status: ${item.isFound ? "Found" : "Lost"}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.isFound ? Colors.green : Colors.red,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.category, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  item.category,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Location: ${item.locationFound}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Date: $formattedDate", // ✅ uses formatted date
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "Description:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFb71c1c),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
