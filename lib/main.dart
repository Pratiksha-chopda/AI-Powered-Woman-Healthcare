import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// REMOVE saving token from main → we will save it only once manually
import 'services/secure_storage.dart';

// SCREENS
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );



  //  HF token:
  await SecureStorage.saveToken(const String.fromEnvironment('HF_TOKEN', defaultValue: 'YOUR_HUGGINGFACE_TOKEN_HERE'));
  //


  runApp(const OvacareApp());
}

class OvacareApp extends StatelessWidget {
  const OvacareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ovacare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.grey.shade50,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(username: 'User'),
      },
    );
  }
}
