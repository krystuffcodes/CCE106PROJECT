// lib/services/item_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/item.dart';

class ItemService extends ChangeNotifier {
  final List<Item> _items = [];
  List<Item> get items => List.unmodifiable(_items);

  final CollectionReference _col = FirebaseFirestore.instance.collection('items');

  ItemService() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final q = await _col.orderBy('dateTime', descending: true).get();
      _items.clear();
      for (final doc in q.docs) {
        final map = doc.data() as Map<String, dynamic>;
        _items.add(Item.fromMap(map, doc.id));
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('ItemService._loadItems error: $e\n$st');
    }
  }

  /// Adds an item. If [imagePath] points to a local file (not 'assets/' and not http),
  /// this will upload the file to Firebase Storage and store the download URL in Firestore.
  Future<void> addItem({
    required String title,
    required String imagePath,
    required String locationFound,
    required DateTime dateTime,
    required String category,
    required bool isFound,
    required String reporterId,
    required String description,
  }) async {
    final id = const Uuid().v4();
    String storedImagePath = imagePath;

    try {
      // Upload local file to Firebase Storage (if applicable)
      if (!imagePath.startsWith('assets/') &&
          !imagePath.startsWith('http') &&
          File(imagePath).existsSync()) {
        final file = File(imagePath);
        final ext = imagePath.split('.').last;
        final ref = FirebaseStorage.instance.ref().child('items/$id.$ext');
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        storedImagePath = await snapshot.ref.getDownloadURL();
      }

      final data = {
        'title': title,
        'imagePath': storedImagePath,
        'locationFound': locationFound,
        'dateTime': Timestamp.fromDate(dateTime),
        'category': category,
        'isFound': isFound,
        'reporterId': reporterId,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _col.doc(id).set(data);

      // Update local list (optimistic)
      final newItem = Item(
        id: id,
        title: title,
        imagePath: storedImagePath,
        locationFound: locationFound,
        dateTime: dateTime,
        category: category,
        isFound: isFound,
        reporterId: reporterId,
        description: description,
      );

      _items.insert(0, newItem);
      notifyListeners();
    } catch (e, st) {
      debugPrint('ItemService.addItem error: $e\n$st');
      rethrow;
    }
  }

  /// Get items for a particular reporter (used in "My Reported Items" page)
  Future<List<Item>> getItemsByReporter(String reporterId) async {
    final q = await _col
        .where('reporterId', isEqualTo: reporterId)
        .orderBy('dateTime', descending: true)
        .get();
    return q.docs.map((d) => Item.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  /// Optional: refresh from server
  Future<void> refresh() async {
    await _loadItems();
  }
}
