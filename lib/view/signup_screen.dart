import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/controller/auth_controller.dart';
import 'package:litup/view/login_email_password.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // 🎨 LitUp Color Palette
  static const Color primary = Color.fromRGBO(83, 17, 150, 1);
  static const Color background = Color.fromRGBO(24, 15, 33, 1);
  static const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
  static const Color textLight = Color.fromRGBO(217, 217, 217, 1);

  final authController = AuthenticationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: false,
      body: Sizer(
        builder: (context, orientation, deviceType) {
          return Stack(
            children: [
              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo Text
                      Text(
                        "LitUp",
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontSize: 30.sp,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: primary.withValues(alpha: 0.7),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.5.h),

                      Text(
                        "Create Your Account",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.splineSans(
                          color: textLight,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.h),

                      // Username Field
                      _buildTextField(
                        controller: _usernameController,
                        label: "Username",
                        hint: "Enter your username",
                        icon: Icons.person_outline,
                      ),
                      SizedBox(height: 2.5.h),

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        hint: "Enter your email",
                        icon: Icons.email_outlined,
                      ),
                      SizedBox(height: 2.5.h),

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        hint: "Enter your password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      SizedBox(height: 5.h),

                      // Sign Up Button
                      GestureDetector(
                        onTap: () async {
                          if (_usernameController.text.trim().isNotEmpty &&
                              _emailController.text.trim().isNotEmpty &&
                              _passwordController.text.trim().isNotEmpty) {
                            bool success = await authController.signUpWithEmail(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                              name: _usernameController.text.trim(),
                            );

                            if (success) {
                              showAppSnackBar(
                                context,
                                message: "Account created successfully!",
                              );
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginEmailPassword(),
                                ),
                              );
                            } else {
                              showAppSnackBar(
                                context,
                                message: "Signup failed. Try again.",
                                backgroundColor: Colors.red,
                              );
                            }
                          } else {
                            showAppSnackBar(
                              context,
                              message: "Please fill all fields.",
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
                                color: primary.withValues(alpha: 0.6),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Sign Up",
                              style: GoogleFonts.splineSans(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Login Link
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
                              fontSize: 14.sp,
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
                                      color: primary.withValues(alpha: 0.8),
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
            ],
          );
        },
      ),
    );
  }

  // 🧱 Reusable TextField Builder
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
            color: textLight,
            fontSize: 15.sp,
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
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey[400]),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[400],
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
