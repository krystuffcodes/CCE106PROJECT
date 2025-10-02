// lib/views/item_detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final img = item.imagePath.startsWith('assets/') ? Image.asset(item.imagePath) : Image.file(File(item.imagePath));
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          SizedBox(height: 250, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: img)),
          const SizedBox(height: 12),
          Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Found: ${item.isFound ? "Yes" : "No"}'),
            Text('Category: ${item.category}'),
          ]),
          const SizedBox(height: 8),
          Text('Location: ${item.locationFound}'),
          const SizedBox(height: 8),
          Text('Date: ${item.dateTime}'),
          const SizedBox(height: 12),
          Text(item.description),
        ]),
      ),
    );
  }
}
