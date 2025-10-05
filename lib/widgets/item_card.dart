// lib/widgets/item_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  const ItemCard({super.key, required this.item, required this.onTap});

  Widget _buildImage() {
    if (item.imagePath.startsWith('assets/')) {
      return Image.asset(item.imagePath, fit: BoxFit.contain, width: double.infinity);
    } else if (item.imagePath.startsWith('http')) {
      return Image.network(item.imagePath, fit: BoxFit.contain, width: double.infinity);
    } else {
      final file = File(item.imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain, width: double.infinity);
      } else {
        // fallback
        return Container(
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.image_not_supported)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Make image take flexible height and not crop
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(width: double.infinity, color: Colors.white, child: _buildImage()),
                ),
              ),
              const SizedBox(height: 8),
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Found: ${item.isFound ? "Yes" : "No"}', style: TextStyle(color: item.isFound ? Colors.green : Colors.red)),
                  Expanded(
                    child: Text(
                      '${item.locationFound}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
