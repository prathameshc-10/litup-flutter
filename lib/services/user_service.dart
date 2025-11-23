import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:litup/model/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserImage(String uid, String imageUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'imageUrl': imageUrl,
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> addPartyJoined(String uid, String partyId) async {
    await _firestore.collection('users').doc(uid).update({
      'partiesJoined': FieldValue.arrayUnion([partyId]),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> addPartyCreated(String uid, String partyId) async {
    await _firestore.collection('users').doc(uid).update({
      'partiesCreated': FieldValue.arrayUnion([partyId]),
      'updatedAt': DateTime.now(),
    });
  }
}
