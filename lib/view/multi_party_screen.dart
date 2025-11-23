import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/community_chat_screen.dart';
import 'package:litup/view/create_party.dart';
import 'package:litup/view/join_party_screen.dart';
import 'package:sizer/sizer.dart';

// Colors
const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

class YourPartiesScreen extends StatelessWidget {
  YourPartiesScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Convert gs:// path to HTTP URL if needed
  Future<String> _resolvePosterUrl(String url) async {
    if (url.startsWith('gs://')) {
      try {
        return await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
      } catch (e) {
        log("Error getting download URL: $e");
        return '';
      }
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Your Parties',
          style: GoogleFonts.quicksand(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            color: textLight,
          ),
        ),
        backgroundColor: background,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('parties')
            .where('members', arrayContains: currentUid)
            //.orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primary));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "You haven't joined or created any parties yet.",
                style: GoogleFonts.quicksand(
                  fontSize: 14.sp,
                  color: textLight.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final partyData = docs[index].data()! as Map<String, dynamic>;
              final partyCode = partyData['partyCode'] ?? docs[index].id;

              return FutureBuilder<String>(
                future: _resolvePosterUrl(partyData['posterUrl'] ?? ''),
                builder: (context, urlSnapshot) {
                  final posterUrl = urlSnapshot.data ?? '';
                  return _buildPartyCard(
                    context,
                    title: partyData['name'] ?? 'Unnamed Party',
                    message:
                        "Members: ${List<String>.from(partyData['members'] ?? []).length}",
                    imageUrl: posterUrl,
                    time: (partyData['createdAt'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                    chatId: partyData['chatId'],
                    partyCode: partyCode,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'groupAddFAB',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => JoinPartyScreen()));
            },
            backgroundColor: primary,
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
          SizedBox(height: 2.h),
          FloatingActionButton(
            heroTag: 'addFAB',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => CreateParty()));
            },
            backgroundColor: primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(
    BuildContext context, {
    required String title,
    required String message,
    required String imageUrl,
    required String time,
    String? chatId,
    String? partyCode,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId ?? '',
              partyName: title,
              partyCode: partyCode ?? '#UNKNOWN',
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                height: 15.w,
                width: 15.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/DummyProfile.webp',
                    fit: BoxFit.cover,
                    height: 15.w,
                    width: 15.w,
                  );
                },
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    message,
                    style: GoogleFonts.quicksand(
                      fontSize: 14.sp,
                      color: textLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: textLight.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
