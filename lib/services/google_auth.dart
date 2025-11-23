import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     // Start Google sign-in
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null; // user canceled

  //     // Get auth details
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     // Create Firebase credential
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     // Sign in to Firebase
  //     final UserCredential userCredential =
  //         await auth.signInWithCredential(credential);

  //     final user = userCredential.user;
  //     log("✅ Google Sign-In Success: ${user?.email}");
  //     return user; // ✅ return the Firebase user
  //   } catch (e) {
  //     log("❌ Google Sign-In Error: $e");
  //     return null;
  //   }
  // }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        log("✅ Google Sign-In Success: ${user.email}");

        // 🔹 Create Firestore user doc if it doesn't exist
        final userDoc = firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'name':
                user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : "Google User",
            'email': user.email ?? '',
            'imageUrl': user.photoURL ?? '',
            'partiesCreated': [],
            'partiesJoined': [],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          log("✅ User document created in Firestore for ${user.email}");
        } else {
          log("User document already exists: ${user.email}");
        }
      }

      return user;
    } catch (e) {
      log("❌ Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }

  // Email/Password Sign Up with username
  Future<User?> signUpWithEmail(
    String username,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Store extra data in Firestore
        await firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      log("Sign up failed: ${e.message}");
      return null;
    }
  }

  // Email/Password Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log("Login failed: ${e.message}");
      return null;
    }
  }
}
