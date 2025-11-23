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

      // Return default items if no data exists
      return _getDefaultStrategyItems();
    } catch (e) {
      print('Error fetching strategy items: $e');
      return _getDefaultStrategyItems();
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
        orElse: () =>
            _getDefaultStrategyItems().firstWhere((e) => e.id == itemId),
      );
    } catch (e) {
      print('Error fetching strategy item: $e');
      return null;
    }
  }

  // Helper: Get default strategy items (from your existing data)
  List<StrategyItem> _getDefaultStrategyItems() {
    return [
      StrategyItem(
        id: "branding_basics",
        title: "Branding Basics",
        sections: [
          StrategySection(
            subtitle: "Be Smart with brand building awareness:",
            bullets: [
              "Be Authentic",
              "Have a unique voice",
              "Build an email list",
              "Create a memorable slogan",
              "Empower and educate your customer",
            ],
          ),
          StrategySection(
            subtitle: "Associate yourself with strong brands:",
            bullets: [
              "Your School",
              "Products that you use",
              "Tools that you use",
            ],
          ),
          StrategySection(
            subtitle:
                "Build a clear website, grow your Instagram following, know your audience, and define your mission.",
            bullets: [],
          ),
        ],
      ),
      StrategyItem(
        id: "vision_mission",
        title: "Vision & Mission",
        sections: [
          StrategySection(
            subtitle: "Vision",
            isTextField: true,
            userInputs: [],
          ),
          StrategySection(
            subtitle: "Mission",
            isTextField: true,
            userInputs: [],
          ),
          StrategySection(
            subtitle: "Core Values",
            isTextField: true,
            userInputs: [],
          ),
        ],
      ),
      StrategyItem(
        id: "target_audience",
        title: "Target Audience",
        sections: [
          StrategySection(
            subtitle: "Age Range",
            isTextField: true,
            userInputs: [],
            fieldType: 'dropdown',
          ),
          StrategySection(
            subtitle: "Income Level",
            isTextField: true,
            userInputs: [],
            fieldType: 'dropdown',
          ),
          StrategySection(
            subtitle: "Location",
            isTextField: true,
            userInputs: [],
          ),
        ],
      ),
      StrategyItem(
        id: "brand_personality",
        title: "Brand Personality",
        sections: [
          StrategySection(
            subtitle: "Select 3-5 traits that define your brand",
            bullets: [
              "Sophisticated",
              "Playful",
              "Luxurious",
              "Approachable",
              "Bold",
              "Elegant",
              "Natural",
              "Modern",
              "Minimalist",
              "Glamorous",
            ],
            isTextField: false,
            fieldType: 'chips',
            userInputs: [],
          ),
        ],
      ),
      StrategyItem(
        id: "brand_story",
        title: "Brand Story",
        sections: [
          StrategySection(
            subtitle: "Your Brand Story",
            isTextField: true,
            userInputs: [],
          ),
        ],
      ),
    ];
  }
}
