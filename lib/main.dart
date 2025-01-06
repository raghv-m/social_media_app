import 'package:flutter/material.dart';
import 'package:social_media_app/screens/onboarding_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner
      initialRoute: '/onboarding', // Set the initial route
      routes: {
        '/onboarding': (context) => OnboardingScreen(), // Add route for OnboardingScreen
      },
    );
  }
}
