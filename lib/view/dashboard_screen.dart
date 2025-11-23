import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/model/party.dart';
import 'package:litup/services/local_db.dart';
import 'package:litup/view/Multi_party_screen.dart';
import 'package:litup/view/create_party.dart';
import 'package:litup/view/join_party_screen.dart';
import 'package:litup/view/party_code_for_polls.dart';
import 'package:litup/view/party_details_screen.dart';
import 'package:litup/view/partybot_screen.dart';
import 'package:litup/view/profile_screen_ui.dart';
import 'package:litup/view/shared_playlist_screen.dart';
import 'package:sizer/sizer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _sliderTimer;
  String? username;
  bool isLoadingUser = true;
  String? profileImageUrl;

  List<Party> upcomingParties = [];
  List<Map<String, dynamic>> parties = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _sliderTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _autoSlide(),
    );
    _getUserData();
    _fetchUpcomingParties();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    log("Dashboard disposed");
    super.dispose();
  }

  Future<void> _getUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;

        setState(() {
          username = data?['username'] ?? 'User';
          profileImageUrl = data?['profileImage'];
          isLoadingUser = false;
        });
      } else {
        setState(() {
          username = 'User';
          profileImageUrl = null;
          isLoadingUser = false;
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
      setState(() {
        username = 'User';
        profileImageUrl = null;
        isLoadingUser = false;
      });
    }
  }

  Future<void> _fetchUpcomingParties() async {
    try {
      // Fetch latest parties from Firestore
      final snapshot =
          await FirebaseFirestore.instance
              .collection('parties')
              .orderBy('createdAt', descending: true)
              .get();

      // Get all current Firestore IDs
      final firestorePartyIds = snapshot.docs.map((doc) => doc.id).toSet();

      // Clear old cache entries that no longer exist in Firestore
      await LocalDB.removePartiesNotIn(firestorePartyIds);

      // Cache updated parties
      for (var doc in snapshot.docs) {
        final party = Party.fromFirestore(doc);
        await LocalDB.cacheParty({
          'id': doc.id,
          'name': party.title,
          'host': party.host,
          'imageUrl': party.imageUrl,
          'createdAt':
              doc['createdAt']?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Now load the updated cache
      final cached = await LocalDB.getCachedParties();
      setState(() {
        upcomingParties =
            cached.map((c) {
              return Party(
                id: c['id'],
                title: c['name'],
                host: c['host'],
                dateTime: '',
                imageUrl: c['imagePath'] ?? c['imageUrl'] ?? '',
              );
            }).toList();
      });
    } catch (e) {
      log('Error fetching parties: $e');
      final cached = await LocalDB.getCachedParties();
      setState(() {
        upcomingParties =
            cached.map((c) {
              return Party(
                id: c['id'],
                title: c['name'],
                host: c['host'],
                dateTime: '',
                imageUrl: c['imagePath'] ?? c['imageUrl'] ?? '',
              );
            }).toList();
      });
    }
  }

  void _autoSlide() {
    if (_pageController.hasClients && upcomingParties.isNotEmpty) {
      int nextPage = (_currentPage + 1) % upcomingParties.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = nextPage);
    }
  }

  Widget _getPartyImage(String url) {
    if (url.isEmpty) {
      return Container(color: Colors.grey.shade800);
    } else if (url.startsWith('http')) {
      return Image.network(url, fit: BoxFit.cover);
    } else {
      return Image.file(File(url), fit: BoxFit.cover);
    }
  }

  Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(46, 18, 73, 1),
          borderRadius: BorderRadius.circular(3.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 3.w),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      body: RefreshIndicator(
        color: const Color.fromRGBO(83, 17, 150, 1),
        backgroundColor: const Color.fromRGBO(27, 29, 44, 1),
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              _buildHeader(),
              SizedBox(height: 3.h),
              _buildUpcomingPartiesSlider(),
              SizedBox(height: 2.h),
              _buildJoinPartySection(),
              SizedBox(height: 2.h),
              _buildCreatePartySection(),
              SizedBox(height: 2.h),
              _buildQuickActions(),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      isLoadingUser = true;
    });
    await Future.wait([_getUserData(), _fetchUpcomingParties()]);
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 3.w),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileScreenUi(fromDashboard: true),
              ),
            );
          },
          child: Container(
            height: 6.h,
            width: 6.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(217, 217, 217, 1),
            ),
            child: ClipOval(
              child:
                  profileImageUrl != null
                      ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Back,",
                style: GoogleFonts.inter(
                  color: const Color.fromRGBO(217, 217, 217, 1),
                  fontSize: 13.sp,
                ),
              ),
              Text(
                isLoadingUser ? "Loading..." : username ?? "User",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 3.w),
          child: GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => YourPartiesScreen()));
            },
            child: Icon(Icons.markunread, size: 28, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingPartiesSlider() {
    if (upcomingParties.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Center(
          child: Text(
            "No upcoming parties yet!",
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14.sp),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "Upcoming Parties",
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 34.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: upcomingParties.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 0.85;
                  double opacity = 0.5;

                  if (_pageController.position.haveDimensions) {
                    double page =
                        _pageController.page ??
                        _pageController.initialPage.toDouble();
                    double diff = (page - index).abs();
                    scale = (1 - diff * 0.2).clamp(0.85, 1.0);
                    opacity = (1 - diff * 0.5).clamp(0.5, 1.0);
                  }

                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(opacity: opacity, child: child),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                PartyDetailsScreen(
                                  party: upcomingParties[index],
                                ),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                        maintainState: true,
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _getPartyImage(upcomingParties[index].imageUrl),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upcomingParties[index].title,
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  upcomingParties[index].dateTime,
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              upcomingParties.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == index
                          ? const Color.fromRGBO(83, 17, 150, 1)
                          : Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  // --- Join Party, Create Party, Quick Actions remain the same ---
  Widget _buildJoinPartySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Join Party",
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(27, 29, 44, 1),
                    hintText: "Enter Party Code",
                    hintStyle: GoogleFonts.inter(
                      color: const Color.fromRGBO(143, 142, 142, 1),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(width: 3.w),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => JoinPartyScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.w,
                    vertical: 1.5.h,
                  ),
                ),
                child: Text(
                  "Join",
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePartySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create Party",
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(27, 29, 44, 1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Start a new party",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        "Plan your next event.",
                        style: GoogleFonts.inter(
                          color: const Color.fromRGBO(143, 142, 142, 1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => CreateParty()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                    ),
                    child: Text(
                      "Create",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
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
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 3,
            children: [
              _quickActionButton(Icons.chat_bubble_outline, "Chat", () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => YourPartiesScreen()));
              }),
              _quickActionButton(Icons.music_note_outlined, "Playlist", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SharedPlaylistScreen(),
                  ),
                );
              }),
              _quickActionButton(Icons.smart_toy_outlined, "PartyBot", () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PartyBotScreen(fromDashboard: true),
                  ),
                );
              }),
              _quickActionButton(Icons.poll_outlined, "Polls", () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EnterPartyCodeScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
