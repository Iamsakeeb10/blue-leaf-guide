import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/navigation/app_router.dart';
import 'app/utils/firebase_helper.dart';
import 'core/services/local_storage.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/task/providers/subtitle_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();
  await initializeFirebase();
  await LocalStorageService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    try {
      // Handle app opened from terminated state
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('📱 Initial link: $initialUri');
        _handleDeepLink(initialUri.toString());
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }

    // Listen to incoming links while app is running
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          print('📱 Received link: $uri');
          _handleDeepLink(uri.toString());
        }
      },
      onError: (err) {
        print('❌ Error listening to app links: $err');
      },
    );
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      final mode = uri.queryParameters['mode'];
      final oobCode = uri.queryParameters['oobCode'];
      final host = uri.host;
      final scheme = uri.scheme;

      print('🔍 Deep link details:');
      print('   Full URL: $link');
      print('   Scheme: $scheme');
      print('   Host: $host');
      print('   Mode: $mode');
      print('   OobCode: ${oobCode?.substring(0, 10)}...');

      // Handle both custom scheme AND Firebase domain
      if ((scheme == 'blueleafguide' && host == 'auth') ||
          (scheme == 'https' && host == 'blue-leaf-guide.firebaseapp.com')) {
        if (mode == 'resetPassword' && oobCode != null && oobCode.isNotEmpty) {
          print('✅ Valid password reset link detected');

          // Navigate to reset password screen
          Future.delayed(const Duration(milliseconds: 300), () {
            router.go('/reset-password/$oobCode');
          });
        } else if (mode == 'verifyEmail' && oobCode != null) {
          print('✅ Email verification link detected');
          // Handle email verification if needed
        } else {
          print('⚠️ Missing mode or oobCode parameter');
        }
      } else {
        print('⚠️ Invalid link format or unrecognized scheme/host');
      }
    } catch (e) {
      print('❌ Error parsing deep link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubtitleProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            title: 'Blue Leaf Guide',
            debugShowCheckedModeBanner: false,
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
