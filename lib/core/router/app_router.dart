import 'package:flutter/material.dart';
import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';

class AppRouter {
  static const initialRoute = "/login";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/login":
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text("404"))),
        );
    }
  }
}
