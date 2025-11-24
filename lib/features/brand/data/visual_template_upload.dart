import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/visual_item.dart';

Future<bool> uploadVisualTemplateToFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final templateItems = [
      // 1. Business Name
      VisualItem(
        id: "business_name",
        title: "Business Name",
        sections: [
          VisualSection(
            subtitle: "Name",
            isTextField: true,
            fieldType: 'text',
            hintText: "The Blue Leaf Salon",
            userInputs: [],
          ),
          VisualSection(
            subtitle: "Tagline (Optional)",
            isTextField: true,
            fieldType: 'text',
            hintText: "Where beauty meets artistry",
            userInputs: [],
          ),
        ],
      ),

      // 2. Color Palette
      VisualItem(
        id: "color_palette",
        title: "Color Palette",
        sections: [
          VisualSection(
            subtitle: "Brand Colors",
            fieldType: 'color',
            userInputs: [], // Stores color hex codes
          ),
        ],
      ),

      // 3. Logo Design
      VisualItem(
        id: "logo_design",
        title: "Logo Design",
        sections: [
          VisualSection(
            subtitle: "Select style",
            options: ["Minimalist", "Elegant", "Vintage", "Playful"],
            fieldType: 'chips',
            selectedOptions: [],
          ),
        ],
      ),

      // 4. Business Card
      VisualItem(
        id: "business_card",
        title: "Business Card",
        sections: [
          VisualSection(
            subtitle: "Select style",
            options: ["Classic", "Modern", "Minimal", "Creative"],
            fieldType: 'chips',
            selectedOptions: [],
          ),
        ],
      ),
    ];

    await firestore.collection('visual_templates').doc('default').set({
      'items': templateItems.map((e) => e.toMap()).toList(),
      'version': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Visual template uploaded successfully!');
    return true;
  } catch (e) {
    print('❌ Error uploading visual template: $e');
    return false;
  }
}

void initializeVisualTemplate() async {
  final success = await uploadVisualTemplateToFirestore();
  if (success) {
    print('Visual template is now in Firestore.');
  }
}
