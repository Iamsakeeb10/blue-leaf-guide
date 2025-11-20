import 'package:blue_leaf_guide/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/setup_account_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
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

    GoRoute(path: '/otp', builder: (context, state) => const OTPScreen()),
    GoRoute(
      path: '/setup-account',
      builder: (context, state) => const SetupAccountScreen(),
    ),
  ],
);
