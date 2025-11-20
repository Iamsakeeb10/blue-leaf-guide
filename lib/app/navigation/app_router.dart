import 'package:go_router/go_router.dart';

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
  ],
);
