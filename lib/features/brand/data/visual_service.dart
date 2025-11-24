import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/visual_item.dart';

class VisualService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<VisualItem>> getUserVisualItems(String userId) async {
    try {
      final templateItems = await _getTemplateVisualItems();

      if (templateItems.isEmpty) {
        print('No visual template found in Firestore.');
        return [];
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('visual')
          .doc('items')
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        return templateItems;
      }

      final userData = userDoc.data()!;
      final userItemsList = userData['items'] as List<dynamic>?;

      if (userItemsList == null || userItemsList.isEmpty) {
        return templateItems;
      }

      final userItemsMap = <String, Map<String, dynamic>>{};
      for (var item in userItemsList) {
        final itemMap = item as Map<String, dynamic>;
        userItemsMap[itemMap['id']] = itemMap;
      }

      final mergedItems = <VisualItem>[];

      for (var templateItem in templateItems) {
        final userItemData = userItemsMap[templateItem.id];

        if (userItemData != null) {
          final userSections = List<Map<String, dynamic>>.from(
            userItemData['sections'] ?? [],
          );

          final mergedSections = <VisualSection>[];
          for (int i = 0; i < templateItem.sections.length; i++) {
            final templateSection = templateItem.sections[i];

            final userSection = userSections.firstWhere(
              (s) => s['subtitle'] == templateSection.subtitle,
              orElse: () => <String, dynamic>{},
            );

            mergedSections.add(
              VisualSection(
                subtitle: templateSection.subtitle,
                options: templateSection.options,
                isTextField: templateSection.isTextField,
                fieldType: templateSection.fieldType,
                hintText: templateSection.hintText,
                userInputs: userSection.isNotEmpty
                    ? List<String>.from(userSection['userInputs'] ?? [])
                    : templateSection.userInputs,
                selectedOptions: userSection.isNotEmpty
                    ? List<String>.from(userSection['selectedOptions'] ?? [])
                    : templateSection.selectedOptions,
              ),
            );
          }

          mergedItems.add(
            VisualItem(
              id: templateItem.id,
              title: templateItem.title,
              sections: mergedSections,
              isCompleted: userItemData['isCompleted'] ?? false,
            ),
          );
        } else {
          mergedItems.add(templateItem);
        }
      }

      return mergedItems;
    } catch (e) {
      print('Error fetching visual items: $e');
      return await _getTemplateVisualItems();
    }
  }

  Future<List<VisualItem>> _getTemplateVisualItems() async {
    try {
      final doc = await _firestore
          .collection('visual_templates')
          .doc('default')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final itemsList = data['items'] as List<dynamic>?;

        if (itemsList != null && itemsList.isNotEmpty) {
          return itemsList
              .map((item) => VisualItem.fromMap(item as Map<String, dynamic>))
              .toList();
        }
      }

      print('No visual template found in Firestore.');
      return [];
    } catch (e) {
      print('Error fetching template visual items: $e');
      return [];
    }
  }

  Future<bool> saveVisualItem(String userId, VisualItem item) async {
    try {
      final existingItems = await getUserVisualItems(userId);

      final index = existingItems.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        existingItems[index] = item;
      } else {
        existingItems.add(item);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('visual')
          .doc('items')
          .set({
            'items': existingItems.map((e) => e.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving visual item: $e');
      return false;
    }
  }

  Future<VisualItem?> getVisualItem(String userId, String itemId) async {
    try {
      final items = await getUserVisualItems(userId);
      return items.firstWhere(
        (item) => item.id == itemId,
        orElse: () => VisualItem(id: itemId, title: '', sections: []),
      );
    } catch (e) {
      print('Error fetching visual item: $e');
      return null;
    }
  }
}
