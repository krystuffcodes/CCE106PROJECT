// lib/models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String title;
  final String imagePath;
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

  /// Converts Firestore data → Item object
  factory Item.fromMap(Map<dynamic, dynamic> rawMap, String id) {
    // Force convert all keys to strings for consistency
    final map = rawMap.map((key, value) => MapEntry(key.toString(), value));

    // DEBUG: Log to verify Firestore data
    print('🟢 Firestore map for $id => $map');

    // Handle Firestore Timestamp or string
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
      title: (map['title']?.toString().trim().isNotEmpty ?? false)
          ? map['title'].toString().trim()
          : 'Unnamed Item',
      imagePath: map['imagePath']?.toString() ?? 'assets/default.jpg',
      locationFound: map['locationFound']?.toString() ?? 'Unknown location',
      dateTime: dateTime,
      category: map['category']?.toString() ?? 'Others',
      isFound: map['isFound'] == true,
      reporterId: map['reporterId']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  /// Converts Item object → Firestore data
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
