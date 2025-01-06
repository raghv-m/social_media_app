import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  double _glowSize = 400; // Initial size of the glowing bubble
  late Timer _timer; // Timer for animation

  @override
  void initState() {
    super.initState();

    // Start the glowing animation loop
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _glowSize = _glowSize == 400 ? 800 : 600; // Alternate between two sizes
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Column(
                children: [
                  Text(
                    "Chattr",
                    style: GoogleFonts.robotoMono(
                      fontSize: 64, // Increased font size
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Color(0xFF6A0DAD),
                            Color(0xFF1E90FF),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 100.0)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Connect, Share, and Explore",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Animated Glowing Chat Bubble
            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  height: _glowSize,
                  width: _glowSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF6A0DAD).withOpacity(0.4),
                        Color(0xFF1E90FF).withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: [0.4, 0.7, 1.0],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chat_bubble_rounded,
                      size: 120,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.blueAccent.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30), // Bottom Padding
          ],
        ),
      ),
    );
  }
}
