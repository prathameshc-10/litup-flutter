import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:litup/controller/auth_controller.dart';
import 'package:litup/view/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sizer/sizer.dart';

class ProfileScreenUi extends StatefulWidget {
  final bool fromDashboard;
  const ProfileScreenUi({super.key, this.fromDashboard = false});

  @override
  State<ProfileScreenUi> createState() => _ProfileScreenUiState();
}

class _ProfileScreenUiState extends State<ProfileScreenUi> {
  String username = "User";
  String? profileImageUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load username and profile image
  Future<void> _loadUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'User';
          profileImageUrl = userDoc['profileImage'];
          _nameController.text = username;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_images/$uid.jpg',
      );
      await ref.putFile(_imageFile!);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImage': url,
      });
      setState(() => profileImageUrl = url);
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
    }
  }

  // Update username
  Future<void> _updateUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': newName,
      });
      setState(() {
        username = newName;
        _isEditingName = false;
      });
    } catch (e) {
      debugPrint('Error updating username: $e');
    }
  }

  Widget _partyTile(Map<String, dynamic> party) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child:
                party['posterUrl'] != null && party['posterUrl'] != ''
                    ? Image.network(party['posterUrl'], fit: BoxFit.cover)
                    : const Icon(Icons.event, color: Colors.grey, size: 40),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                party['name'] ?? 'Party',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                party['date'] ?? '',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _partyList(String title, List<Map<String, dynamic>> parties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (parties.isEmpty)
          Text(
            "No parties yet",
            style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
          )
        else
          ...parties.map((party) => _partyTile(party)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Stream<List<Map<String, dynamic>>> _createdPartiesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('parties')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'name': data['name'] ?? 'Party',
                  'date': data['date'] ?? '',
                  'posterUrl': data['posterUrl'] ?? '',
                };
              }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> _joinedPartiesStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('parties')
        .where('members', arrayContains: uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'name': data['name'] ?? 'Party',
                  'date': data['date'] ?? '',
                  'posterUrl': data['posterUrl'] ?? '',
                };
              }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
        leading:
            widget.fromDashboard
                ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
                : null,
        title: Text(
          "Profile",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final authController = AuthenticationController();
              await authController.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- Profile Image ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage:
                        _imageFile != null
                            ? FileImage(_imageFile!)
                            : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage('assets/DummyProfile.webp'))
                                    // as ImageProvider),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- Username Editable (Centered with edit icon on right) ---
            SizedBox(
              height: 40, // adjust as needed
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Username text or TextField (centered)
                  _isEditingName
                      ? SizedBox(
                        width: 200, // fixed width for editing
                        child: TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter name",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                      : Text(
                        username,
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  // Edit / Check / Close buttons on the right
                  Positioned(
                    right: 0,
                    child:
                        _isEditingName
                            ? Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: _updateUsername,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() => _isEditingName = false);
                                  },
                                ),
                              ],
                            )
                            : IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _isEditingName = true;
                                  _nameController.text = username;
                                });
                              },
                            ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Created Parties Stream ---
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _createdPartiesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final parties = snapshot.data!;
                return _partyList("Created Parties", parties);
              },
            ),

            // --- Joined Parties Stream ---
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _joinedPartiesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final parties = snapshot.data!;
                return _partyList("Party History", parties);
              },
            ),
          ],
        ),
      ),
    );
  }
}
