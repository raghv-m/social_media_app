import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/screens/login_signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  double _glowSize = 300;
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _glowSize = _glowSize == 300 ? 800 : 300;
      });
    });

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 4), () async {
      await _animationController.forward();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginSignupScreen(),
          transitionDuration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header Section (Matches LoginSignupScreen)
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        const AnimatedLogo(), // Pixelated animated logo
                        const SizedBox(height: 10),
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
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        height: _glowSize,
                        width: _glowSize,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF6A0DAD).withOpacity(0.4),
                              const Color(0xFF1E90FF).withOpacity(0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.4, 0.7, 1.0],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            size: 120,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.blueAccent,
                                blurRadius: 10,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
