import 'package:flutter/material.dart';

import '../constant/app_texts.dart';
import '../../features/auth/login/ui/login_screen.dart';
import '../../features/auth/register/ui/register_screen.dart';
import '../../features/auth/register/ui/role_selection_screen.dart';
import '../../features/auth/register/data/models/register_models.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';

Route<dynamic> onGenerateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.signup:
      final role = settings.arguments as UserRole?;
      if (role != null) {
        return MaterialPageRoute(builder: (_) => RegisterScreen(role: role));
      }
      return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    default:
      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: Center(child: Text(AppTexts.routeNotFound))),
      );
  }
}
