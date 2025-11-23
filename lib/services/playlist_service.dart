import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaylistService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveAiPlaylist(List<Map<String, String>> songs, String aiPrompt) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('ai_suggestions')
        .doc(user.uid)
        .collection('generated_playlists')
        .add({
      'prompt': aiPrompt,
      'songs': songs,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
