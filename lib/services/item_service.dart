// lib/services/item_service.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';

class ItemService extends ChangeNotifier {
  final List<Item> _items = [];

  ItemService() {
    // sample seed data (assets)
    _items.addAll([
      Item(
        id: const Uuid().v4(),
        title: 'iPhone 17',
        imagePath: 'assets/sample1.jpg',
        locationFound: 'Main Library',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Phone / Tablets',
        isFound: true,
        reporterId: 'user1',
        description: 'Gold color, with case',
      ),
      Item(
        id: const Uuid().v4(),
        title: 'iPhone 17 Pro Max',
        imagePath: 'assets/sample2.jpg',
        locationFound: 'Cafeteria',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Bottle',
        isFound: true,
        reporterId: 'user2',
        description: 'Large black bottle with sticker',
      ),
    ]);
  }

  List<Item> get items => List.unmodifiable(_items);

  void addItem({
    required String title,
    required String imagePath,
    required String locationFound,
    required DateTime dateTime,
    required String category,
    required bool isFound,
    required String reporterId,
    String description = '',
  }) {
    final item = Item(
      id: const Uuid().v4(),
      title: title,
      imagePath: imagePath,
      locationFound: locationFound,
      dateTime: dateTime,
      category: category,
      isFound: isFound,
      reporterId: reporterId,
      description: description,
    );
    _items.insert(0, item); // new at top
    notifyListeners();
  }

  List<Item> search(String query) {
    final q = query.toLowerCase();
    return _items.where((i) =>
        i.title.toLowerCase().contains(q) ||
        i.category.toLowerCase().contains(q) ||
        i.locationFound.toLowerCase().contains(q)).toList();
  }

  List<Item> filterByCategory(String category) {
    return _items.where((i) => i.category == category).toList();
  }

  List<Item> itemsByReporter(String reporterId) {
    return _items.where((i) => i.reporterId == reporterId).toList();
  }
}
