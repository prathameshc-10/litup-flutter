import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:litup/view/all_parties_screen.dart';
import 'package:litup/view/dashboard_screen.dart';
import 'package:litup/view/partybot_screen.dart';
import 'package:litup/view/profile_screen_ui.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int currentSelectedIndex = 0;

  final List<Widget> pages = const [
    DashboardScreen(),
    MyPartiesScreen(),
    PartyBotScreen(),
    ProfileScreenUi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      body: IndexedStack(
        index: currentSelectedIndex,
        children: pages, // keeps pages alive
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentSelectedIndex,
        height: 60,
        backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
        color: const Color.fromRGBO(40, 25, 60, 1),
        buttonBackgroundColor: const Color.fromRGBO(83, 17, 150, 1),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeOutQuad,
        items: const [
          Icon(Icons.home_outlined, color: Colors.white, size: 28),
          Icon(Icons.people_outline, color: Colors.white, size: 28),
          Icon(Icons.message_outlined, color: Colors.white, size: 28),
          Icon(Icons.person_outline, color: Colors.white, size: 28),
        ],
        onTap: (index) {
          setState(() {
            currentSelectedIndex = index;
          });
        },
      ),
    );
  }
}
