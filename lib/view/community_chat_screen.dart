import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

// Colors
const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String partyName;
  final String partyCode;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.partyName,
    required this.partyCode,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();

  bool _isSending = false;
  final Map<String, DocumentSnapshot> _userCache = {}; // cache for user info

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.partyName,
              style: GoogleFonts.quicksand(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.partyCode,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: textLight.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(2.w),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final senderId = data['senderId'] as String?;
                    final isMe = senderId == _auth.currentUser?.uid;

                    if (senderId == null) return SizedBox();

                    print("Message: ${data['message']}, senderId: $senderId");

                    return FutureBuilder<DocumentSnapshot?>(
                      future: _getUserData(senderId),
                      builder: (context, userSnapshot) {
                        Map<String, dynamic>? userData;
                        if (userSnapshot.hasData && userSnapshot.data != null) {
                          userData =
                              userSnapshot.data!.data() as Map<String, dynamic>?;
                        } else {
                          print("User not found for senderId: $senderId");
                          userData = {'username': 'Unknown', 'profileImage': ''};
                        }

                        return _buildMessageBubble(data, isMe, userData);
                      },
                    );
                  },
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> data, bool isMe, Map<String, dynamic>? userData) {
    final timestamp = data['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? timestamp.toDate().toLocal().toString().substring(11, 16)
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isMe ? primary : cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 12.sp,
                backgroundImage: userData != null &&
                        userData['profileImage'] != null &&
                        userData['profileImage'] != ''
                    ? NetworkImage(userData['profileImage'])
                    : null,
                backgroundColor: Colors.grey,
              ),
            if (!isMe) SizedBox(width: 2.w),
            Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Text(
                    userData != null && userData['username'] != null
                        ? userData['username']
                        : 'Unknown',
                    style: GoogleFonts.quicksand(
                      fontSize: 12.sp,
                      color: Colors.white70,
                    ),
                  ),
                Text(
                  data['message'] ?? '',
                  style: GoogleFonts.quicksand(
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  timeString,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: background,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.quicksand(color: textLight),
              decoration: InputDecoration(
                hintText: 'Message #${widget.partyName}',
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _isSending
              ? CircularProgressIndicator(color: textLight)
              : IconButton(
                  icon: Icon(Icons.send, color: textLight),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }

  Future<DocumentSnapshot?> _getUserData(String userId) async {
    try {
      if (_userCache.containsKey(userId)) return _userCache[userId];

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) _userCache[userId] = doc;
      print("User data cached for $userId: ${doc.data()}");
      return doc.exists ? doc : null;
    } catch (e) {
      print("Error fetching user data for $userId: $e");
      return null;
    }
  }

  void _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    final message = _controller.text.trim();
    _controller.clear();

    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'Anonymous',
        'message': message,
        'avatarUrl': user.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Message sent: $message");
    } catch (e) {
      print("Error sending message: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }
}
