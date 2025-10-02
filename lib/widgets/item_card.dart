// lib/widgets/item_card.dart
import 'dart:io'; // 👈 for Image.file
import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // ✅ keep images same height & no cropping
              AspectRatio(
                aspectRatio: 1, // square image area
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.imagePath.startsWith('assets/')
                      ? Image.asset(
                          item.imagePath,
                          fit: BoxFit.contain, // ✅ show full image (not cropped)
                          width: double.infinity,
                        )
                      : Image.file(
                          File(item.imagePath),
                          fit: BoxFit.contain, // ✅ show full image (not cropped)
                          width: double.infinity,
                        ),
                ),
              ),

              const SizedBox(height: 8),

              // ✅ Title
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // ✅ Info row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Found: ${item.isFound ? "Yes" : "No"}',
                    style: TextStyle(
                      color: item.isFound ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    item.locationFound,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
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
