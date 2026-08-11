import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'app.dart';
import 'config/firebase_options.dart';
import 'features/auth/provider/auth_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // บันทึก FCM Token เมื่อ user login อยู่
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await notificationService.saveTokenToFirestore(currentUser.uid);
  }

  // อัพเดท token เมื่อ login/logout
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      await notificationService.saveTokenToFirestore(user.uid);
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
