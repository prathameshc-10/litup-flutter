import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:litup/services/google_auth.dart';
import 'package:litup/view/bottom_navigation_screen.dart';
import 'package:litup/view/login_email_password.dart';
import 'package:litup/view/signup_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseServices firebaseServices = FirebaseServices();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎉 App Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: primary,
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              // 🏠 Title
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Welcome to ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                    ),
                    TextSpan(
                      text: "LitUp",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Your ultimate house party companion.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textLight.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 50),

              // ✉️ Continue with Email
              _buildButton(
                icon: Icons.email_outlined,
                label: "Continue with Email",
                background: primary,
                onTap: () {
                  log("Email button tapped");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginEmailPassword(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 🔥 Continue with Google
              _buildButton(
                iconWidget: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                  size: 18,
                ),
                label: "Continue with Google",
                background: cardColor,
                onTap: () async {
                  log("Google button tapped");
                  final user = await firebaseServices.signInWithGoogle();
                  if (user != null) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', true);

                    log(
                      "Google login: ${prefs.getBool('isLoggedIn') ?? false}",
                    );
                    log(
                      "UserName : ${FirebaseAuth.instance.currentUser?.displayName}",
                    );
                    log(
                      "UserEmail : ${FirebaseAuth.instance.currentUser?.email}",
                    );
                    log("UserID : ${FirebaseAuth.instance.currentUser?.uid}");

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const BottomNavigationScreen(),
                      ),
                    );
                  } else {
                    showAppSnackBar(
                      context,
                      message: "Google sign-in cancelled",
                    );
                  }
                },
              ),

              const SizedBox(height: 50),

              // 👤 Sign up link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    children: [
                      TextSpan(text: "Don’t have an account yet? "),
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔘 Reusable button widget
  Widget _buildButton({
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required Color background,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: iconWidget ?? Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// 🎨 Color Scheme
const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);
