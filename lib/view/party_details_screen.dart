import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/model/party.dart';
import 'package:litup/view/join_party_screen.dart';
import 'package:sizer/sizer.dart';

// 🎨 Colors
const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

class PartyDetailsScreen extends StatefulWidget {
  final Party party;
  const PartyDetailsScreen({super.key, required this.party});

  @override
  State<PartyDetailsScreen> createState() => _PartyDetailsScreenState();
}

class _PartyDetailsScreenState extends State<PartyDetailsScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, DocumentSnapshot> _userCache = {};

  User get currentUser => _auth.currentUser!;

  Future<DocumentSnapshot?> _getUserData(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId];
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) _userCache[userId] = doc;
    return doc.exists ? doc : null;
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final userDoc = await _getUserData(currentUser.uid);
    final profileImage =
        userDoc?.get('profileImage') ?? 'https://via.placeholder.com/150';
    final username = userDoc?.get('username') ?? 'Unknown';

    await _firestore
        .collection('chats')
        .doc(widget.party.id)
        .collection('messages')
        .add({
      'senderId': currentUser.uid,
      'username': username,
      'profileImage': profileImage,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Party Details",
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            _firestore.collection('parties').doc(widget.party.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final partyName = data['name'] ?? widget.party.title;
          final createdBy = data['createdBy'];
          final date = data['date'] ?? widget.party.time;
          final imageUrl = data['posterUrl'] ?? widget.party.imageUrl;
          final location = data['location'] ?? 'Not specified';

          return SafeArea(
            child: Column(
              children: [
                // Top banner
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 28.h,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: 28.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 5.w,
                        bottom: 2.h,
                        child: Text(
                          partyName,
                          style: GoogleFonts.quicksand(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // Info + Join button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: primary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    date,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            FutureBuilder<DocumentSnapshot>(
                              future: _firestore
                                  .collection('users')
                                  .doc(createdBy)
                                  .get(),
                              builder: (context, snapshot) {
                                final hostName = snapshot.hasData
                                    ? (snapshot.data!.get('username') ?? 'Unknown')
                                    : 'Loading...';
                                return Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        "Hosted by $hostName",
                                        style: GoogleFonts.inter(
                                          color: textLight.withValues(alpha: 0.9),
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: primary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Join button
                      SizedBox(
                        height: 5.5.h,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const JoinPartyScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.celebration_rounded,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Join Party",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 6,
                            shadowColor: primary.withValues(alpha: 0.5),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.2.h,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // Chat Section
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      children: [
                        // Messages
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('chats')
                                .doc(widget.party.id)
                                .collection('messages')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, chatSnapshot) {
                              if (!chatSnapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }
                              final docs = chatSnapshot.data!.docs;
                              return ListView.builder(
                                reverse: true,
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final msgData =
                                      docs[index].data() as Map<String, dynamic>;
                                  final isMe =
                                      msgData['senderId'] == currentUser.uid;

                                  return Align(
                                    alignment: isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 0.6.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.w, vertical: 1.h),
                                      decoration: BoxDecoration(
                                        color: isMe ? primary : Colors.grey[700],
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (!isMe)
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  msgData['profileImage'] ??
                                                      'https://via.placeholder.com/150'),
                                            ),
                                          if (!isMe) SizedBox(width: 2.w),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (!isMe)
                                                  Text(
                                                    msgData['username'] ?? 'Unknown',
                                                    style: GoogleFonts.inter(
                                                      color: textLight,
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                Text(
                                                  msgData['text'] ?? '',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (isMe) SizedBox(width: 2.w),
                                          if (isMe)
                                            CircleAvatar(
                                              radius: 15,
                                              backgroundImage: NetworkImage(
                                                  msgData['profileImage'] ??
                                                      'https://via.placeholder.com/150'),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Message Input
                        Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 1.h,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "Type a message...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: sendMessage,
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
