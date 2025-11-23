import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/controller/auth_controller.dart';
import 'package:litup/view/bottom_navigation_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

class LoginEmailPassword extends StatefulWidget {
  const LoginEmailPassword({super.key});

  @override
  State<LoginEmailPassword> createState() => _LoginEmailPasswordState();
}

class _LoginEmailPasswordState extends State<LoginEmailPassword> {
  // 🎨 LitUp Color Palette
  static const Color primary = Color.fromRGBO(83, 17, 150, 1);
  static const Color background = Color.fromRGBO(24, 15, 33, 1);
  static const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
  static const Color textLight = Color.fromRGBO(217, 217, 217, 1);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final authController = AuthenticationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "LitUp",
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: primary.withOpacity(0.7), blurRadius: 25),
                      ],
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Login to Your Account",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.splineSans(
                      color: textLight,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                  ),
                  SizedBox(height: 2.5.h),
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () async {
                      // login logic
                      if (_emailController.text.trim().isNotEmpty &&
                          _passwordController.text.trim().isNotEmpty) {
                        bool success = await authController.loginWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        if (success) {
                          showAppSnackBar(
                            context,
                            message: "Login Successful!",
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) {
                                return BottomNavigationScreen();
                              },
                            ),
                          );
                        } else {
                          showAppSnackBar(
                            context,
                            message: "Please enter valid email or password",
                            backgroundColor: Colors.red,
                          );
                        }
                      } else {
                        showAppSnackBar(
                          context,
                          message: "Please enter valid data",
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Log in",
                          style: GoogleFonts.splineSans(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: GoogleFonts.splineSans(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              shadows: [
                                Shadow(
                                  color: primary.withOpacity(0.8),
                                  blurRadius: 10,
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.splineSans(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && _obscurePassword,
            style: TextStyle(color: Colors.white, fontSize: 14.5.sp),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.8.h,
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.white),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
