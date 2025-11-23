import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:litup/services/local_db.dart';
import 'package:litup/view/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA4OpY39JjKUtD3ry6_sZdjjojlrts2q34",
      appId: "1:254233881371:android:81ab1bcff782c5c30181be",
      messagingSenderId: "254233881371",
      projectId: "litup-c38ac",
    ),
  );
  await LocalDB.database;
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen(isLoggedIn: isLoggedIn),
        );
      },
    );
  }
}
