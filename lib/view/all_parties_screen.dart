import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/model/party.dart';
import 'package:litup/view/create_party.dart';
import 'package:litup/view/join_party_screen.dart';
import 'package:litup/view/party_details_screen.dart';
import 'package:sizer/sizer.dart';

class MyPartiesScreen extends StatefulWidget {
  const MyPartiesScreen({super.key});

  @override
  State<MyPartiesScreen> createState() => _MyPartiesScreenState();
}

class _MyPartiesScreenState extends State<MyPartiesScreen> {
  static const Color primary = Color(0xFF7f13ec);
  static const Color background = Color.fromRGBO(24, 15, 33, 1);

  int _selectedTabIndex = 0;
  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "My Parties",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateParty()),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Search TextField
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery =
                      value
                          .toLowerCase(); // convert to lowercase for case-insensitive search
                });
              },
              decoration: InputDecoration(
                hintText: "Search parties...",
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: background.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                  borderSide: BorderSide.none,
                ),
              ),
              style: GoogleFonts.inter(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Tabs
            Row(
              children: [
                _buildTab("My Parties", 0),
                _buildTab("All Parties", 1),
              ],
            ),
            const SizedBox(height: 20),

            // Party List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('parties')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final allParties =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Party(
                          id: doc.id,
                          title: data['name'] ?? '',
                          host: data['hostName'] ?? '',
                          time: data['date'] ?? '',
                          imageUrl: data['posterUrl'] ?? '',
                          rsvped: (data['members'] as List).contains(
                            user?.uid ?? '',
                          ),
                          tags: [],
                          createdBy: data['createdBy'] ?? '',
                        );
                      }).toList();

                  // Filter based on tab selection
                  var displayed =
                      _selectedTabIndex == 0
                          ? allParties.where((p) => p.rsvped).toList()
                          : allParties;

                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    displayed =
                        displayed
                            .where(
                              (p) =>
                                  p.title.toLowerCase().contains(_searchQuery),
                            )
                            .toList();
                  }

                  if (displayed.isEmpty) {
                    return Center(
                      child: Text(
                        "No parties found!",
                        style: GoogleFonts.inter(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: displayed.length,
                    itemBuilder: (context, index) {
                      return PartyCard(party: displayed[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    _selectedTabIndex == index ? primary : Colors.transparent,
                width: 2.sp,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: _selectedTabIndex == index ? primary : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class PartyCard extends StatelessWidget {
  final Party party;
  const PartyCard({super.key, required this.party});

  Future<String> _fetchHostUsername(String createdBy) async {
    if (createdBy.isEmpty) return 'Unknown';
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(createdBy)
              .get();

      if (!doc.exists) return 'Unknown';

      // ignore: unnecessary_cast
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return 'Unknown';

      return data['username'] as String? ?? 'Unknown';
    } catch (e) {
      debugPrint('Error fetching username: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF7f13ec);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PartyDetailsScreen(party: party)),
        );
      },
      borderRadius: BorderRadius.circular(16.sp),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.2),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.time,
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      party.title,
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Fetch username using createdBy UID
                    FutureBuilder<String>(
                      future: _fetchHostUsername(party.createdBy),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text(
                            "Hosted by ...",
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        }
                        final username = snapshot.data!;
                        return Text(
                          "Hosted by $username",
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // RSVP / Join button
                    party.rsvped
                        ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "RSVP'd",
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (Context){return JoinPartyScreen();}));
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Join",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),

            // Right image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                party.imageUrl,
                width: 90,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
