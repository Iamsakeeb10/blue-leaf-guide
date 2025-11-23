import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/strategy_item.dart';

/// One-time script to upload strategy template to Firestore
/// Call this function once from your app (e.g., from a hidden admin button)
/// After running once, you can update the data directly in Firestore console
Future<bool> uploadStrategyTemplateToFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final templateItems = [
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

    await firestore.collection('strategy_templates').doc('default').set({
      'items': templateItems.map((e) => e.toMap()).toList(),
      'version': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Strategy template uploaded successfully!');
    return true;
  } catch (e) {
    print('❌ Error uploading strategy template: $e');
    return false;
  }
}

/// Call this from anywhere in your app to initialize the template
/// Example: Add a hidden button in settings or call it once on app launch
void initializeStrategyTemplate() async {
  final success = await uploadStrategyTemplateToFirestore();
  if (success) {
    print(
      'Template is now in Firestore. You can update it anytime from Firebase Console.',
    );
  }
}
