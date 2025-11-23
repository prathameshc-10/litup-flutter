import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/bottom_navigation_screen.dart';
import 'package:litup/view/onboarding_screen.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  widget.isLoggedIn
                      ? const BottomNavigationScreen()
                      : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(25, 5, 60, 1),
              Color.fromRGBO(55, 10, 100, 1),
              Color.fromRGBO(90, 20, 140, 1),
              Color.fromRGBO(130, 35, 160, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gradient Logo Text
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.white, Colors.amberAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      "LitUp",
                      style: GoogleFonts.righteous(
                        fontSize: 42.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // Tagline with a shimmer-style animation
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final shimmerValue =
                          (1 + (_controller.value * 0.8)) % 1.0;
                      return ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: const [
                              Colors.white70,
                              Colors.white,
                              Colors.white70,
                            ],
                            stops: [
                              shimmerValue - 0.3,
                              shimmerValue,
                              shimmerValue + 0.3,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            tileMode: TileMode.clamp,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Text(
                          "Bring Your Parties to Life",
                          style: GoogleFonts.nunito(
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
