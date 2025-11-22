import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/navigation/app_router.dart';
import 'app/utils/firebase_helper.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  await initializeFirebase();

  final firestore = FirebaseFirestore.instance;

  final roadmaps = [
    {
      "title": "Plant Your Roots",
      "subtitle": "Orientation, Confidence, and Professional Foundation.",
      "buttonLabel": "0-100 hours",
      "description":
          "Every professional was once a beginner who dared to take the first step. This is where your habits of excellence begin.",
      "focusGoals": [
        "Learn your school systems and routines",
        "Build your mindset and time management skills",
        "Organize your tools and create your personal brand vision",
      ],
      "actionChecklist": [
        "Set up your Blue Leaf binder or digital folder",
        "Write your mission statement and define your why",
        "Create professional social handles such as @TomekaStyles",
        "Take your first professional photo for social media",
        "Follow 5 inspiring local salons or barbers",
        "Practice sanitation, draping, and basic client setup",
        "Take at least 100 photos of your mannequin work",
        "Arrive 15 minutes early each day for 2 weeks",
        "Keep your workstation clean and organized daily",
        "Record short daily learning reflections",
      ],
      "milestoneReflection": [
        {
          "label":
              "What skill or mindset has grown the most in me since Day One?",
          "value": "",
        },
        {
          "label":
              "What would my future professional self thank me for learning early?",
          "value": "",
        },
      ],
    },
    // Add other roadmap items here in same structure
  ];

  for (var roadmap in roadmaps) {
    await firestore.collection('roadmaps').add(roadmap);
    print('Uploaded: ${roadmap["title"]}');
  }

  print('All roadmap data uploaded successfully!');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Blue Leaf Guide',
            debugShowCheckedModeBanner: false,
            // 2️⃣ Add the global key here
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2E7D32),
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
