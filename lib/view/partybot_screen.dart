import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:litup/controller/secrets.dart';
import 'package:litup/services/playlist_service.dart';
import 'package:sizer/sizer.dart';

class PartyBotScreen extends StatefulWidget {
  final bool fromDashboard;
  const PartyBotScreen({super.key, this.fromDashboard = false});

  @override
  State<PartyBotScreen> createState() => _PartyBotScreenState();
}

class _PartyBotScreenState extends State<PartyBotScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "sender": "bot",
      "text":
          "Hey there! I'm PartyBot, your AI assistant for all things party planning. How can I help you today?",
    },
  ];

  final List<Map<String, String>> features = [
    {
      "title": "AI Playlist",
      "subtitle": "Generate a Playlist",
      "desc": "Create a custom playlist based on your party theme.",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuDGtHnKjuxcJOtWZM00amr3mE72hkFF81pteU3r32C12EumEmcnuktm_xaNHG8DwAx2Bk1XXrPX35ugY-0zyIwrPbXw0x5169Ny57uY78V9Rub7UNpCAuOS8qCLRe7iwq7jvV8Vnf3xUR68hsXLlXYTIPKyuCpudKHvpw9nJkZc3OdLgaV5ZLba9RHaSvGmogmvbL70gGCvk8skDqCWWpJGJt3K2_B2MkvbDMJmidFr5R58XXbdyUOxuf9aH8awdXX8FrIFfzmici_O",
    },
    {
      "title": "AI Theme & Decor",
      "subtitle": "Get Theme & Decor Suggestions",
      "desc": "Receive creative ideas for your party's theme.",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuANaj9Ut4uiISoWaIM4ICAR7LxWwu3i0KvRk8ZMXPbKyIbv2AQtveLFcMiI6BFaQFESDUbxT1rydlaQgtc6pRqdOpuLWoRVW0PDJFCY6g9U0IdL4yLdAg-Joy0ZknZiEnBMNntW1cC-kqZl1GSkiCzh-OtdNo_JPtEHvcO76jajD_V1_QSxMl3t8I_EWzzfOkV_cugrrHQXPU5nVtht3ZR5odTjJQ6Ke9o9_wYZSsCY_pSRGCHMl_Hnwzfh1GQ3bRP87auPEnplILvH",
    },
  ];

  final PlaylistService _playlistService = PlaylistService();
  final String geminiContext = '''
You are PartyBot — the official AI of **LitUp**, a social party app that helps users discover, create, and join house parties. 
Your job is to make every party more fun by:
- suggesting playlists, drinks, decorations, and party games 🎶🥂🎈
- chatting casually with users about their party vibe
- creating themed playlists or fun ideas when asked

🪩 Personality:
You are energetic, witty, and concise. Keep answers short, sweet, and fun — like a friendly party DJ. 
Avoid being too formal or robotic. Always keep replies under 2 sentences unless asked for a detailed list.
If the user mentions “playlist” or “music”, suggest 3-5 songs that match the vibe.

Your context:
LitUp users can:
- create or join parties
- view a shared playlist page where songs can be played
- chat with PartyBot for creative ideas

You are aware of these features but do not reveal internal app details.
Just focus on helping them have a great party!
''';

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    setState(() {
      messages.add({"sender": "user", "text": userText});
      _controller.clear();
    });

    try {
      // Initialize Gemini model
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: geminiApiKey,
        systemInstruction: Content.text(geminiContext),
      );

      // Send the message
      final content = [Content.text(userText)];
      final response = await model.generateContent(content);

      // Get the AI's text
      final aiText = response.text ?? "Hmm... I couldn't think of anything 😅";

      setState(() {
        messages.add({"sender": "bot", "text": aiText});
      });
    } catch (e) {
      log("Error: $e");
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "Oops! Something went wrong. Please try again later.",
        });
      });
    }
  }

  void _sendMessageFromFeature(String prompt) async {
    setState(() {
      messages.add({"sender": "user", "text": prompt});
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: geminiApiKey,
        systemInstruction: Content.text(geminiContext),
      );

      final response = await model.generateContent([
        Content.text("${prompt} one per line"),
      ]);
      final aiText = response.text ?? "Hmm... I couldn't think of anything 😅";

      // Check if message likely contains a playlist
      if (aiText.toLowerCase().contains("song") ||
          aiText.toLowerCase().contains("track") ||
          aiText.toLowerCase().contains("playlist") ||
          aiText.contains("•") ||
          aiText.contains("-")) {
        // Parse AI text into song entries
        final List<Map<String, String>> parsedSongs = [];
        final lines = aiText.split('\n');
        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty) continue;

          // Example: "1. Blinding Lights - The Weeknd"
          final parts = line.split(RegExp(r'[--]'));
          if (parts.length >= 2) {
            parsedSongs.add({
              "title": parts[0].replaceAll(RegExp(r'^[\*\-\d.\s]+'), '').trim(),
              "artist": parts[1].trim(),
            });
          }
        }

        if (parsedSongs.isNotEmpty) {
          await _playlistService.saveAiPlaylist(parsedSongs, prompt);
        }
      }

      setState(() {
        messages.add({"sender": "bot", "text": aiText});
      });
    } catch (e) {
      log("Error: $e");
      setState(() {
        messages.add({
          "sender": "bot",
          "text": "Oops! Something went wrong. Please try again later.",
        });
      });
    }
  }

  dynamic textStyle() {
    return GoogleFonts.quicksand(
      color: Colors.white,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color.fromRGBO(83, 17, 150, 1);
    const Color background = Color.fromRGBO(24, 15, 33, 1);
    const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
    const Color textLight = Color.fromRGBO(217, 217, 217, 1);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        leading:
            widget.fromDashboard
                ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                )
                : null,
        title: Text("PartyBot", style: textStyle()),
        backgroundColor: Color.fromRGBO(24, 15, 33, 1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: messages.length + 1,
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  // AI Features section
                  return Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Features",
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        ...features.map(
                          (feature) => Container(
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (feature["title"] == "AI Playlist") {
                                  _sendMessageFromFeature(
                                    "Generate a fun party playlist with 5-10 songs. Include artist names.",
                                  );
                                } else if (feature["title"] ==
                                    "AI Theme & Decor") {
                                  _sendMessageFromFeature(
                                    "Give me 5-10 quick party theme ideas.",
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            feature["title"]!,
                                            style: GoogleFonts.inter(
                                              fontSize: 17.sp,
                                              color: primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            feature["subtitle"]!,
                                            style: GoogleFonts.quicksand(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            feature["desc"]!,
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              color: textLight.withValues(
                                                alpha: 0.7,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        feature["img"]!,
                                        width: 22.w,
                                        height: 12.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final msg = messages[index];
                bool isUser = msg["sender"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    padding: EdgeInsets.all(3.w),
                    constraints: BoxConstraints(maxWidth: 80.w),
                    decoration: BoxDecoration(
                      color: isUser ? primary : cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft:
                            isUser ? const Radius.circular(12) : Radius.zero,
                        bottomRight:
                            isUser ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              // color: cardColor,
              color: background,
              border: Border(
                top: BorderSide(
                  color: primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Message PartyBot...",
                      hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Color.fromRGBO(46, 18, 73, 1),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.2.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
