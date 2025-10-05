// lib/models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String imagePath; // can be: 'assets/..', local file path, or http(s) URL
  final String locationFound;
  final DateTime dateTime;
  final String category;
  final bool isFound;
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

  factory Item.fromMap(Map<String, dynamic> map, String id) {
    final dateVal = map['dateTime'];
    DateTime dateTime;
    if (dateVal is Timestamp) {
      dateTime = dateVal.toDate();
    } else if (dateVal is DateTime) {
      dateTime = dateVal;
    } else {
      dateTime = DateTime.tryParse(dateVal?.toString() ?? '') ?? DateTime.now();
    }

    return Item(
      id: id,
      title: map['title'] ?? '',
      imagePath: map['imagePath'] ?? '',
      locationFound: map['locationFound'] ?? '',
      dateTime: dateTime,
      category: map['category'] ?? 'Others',
      isFound: map['isFound'] ?? false,
      reporterId: map['reporterId'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imagePath': imagePath,
      'locationFound': locationFound,
      'dateTime': Timestamp.fromDate(dateTime),
      'category': category,
      'isFound': isFound,
      'reporterId': reporterId,
      'description': description,
    };
  }
}
