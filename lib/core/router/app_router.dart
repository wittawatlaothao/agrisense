import 'package:agrisense/core/widgets/mobile_navigation.dart';
import 'package:agrisense/features/camera/pages/Predict_result.dart';
import 'package:flutter/material.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/settings/pages/settings_page.dart';
import '../../features/settings/pages/device_config_page.dart';
import '../../features/settings/pages/dashboard_config_page.dart';
import '../../features/settings/pages/hardware_config_page.dart';
import '../../features/settings/pages/camera_config_page.dart';
import '../../features/settings/pages/change_password_page.dart';
import '../../features/camera/pages/camera_page.dart';
import '../../features/camera/pages/history_page.dart';
import '../../features/camera/pages/camera_captures_page.dart';
import '../../features/report/pages/report_page.dart';

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
      case "/settings":
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case "/change_password":
        return MaterialPageRoute(builder: (_) => const ChangePasswordPage());
      case "/device_config":
        return MaterialPageRoute(
          builder: (_) => const DeviceConfigPage(),
        );
      case "/dashboard_config":
        return MaterialPageRoute(
          builder: (_) => const DashboardConfigPage(),
        );
      case "/hardware_config":
        return MaterialPageRoute(
          builder: (_) => const HardwareConfigPage(),
        );
      case "/camera_config":
        return MaterialPageRoute(
          builder: (_) => const CameraConfigPage(),
        );
      case "/camera":
        return MaterialPageRoute(builder: (_) => const CameraPage());
      case "/notifications":
        return MaterialPageRoute(builder: (_) => const ReportPage());
      case "/history":
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case "/camera_captures":
        return MaterialPageRoute(builder: (_) => const CameraCapturesPage());
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
