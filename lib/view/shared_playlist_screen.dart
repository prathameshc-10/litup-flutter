import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🎨 Custom Color Theme
const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

class SharedPlaylistScreen extends StatefulWidget {
  const SharedPlaylistScreen({super.key});

  @override
  State<SharedPlaylistScreen> createState() => _SharedPlaylistScreenState();
}

class _SharedPlaylistScreenState extends State<SharedPlaylistScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _player = AudioPlayer();

  List<Map<String, String>> searchResults = [];
  List<Map<String, String>> aiSuggestions = [];
  List<Map<String, String>> userPlaylist = [];

  bool isPlaying = false;
  String? currentPreviewUrl;
  bool isLoading = true;
  bool isAISuggestionsLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserPlaylist();
    fetchAISuggestions();
  }

  // 🔥 Fetch current user's playlist
  Future<void> fetchUserPlaylist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('playlist')
              .get();

      final songs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return <String, String>{
              "title": data['title']?.toString() ?? 'Unknown',
              "artist": data['artist']?.toString() ?? 'Unknown',
              "image":
                  data['image']?.toString() ??
                  'https://picsum.photos/seed/${data['title']}/200/200',
              "preview": data['preview']?.toString() ?? "",
            };
          }).toList();

      setState(() {
        userPlaylist = songs;
        isLoading = false;
      });
    } catch (e) {
      log("Error fetching user playlist: $e");
      setState(() => isLoading = false);
    }
  }

  // 🤖 Fetch AI suggestions from Firestore
  Future<void> fetchAISuggestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('ai_suggestions')
              .doc(user.uid)
              .collection('generated_playlists')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final songs =
            (data['songs'] as List).map<Map<String, String>>((song) {
              final songMap = Map<String, dynamic>.from(song);
              return {
                'title': songMap['title']?.toString() ?? 'Unknown',
                'artist': songMap['artist']?.toString() ?? 'Unknown',
                'image':
                    songMap['image']?.toString() ??
                    'https://picsum.photos/seed/${songMap['title']}/200/200',
                'preview': songMap['preview']?.toString() ?? '',
              };
            }).toList();

        setState(() {
          aiSuggestions = songs;
          isAISuggestionsLoading = false;
        });
      } else {
        setState(() => isAISuggestionsLoading = false);
      }
    } catch (e) {
      log("Error fetching AI suggestions: $e");
      setState(() => isAISuggestionsLoading = false);
    }
  }

  // 🔍 Search songs via iTunes API
  Future<void> searchSongs(String query) async {
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=${Uri.encodeComponent(query)}&entity=song&limit=10',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)['results'] as List;
      setState(() {
        searchResults =
            results.map<Map<String, String>>((song) {
              return {
                "title": song["trackName"] ?? "Unknown",
                "artist": song["artistName"] ?? "Unknown",
                "image": song["artworkUrl100"] ?? "",
                "preview": song["previewUrl"] ?? "",
              };
            }).toList();
      });
    }
  }

  // ▶️ Play / Pause song preview
  void playSong(String previewUrl) async {
    if (isPlaying && currentPreviewUrl == previewUrl) {
      await _player.pause();
      setState(() => isPlaying = false);
    } else {
      await _player.play(UrlSource(previewUrl));
      setState(() {
        isPlaying = true;
        currentPreviewUrl = previewUrl;
      });
    }
  }

  // ➕ Add song to user's playlist in Firestore
  Future<void> addSongToUserPlaylist(Map<String, String> song) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('playlist')
          .add(song);

      fetchUserPlaylist();

      showAppSnackBar(
        context,
        message: "${song['title']} added to your playlist!",
      );
    } catch (e) {
      log("Error adding song to user playlist: $e");
    }
  }

  // 🔍 Fetch preview URL if missing
  Future<String?> fetchPreviewUrl(String title, String artist) async {
    final query = Uri.encodeComponent("$title $artist");
    final url = Uri.parse(
      'https://itunes.apple.com/search?term=$query&entity=song&limit=1',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)['results'] as List;
      if (results.isNotEmpty) {
        return results.first['previewUrl'] as String?;
      }
    }
    return null;
  }

  // 🔹 Widget for song item (search, AI suggestions)
  Widget songTile(Map<String, String> song) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(2.w),
          child: Image.network(
            song["image"]!,
            height: 13.w,
            width: 13.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/default_song.webp',
                height: 13.w,
                width: 13.w,
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        title: Text(
          song["title"]!,
          style: GoogleFonts.inter(
            color: textLight,
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
        ),
        subtitle: Text(
          song["artist"]!,
          style: GoogleFonts.inter(
            color: textLight.withOpacity(0.7),
            fontSize: 13.sp,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause button
            IconButton(
              icon: Icon(
                (isPlaying && currentPreviewUrl == song["preview"])
                    ? Icons.pause_circle
                    : Icons.play_circle,
                color: primary,
                size: 7.w,
              ),
              onPressed: () async {
                String? previewUrl = song["preview"];
                if (previewUrl == null || previewUrl.isEmpty) {
                  previewUrl = await fetchPreviewUrl(
                    song["title"]!,
                    song["artist"]!,
                  );
                  if (previewUrl != null) song["preview"] = previewUrl;
                }
                if (previewUrl != null && previewUrl.isNotEmpty) {
                  playSong(previewUrl);
                } else {
                  showAppSnackBar(context, message: "Preview not available");
                }
              },
            ),
            // Add button
            IconButton(
              icon: Icon(Icons.add, color: primary),
              onPressed: () => addSongToUserPlaylist(song),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            centerTitle: true,
            title: Text(
              "Playlist",
              style: GoogleFonts.quicksand(
                color: textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search bar
                  TextField(
                    controller: _searchController,
                    onSubmitted: (value) => searchSongs(value),
                    decoration: InputDecoration(
                      hintText: "Search for a song...",
                      hintStyle: GoogleFonts.quicksand(color: Colors.white70),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: textLight),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 2.h),

                  // 🎧 Search Results
                  if (searchResults.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Search Results",
                          style: GoogleFonts.quicksand(
                            color: textLight,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Column(children: searchResults.map(songTile).toList()),
                        SizedBox(height: 3.h),
                      ],
                    ),

                  // 🌀 Loading
                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(3.h),
                        child: CircularProgressIndicator(color: primary),
                      ),
                    ),

                  // 🎵 Current User Playlist
                  if (!isLoading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Playlist",
                          style: GoogleFonts.quicksand(
                            color: textLight,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        if (userPlaylist.isEmpty)
                          Text(
                            "No songs yet! Add from search or AI suggestions.",
                            style: GoogleFonts.quicksand(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          )
                        else
                          Column(children: userPlaylist.map(songTile).toList()),
                        SizedBox(height: 3.h),
                      ],
                    ),

                  // 🤖 AI Suggestions
                  Text(
                    "AI Suggestions",
                    style: GoogleFonts.quicksand(
                      color: textLight,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  if (isAISuggestionsLoading)
                    Center(child: CircularProgressIndicator(color: primary))
                  else if (aiSuggestions.isEmpty)
                    Text(
                      "No AI suggestions yet.",
                      style: GoogleFonts.quicksand(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                    )
                  else
                    Column(children: aiSuggestions.map(songTile).toList()),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
