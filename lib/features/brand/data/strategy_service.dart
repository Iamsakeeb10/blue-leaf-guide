import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/strategy_item.dart';

class StrategyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's strategy data
  Future<List<StrategyItem>> getUserStrategyItems(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('strategy')
          .doc('items')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final itemsList = data['items'] as List<dynamic>?;

        if (itemsList != null) {
          return itemsList
              .map((item) => StrategyItem.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      }

      // If no user data exists, fetch template from Firestore
      return await _getTemplateStrategyItems();
    } catch (e) {
      print('Error fetching strategy items: $e');
      return await _getTemplateStrategyItems();
    }
  }

  // Fetch template strategy items from Firestore
  Future<List<StrategyItem>> _getTemplateStrategyItems() async {
    try {
      final doc = await _firestore
          .collection('strategy_templates')
          .doc('default')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final itemsList = data['items'] as List<dynamic>?;

        if (itemsList != null && itemsList.isNotEmpty) {
          return itemsList
              .map((item) => StrategyItem.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      }

      // If template doesn't exist in Firestore, return empty list
      // This means you need to manually add the template to Firestore first
      print('No template found in Firestore. Please add template data.');
      return [];
    } catch (e) {
      print('Error fetching template strategy items: $e');
      return [];
    }
  }

  // Save or update a single strategy item
  Future<bool> saveStrategyItem(String userId, StrategyItem item) async {
    try {
      // Get existing items
      final existingItems = await getUserStrategyItems(userId);

      // Find and update the item
      final index = existingItems.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        existingItems[index] = item;
      } else {
        existingItems.add(item);
      }

      // Save back to Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('strategy')
          .doc('items')
          .set({
            'items': existingItems.map((e) => e.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving strategy item: $e');
      return false;
    }
  }

  // Save all strategy items at once
  Future<bool> saveAllStrategyItems(
    String userId,
    List<StrategyItem> items,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('strategy')
          .doc('items')
          .set({
            'items': items.map((e) => e.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print('Error saving all strategy items: $e');
      return false;
    }
  }

  // Get a single strategy item
  Future<StrategyItem?> getStrategyItem(String userId, String itemId) async {
    try {
      final items = await getUserStrategyItems(userId);
      return items.firstWhere(
        (item) => item.id == itemId,
        orElse: () => StrategyItem(id: itemId, title: '', sections: []),
      );
    } catch (e) {
      print('Error fetching strategy item: $e');
      return null;
    }
  }
}
