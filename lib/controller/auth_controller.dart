import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:litup/services/google_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationController {
  final FirebaseServices _firebaseServices = FirebaseServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔑 Email login
  Future<bool> loginWithEmail(String email, String password) async {
    final user = await _firebaseServices.loginWithEmail(email, password);

    if (user != null) {
      // Fetch username from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final username = userDoc.data()?['name'] ?? '';

      // Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', username);
      await prefs.setString('userId', user.uid);

      log("Login success for: $email");
      return true;
    }
    return false;
  }

  // 📝 Email signup with username
  Future<bool> signUpWithEmail(String email, String password, {required String name}) async {
    final user = await _firebaseServices.signUpWithEmail(name, email, password);
    if (user != null) {
      await _createUserInFirestore(user, name);

      // Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', name);
      await prefs.setString('userId', user.uid);

      log("Signup success for: $email");
      return true;
    }
    return false;
  }

  // 🌐 Google login
  Future<bool> loginWithGoogle() async {
    final user = await _firebaseServices.signInWithGoogle();

    if (user != null) {
      await _createUserInFirestore(user, user.displayName ?? '');

      // Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userName', user.displayName ?? '');
      await prefs.setString('userId', user.uid);

      log("Google login success: ${user.email}");
      return true;
    }
    return false;
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _firebaseServices.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    log("User logged out successfully");
  }

  // 🧱 Create user document in Firestore (if not exists)
  Future<void> _createUserInFirestore(User user, String name) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'imageUrl': user.photoURL ?? '',
        'partiesCreated': [],
        'partiesJoined': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log("User document created for ${user.email}");
    } else {
      log("User already exists in Firestore");
    }
  }
}
