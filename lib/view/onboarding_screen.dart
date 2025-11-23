import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/intro_screens/intro_screen_1.dart';
import 'package:litup/view/intro_screens/intro_screen_2.dart';
import 'package:litup/view/intro_screens/intro_screen_3.dart';
import 'package:litup/view/login_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller to keep track of pages
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [IntroPage1(), IntroPage2(), IntroPage3()],
          ),

          // Dot indicator
          Container(
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text("skip", style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
                ),

                // Dot indicator
                SmoothPageIndicator(controller: _controller, count: 3),

                // Next or Done
                onLastPage
                    ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) {
                              return WelcomeScreen();
                            },
                          ),
                        );
                      },
                      child: Text("done", style: GoogleFonts.inter(color: Colors.white, fontSize: 16),),
                    )
                    : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: Text("next", style: GoogleFonts.inter(color: Colors.white, fontSize: 16),),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
