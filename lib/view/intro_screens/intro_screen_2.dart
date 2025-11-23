import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

/// 🎨 LitUp Brand Colors
const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

/// 🌈 Consistent App Gradient
const LinearGradient litupGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromRGBO(10, 0, 25, 1),
    Color.fromRGBO(25, 0, 50, 1),
    Color.fromRGBO(50, 0, 80, 1),
    Color.fromRGBO(90, 10, 110, 1),
  ],
);

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: litupGradient),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎮 Party Games Animation
            Lottie.asset(
              'assets/animations/party_games.json',
              height: 40.h,
              repeat: true,
              reverse: true,
            ),

            SizedBox(height: 4.h),

            Text(
              "Play, Vote & Engage",
              style: GoogleFonts.poppins(
                fontSize: 21.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // 💬 Subtitle Text
            Text(
              "From fun games like Spin the Bottle to polls and challenges — keep the vibe alive!",
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
