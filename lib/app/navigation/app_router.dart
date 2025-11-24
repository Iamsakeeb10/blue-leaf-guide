import 'package:blue_leaf_guide/features/profile/presentation/change_password_screen.dart';
import 'package:blue_leaf_guide/features/profile/presentation/confirm_change_password_screen.dart';
import 'package:blue_leaf_guide/features/profile/presentation/screens/notifications_screen.dart';
import 'package:blue_leaf_guide/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:blue_leaf_guide/features/profile/presentation/screens/profile_information_screen.dart';
import 'package:blue_leaf_guide/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/setup_account_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/brand/models/marketing_item.dart';
import '../../features/brand/models/strategy_item.dart';
import '../../features/brand/presentation/screens/build_brand_screen.dart';
import '../../features/brand/presentation/screens/marketing_item_detail_screen.dart';
import '../../features/brand/presentation/screens/planning_screen.dart';
import '../../features/brand/presentation/screens/strategy_items_details_screen.dart';
import '../../features/home/presentation/screens/main_navigation_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/my_account_screen.dart';
import '../../features/roadmap/presentation/screens/roadmap_details_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.currentUser != null;

    final isGoingToSplash = state.matchedLocation == '/';
    final isGoingToAuth =
        state.matchedLocation == '/sign-in' ||
        state.matchedLocation == '/sign-up' ||
        state.matchedLocation == '/onboarding' ||
        state.matchedLocation == '/otp' ||
        state.matchedLocation == '/setup-account' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/reset-password';

    final isGoingToHome = state.matchedLocation == '/home';

    // If logged in and trying to access auth screens, redirect to home
    if (isLoggedIn && isGoingToAuth) {
      return '/home';
    }

    // If not logged in and trying to access home, redirect to sign-in
    if (!isLoggedIn && isGoingToHome) {
      return '/sign-in';
    }

    // Allow splash screen
    if (isGoingToSplash) {
      return null;
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final nextRoute =
            (state.extra as Map<String, dynamic>?)?['nextRoute'] as String?;
        return OTPScreen(nextRoute: nextRoute);
      },
    ),
    GoRoute(
      path: '/setup-account',
      builder: (context, state) => const SetupAccountScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password/:code',
      builder: (context, state) {
        final code = state.pathParameters['code'] ?? '';
        return ResetPasswordScreen(resetCode: code);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScreen(),
    ),

    GoRoute(
      path: '/my-account',
      builder: (context, state) => const MyAccountScreen(),
    ),

    GoRoute(
      path: '/profile-information',
      builder: (context, state) => const ProfileInformationScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    GoRoute(
      path: '/confirm-change-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final currentPassword = extra?['currentPassword'] as String? ?? '';
        return ConfirmChangePasswordScreen(currentPassword: currentPassword);
      },
    ),

    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: '/roadmapDetails',
      builder: (context, state) {
        final roadmapId = state.extra as String;
        return RoadmapDetailsScreen(roadmapId: roadmapId);
      },
    ),

    GoRoute(
      path: '/build-brand',
      builder: (context, state) => const BuildBrandScreen(),
    ),

    GoRoute(
      path: '/strategy_item/:id',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final StrategyItem item = extra['item'];
        final String stepTitle = extra['stepTitle'] ?? 'Strategy';
        return StrategyItemDetailScreen(item: item, stepTitle: stepTitle);
      },
    ),

    GoRoute(
      path: '/marketing_item/:id',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return MarketingItemDetailScreen(
          item: extra['item'] as MarketingItem,
          stepTitle: extra['stepTitle'] as String,
        );
      },
    ),

    GoRoute(path: '/planning', builder: (context, state) => PlanningScreen()),
  ],
);
