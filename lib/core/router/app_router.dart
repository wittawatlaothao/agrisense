import 'package:agrisense/core/widgets/mobile_navigation.dart';
import 'package:agrisense/features/camera/pages/Predict_result.dart';
import 'package:flutter/material.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/camera/pages/camera_page.dart';

class AppRouter {
  static const initialRoute = "/login";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/login":
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case "/home":
        return MaterialPageRoute(builder: (_) => const MobileNavigationScaffold());
      case "/dashboard":
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case "/profile":
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case "/camera":
        return MaterialPageRoute(builder: (_) => const CameraPage());
      case "/predict_result":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PredictResultPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text("404"))),
        );
    }
  }
}
