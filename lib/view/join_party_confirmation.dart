import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/model/party.dart';
import 'package:litup/view/bottom_navigation_screen.dart';
import 'package:litup/view/party_details_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

class JoinPartyConfirmation extends StatefulWidget {
  final String partyCode;
  const JoinPartyConfirmation({super.key, required this.partyCode});

  @override
  State<JoinPartyConfirmation> createState() => _JoinPartyConfirmationState();
}

class _JoinPartyConfirmationState extends State<JoinPartyConfirmation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? partyData;
  bool _loading = true;
  String? hostName;

  @override
  void initState() {
    super.initState();
    _fetchPartyData();
  }

  Future<void> _fetchHostName() async {
    final createdById = partyData!['createdBy'];
    if (createdById != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(createdById)
              .get();

      if (userDoc.exists) {
        setState(() {
          hostName = userDoc['username'];
        });
      } else {
        setState(() {
          hostName = 'Unknown';
        });
      }
    }
  }

  Future<void> _fetchPartyData() async {
    try {
      final doc =
          await _firestore.collection('parties').doc(widget.partyCode).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;
        String imageUrl = data['posterUrl'] ?? ''; // <-- changed here

        // If it's a Firebase Storage path, get download URL
        if (imageUrl.startsWith('gs://')) {
          imageUrl = await _getImageUrl(imageUrl);
        }

        setState(() {
          partyData = {
            ...data,
            'imageUrl': imageUrl, // store proper HTTP URL
          };
          _loading = false;
        });

        _fetchHostName();
      } else {
        _showError("Party not found");
      }
    } catch (e) {
      _showError("Error fetching data");
      log("Error: ${e.toString()}");
    }
  }

  Future<String> _getImageUrl(String path) async {
    try {
      String url =
          await FirebaseStorage.instance.refFromURL(path).getDownloadURL();
      return url;
    } catch (e) {
      log("Error getting download URL: $e");
      return '';
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showAppSnackBar(context, message: message, backgroundColor: Colors.red);
    log("Error: $message");
    setState(() {
      _loading = false;
      partyData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF180F21),
      appBar: AppBar(
        leading: IconButton(
          onPressed:
              () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
                (route) => false,
              ),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "Join Party",
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF180F21),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : partyData == null
              ? Center(
                child: Text(
                  "Party not found",
                  style: GoogleFonts.quicksand(color: Colors.white),
                ),
              )
              : _buildPartyContent(),
    );
  }

  Widget _buildPartyContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        children: [
          Text(
            "You're in!",
            style: GoogleFonts.quicksand(
              fontSize: 32.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Get ready to party with your friends at",
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: Colors.white70,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF5A328C),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // align left
                  children: [
                    // --- Party Image ---
                    Align(
                      alignment: Alignment.centerLeft, // align image to left
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 300,
                          width: 300,
                          child:
                              partyData!['imageUrl'] != ''
                                  ? Image.network(
                                    partyData!['imageUrl'],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      log("Failed to load party image: $error");
                                      return Image.asset(
                                        'assets/DummyProfile.webp',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    'assets/DummyProfile.webp',
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // --- Party Details ---
                    Text(
                      partyData!['name'] ?? '',
                      style: GoogleFonts.quicksand(
                        fontSize: 19.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      "Hosted by ${hostName ?? '...'}",
                      style: GoogleFonts.quicksand(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white54,
                          size: 20,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          partyData!['date'] ?? '',
                          style: GoogleFonts.quicksand(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white54,
                          size: 20,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            partyData!['location'] ?? '',
                            style: GoogleFonts.quicksand(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 3.h, bottom: 2.h),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (_) => PartyDetailsScreen(
                          party: Party(
                            id: widget.partyCode,
                            title: partyData!['name'] ?? '',
                            host: partyData!['createdBy'] ?? '',
                            dateTime:
                                "${partyData!['date'] ?? ''} - ${partyData!['location'] ?? ''}",
                            time: partyData!['date'] ?? '',
                            imageUrl: partyData!['imageUrl'] ?? '',
                          ),
                        ),
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF531196),
                minimumSize: Size(100.w, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "Go to Party",
                style: GoogleFonts.quicksand(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
