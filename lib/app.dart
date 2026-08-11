import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/router/app_router.dart';
import 'core/widgets/mobile_navigation.dart';
import 'config/themes.dart';
import 'features/auth/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Agrisense",
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Show login or dashboard depending on Firebase auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasData) {
            return const MobileNavigationScaffold();
          }

          return const LoginPage();
        },
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
