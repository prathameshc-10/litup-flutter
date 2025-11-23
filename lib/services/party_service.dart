  import 'dart:io';
  import 'dart:math';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:firebase_storage/firebase_storage.dart';

  class PartyService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    // Generate unique 6-letter code
    String _generatePartyCode() {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random();
      return List.generate(
        6,
        (index) => chars[random.nextInt(chars.length)],
      ).join();
    }

    /// 🔹 Create a new party
    Future<String> createParty({
      required String name,
      required String date,
      required String location,
      required String theme,
      required File posterFile,
      required List<Map<String, dynamic>> polls,
    }) async {
      if (name.isEmpty || date.isEmpty || location.isEmpty || theme.isEmpty) {
        throw Exception("All fields are required");
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Generate unique party code
      String code = _generatePartyCode();
      final existing = await _firestore.collection('parties').doc(code).get();
      if (existing.exists) code = _generatePartyCode();

      // Upload poster
      final storageRef = _storage.ref().child('party_posters/$code.jpg');
      await storageRef.putFile(posterFile);
      final imageUrl = await storageRef.getDownloadURL();

      // Create a chat document
      final chatRef = _firestore.collection('chats').doc();
      await chatRef.set({
        'chatId': chatRef.id,
        'partyCode': code,
        'members': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Store party info including chatId
      await _firestore.collection('parties').doc(code).set({
        'name': name,
        'date': date,
        'location': location,
        'theme': theme,
        'posterUrl': imageUrl,
        'hostName': user.displayName ?? user.email ?? "Unknown Host",
        'createdBy': user.uid,
        'members': [user.uid],
        'polls': polls,
        'chatId': chatRef.id, // link chat here
        'createdAt': FieldValue.serverTimestamp(),
      });

      return code;
    }

    /// 🔹 Join Party
    Future<void> joinParty(String code) async {
      final doc = await _firestore.collection('parties').doc(code).get();

      if (!doc.exists) throw Exception('Party not found!');

      final currentUid = _auth.currentUser?.uid ?? 'anonymous';
      final members = List<String>.from(doc.data()?['members'] ?? []);

      if (members.contains(currentUid))
        throw Exception('You have already joined this party!');

      // Update party members
      await _firestore.collection('parties').doc(code).update({
        'members': FieldValue.arrayUnion([currentUid]),
      });

      // Add user to chat members
      final chatId = doc.data()?['chatId'];
      if (chatId != null) {
        await _firestore.collection('chats').doc(chatId).update({
          'members': FieldValue.arrayUnion([currentUid]),
        });
      }
    }
  }
