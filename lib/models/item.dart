// lib/models/item.dart
import 'package:flutter/foundation.dart';

class Item {
  final String id;
  final String title;
  final String imagePath; // asset path or file path
  final String locationFound;
  final DateTime dateTime;
  final String category;
  final bool isFound; // true => Found, false => Lost
  final String reporterId;
  final String description;

  Item({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.locationFound,
    required this.dateTime,
    required this.category,
    required this.isFound,
    required this.reporterId,
    required this.description,
  });
}
