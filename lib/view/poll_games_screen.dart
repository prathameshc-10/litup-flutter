import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

class PollsGamesScreen extends StatefulWidget {
  final String partyId;
  const PollsGamesScreen({super.key, required this.partyId});

  @override
  State<PollsGamesScreen> createState() => _PollsGamesScreenState();
}

class _PollsGamesScreenState extends State<PollsGamesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final List<Map<String, String>> games = [
    {
      "title": "Truth or Dare",
      "desc": "A classic party game.",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCCgJ0ylqkKsnDo2G1fAHPGyRK9HBY09w2fzCbiuye1qBVNeqgdT6PE3Teiw_fwmfuw5uu85xEM2Mjo3cGCpo0zhuzP8gRYo9edak35ouXjq42fgsXQkdd3jNskdOBkose_Bb8XxOiExmKatM8nQhExnODahgdzNwxon4eOXkjONp3V3hG7Nj3QskWC5lTnKBTwpImaJsim3JACRK1_S7NTE-FWRaziRb5I7__s-b122hM70TsBdkwFtOucA4edyFxRlQATIQtUtusP",
    },
    {
      "title": "Quick Quiz",
      "desc": "Test your knowledge.",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuA7y7toa8q7w3wwZmzl9lwCd5X2z2iNeB52RjF7qHNEPu2cZdD6Dyq14E1-LHRMReYk0p7QVVXZNc-kB1wI_YTzLLJ8OhUgaVMk4UfOsLqDrJIN_WS5aFOuCxVyvQvYGA-nB-ZwIEvkfnyo3085QuzNhb6d2Y3_hHapMsLmgHeX3yEt9K2tLxdlwHM4JaGeTqa_2REp2dvST1QkWUDRtPTpO5jpBT30RQL1KxQo3oibUdjTlgKg88vnlHDjYX7XQBHQ-VczBoBdYWjG",
    },
    {
      "title": "Dice Roll",
      "desc": "Roll dice for fun challenges",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuCCgJ0ylqkKsnDo2G1fAHPGyRK9HBY09w2fzCbiuye1qBVNeqgdT6PE3Teiw_fwmfuw5uu85xEM2Mjo3cGCpo0zhuzP8gRYo9edak35ouXjq42fgsXQkdd3jNskdOBkose_Bb8XxOiExmKatM8nQhExnODahgdzNwxon4eOXkjONp3V3hG7Nj3QskWC5lTnKBTwpImaJsim3JACRK1_S7NTE-FWRaziRb5I7__s-b122hM70TsBdkwFtOucA4edyFxRlQATIQtUtusP",
    },
    {
      "title": "Would You Rather",
      "desc": "Choose wisely!",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuA7y7toa8q7w3wwZmzl9lwCd5X2z2iNeB52RjF7qHNEPu2cZdD6Dyq14E1-LHRMReYk0p7QVVXZNc-kB1wI_YTzLLJ8OhUgaVMk4UfOsLqDrJIN_WS5aFOuCxVyvQvYGA-nB-ZwIEvkfnyo3085QuzNhb6d2Y3_hHapMsLmgHeX3yEt9K2tLxdlwHM4JaGeTqa_2REp2dvST1QkWUDRtPTpO5jpBT30RQL1KxQo3oibUdjTlgKg88vnlHDjYX7XQBHQ-VczBoBdYWjG",
    },
    {
      "title": "Spin the Bottle",
      "desc": "Virtual spin with random outcomes",
      "img":
          "https://lh3.googleusercontent.com/aida-public/AB6AXuA7y7toa8q7w3wwZmzl9lwCd5X2z2iNeB52RjF7qHNEPu2cZdD6Dyq14E1-LHRMReYk0p7QVVXZNc-kB1wI_YTzLLJ8OhUgaVMk4UfOsLqDrJIN_WS5aFOuCxVyvQvYGA-nB-ZwIEvkfnyo3085QuzNhb6d2Y3_hHapMsLmgHeX3yEt9K2tLxdlwHM4JaGeTqa_2REp2dvST1QkWUDRtPTpO5jpBT30RQL1KxQo3oibUdjTlgKg88vnlHDjYX7XQBHQ-VczBoBdYWjG",
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleVote(int pollIndex, int optionIndex) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final partyRef = FirebaseFirestore.instance
          .collection('parties')
          .doc(widget.partyId);

      final doc = await partyRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final polls = List<Map<String, dynamic>>.from(data['polls'] ?? []);

      final poll = polls[pollIndex];
      final votes = List<int>.from(
        poll['votes'] ?? List.filled(poll['options'].length, 0),
      );

      // Track voters
      final votedUsers = List<String>.from(poll['votedUsers'] ?? []);

      // Prevent double voting
      if (votedUsers.contains(user.uid)) {
        print("User has already voted in this poll!");
        showAppSnackBar(
          context,
          message: 'You have already voted in this poll!',
          backgroundColor: Colors.red,
        );
        return;
      }

      // Count the vote
      votes[optionIndex] += 1;
      poll['votes'] = votes;
      votedUsers.add(user.uid);
      poll['votedUsers'] = votedUsers;
      polls[pollIndex] = poll;

      await partyRef.update({'polls': polls});
    } catch (e) {
      print('Error voting: $e');
    }
  }

  Widget _pollCard(Map<String, dynamic> poll, int pollIndex) {
    final question = poll['question'] ?? 'No question';
    final options = List<String>.from(poll['options'] ?? []);
    final votes = List<int>.from(poll['votes'] ?? []);
    final totalVotes = votes.isNotEmpty ? votes.reduce((a, b) => a + b) : 1;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.quicksand(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            for (int i = 0; i < options.length; i++)
              GestureDetector(
                onTap: () => _handleVote(pollIndex, i),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: _voteBar(
                    options[i],
                    votes.isNotEmpty ? votes[i] / totalVotes : 0.0,
                    votes.isNotEmpty ? votes[i] : 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _voteBar(String title, double value, int votes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: textLight,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: GoogleFonts.inter(
                color: textLight,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(2.w),
          child: Stack(
            children: [
              Container(height: 0.7.h, color: Colors.grey[800]),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                height: 0.7.h,
                width: MediaQuery.of(context).size.width * value * 0.8,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2.w),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          "$votes votes",
          style: GoogleFonts.inter(
            color: Colors.grey,
            fontSize: 14.sp,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // Mini-Games
  void _playTruthOrDare() {
    final truths = [
      "What is your biggest fear?",
      "Who is your crush?",
      "Have you ever lied to your best friend?",
      "What is your most embarrassing moment?",
      "Have you ever cheated in a game?",
      "Who do you secretly admire?",
      "What is a secret talent you have?",
      "Have you ever had a crush on a teacher?",
      "What is your weirdest habit?",
      "Which celebrity would you like to meet?",
    ];

    final dares = [
      "Dance for 30 seconds.",
      "Sing your favorite song loudly.",
      "Do 10 push-ups.",
      "Spin around 5 times and walk straight.",
      "Imitate someone in the room.",
      "Do a funny face for 10 seconds.",
      "Do 5 jumping jacks.",
      "Act like a chicken for 15 seconds.",
      "Touch your toes 5 times.",
      "Hop on one leg 10 times.",
    ];

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              "Truth or Dare",
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final prompt = truths..shuffle();
                    Navigator.pop(ctx);
                    _showGamePrompt("Truth", prompt.first);
                  },
                  child: Text("Truth"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final prompt = dares..shuffle();
                    Navigator.pop(ctx);
                    _showGamePrompt("Dare", prompt.first);
                  },
                  child: Text("Dare"),
                ),
              ],
            ),
          ),
    );
  }

  void _playQuickQuiz() {
    final questions = [
      {
        "q": "Capital of France?",
        "options": ["Paris", "London", "Berlin", "Rome"],
        "answer": "Paris",
      },
      {
        "q": "5 + 7 = ?",
        "options": ["10", "12", "11", "14"],
        "answer": "12",
      },
      {
        "q": "Largest planet in our Solar System?",
        "options": ["Earth", "Mars", "Jupiter", "Saturn"],
        "answer": "Jupiter",
      },
      {
        "q": "Which element has the chemical symbol O?",
        "options": ["Oxygen", "Gold", "Osmium", "Silver"],
        "answer": "Oxygen",
      },
      {
        "q": "Who wrote 'Romeo and Juliet'?",
        "options": ["Shakespeare", "Hemingway", "Tolstoy", "Dickens"],
        "answer": "Shakespeare",
      },
      {
        "q": "Fastest land animal?",
        "options": ["Cheetah", "Lion", "Horse", "Tiger"],
        "answer": "Cheetah",
      },
      {
        "q": "Square root of 64?",
        "options": ["6", "7", "8", "9"],
        "answer": "8",
      },
      {
        "q": "Water freezes at ___°C?",
        "options": ["0", "32", "100", "-1"],
        "answer": "0",
      },
      {
        "q": "Currency of Japan?",
        "options": ["Yen", "Dollar", "Euro", "Rupee"],
        "answer": "Yen",
      },
      {
        "q": "Largest ocean?",
        "options": ["Atlantic", "Indian", "Arctic", "Pacific"],
        "answer": "Pacific",
      },
    ];

    questions.shuffle();
    _showQuizQuestion(questions.first);
  }

  void _playDiceChallenge() {
    final challenges = [
      "Do 10 squats",
      "Sing a line of your favorite song",
      "Spin around 5 times",
      "High-five someone next to you",
      "Do 5 jumping jacks",
      "Act like a chicken for 15 seconds",
      "Touch your toes 5 times",
      "Hop on one leg 10 times",
      "Make a funny face",
      "Do a silly dance",
    ];

    final roll = Random().nextInt(6) + 1;
    final challenge = challenges[Random().nextInt(challenges.length)];

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              "Dice Roll: $roll",
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            content: Text(
              challenge,
              style: GoogleFonts.inter(color: textLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: GoogleFonts.inter(color: primary)),
              ),
            ],
          ),
    );
  }

  void _playWouldYouRather() {
    final questions = [
      "Would you rather fly or be invisible?",
      "Would you rather be rich or famous?",
      "Would you rather live in the mountains or the beach?",
      "Would you rather have super strength or super speed?",
      "Would you rather never use social media or never watch TV?",
      "Would you rather eat only pizza or only burgers for a week?",
      "Would you rather be a superhero or a villain?",
      "Would you rather read minds or see the future?",
      "Would you rather always be hot or always be cold?",
      "Would you rather travel to space or under the sea?",
    ];

    questions.shuffle();
    final question = questions.first;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              "Would You Rather",
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            content: Text(question, style: GoogleFonts.inter(color: textLight)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: GoogleFonts.inter(color: primary)),
              ),
            ],
          ),
    );
  }

  void _showGamePrompt(String type, String prompt) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              type,
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            content: Text(prompt, style: GoogleFonts.inter(color: textLight)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: GoogleFonts.inter(color: primary)),
              ),
            ],
          ),
    );
  }

  void _showQuizQuestion(Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              question["q"],
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                question["options"].length,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: ElevatedButton(
                    onPressed: () {
                      final correct =
                          question["options"][i] == question["answer"];
                      Navigator.pop(context);
                      showAppSnackBar(
                        context,
                        message:
                            correct
                                ? "Correct!"
                                : "Wrong! Correct: ${question['answer']}",
                        backgroundColor: correct ? Colors.green : Colors.red,
                      );
                    },
                    child: Text(question["options"][i]),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _playSpinTheBottle() async {
    try {
      // Get members from the party document
      final partyDoc =
          await FirebaseFirestore.instance
              .collection('parties')
              .doc(widget.partyId)
              .get();

      if (!partyDoc.exists) {
        showAppSnackBar(
          context,
          message: "Party not found!",
          backgroundColor: Colors.red,
        );
        return;
      }

      final List<dynamic> memberIds = partyDoc.data()?['members'] ?? [];

      if (memberIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No players found in this party!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Fetch usernames for all members in one go
      List<String> players = [];
      if (memberIds.length <= 10) {
        // Firestore whereIn supports max 10 IDs per query
        final usersSnap =
            await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: memberIds)
                .get();

        players =
            usersSnap.docs
                .map((d) => d.data()['username'] ?? 'Unknown')
                .cast<String>()
                .toList();
      } else {
        // For more than 10 members, split into chunks
        final chunks = <List<dynamic>>[];
        for (var i = 0; i < memberIds.length; i += 10) {
          chunks.add(
            memberIds.sublist(
              i,
              i + 10 > memberIds.length ? memberIds.length : i + 10,
            ),
          );
        }

        for (final chunk in chunks) {
          final usersSnap =
              await FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: chunk)
                  .get();

          players.addAll(
            usersSnap.docs
                .map((d) => d.data()['username'] ?? 'Unknown')
                .cast<String>(),
          );
        }
      }

      // Show the FortuneWheel dialog
      showDialog(
        context: context,
        builder: (_) {
          final controller = StreamController<int>();
          int? selectedIndex;

          return AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              "Spin the Bottle",
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 300,
              child: FortuneWheel(
                selected: controller.stream,
                items: [
                  for (var player in players)
                    FortuneItem(
                      child: Center(
                        child: Text(
                          player,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
                onAnimationEnd: () {
                  if (selectedIndex != null) {
                    final winner = players[selectedIndex!];
                    showAppSnackBar(
                      context,
                      message: "Bottle points to: $winner!",
                      backgroundColor: Colors.green,
                    );
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final spinIndex = Random().nextInt(players.length);
                  selectedIndex = spinIndex;
                  controller.add(spinIndex);
                },
                child: Text("Spin", style: GoogleFonts.inter(color: primary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.close();
                },
                child: Text("Close", style: GoogleFonts.inter(color: primary)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showAppSnackBar(
        context,
        message: "Error loading players",
        backgroundColor: Colors.red,
      );
      print("Error: $e");
    }
  }

  // Game Card
  Widget _gameCard(Map<String, String> game) {
    return ScaleTransition(
      scale: _fadeIn,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(3.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.w),
            color: cardColor,
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.15), blurRadius: 12),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                child: Image.network(
                  game["img"]!,
                  height: 20.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 20.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 1.5.h,
                left: 3.w,
                right: 3.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game["title"]!,
                      style: GoogleFonts.quicksand(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      game["desc"]!,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ElevatedButton(
                      onPressed: () {
                        final title = game["title"];
                        if (title == "Truth or Dare") {
                          _playTruthOrDare();
                        } else if (title == "Quick Quiz") {
                          _playQuickQuiz();
                        } else if (title == "Dice Roll") {
                          _playDiceChallenge();
                        } else if (title == "Would You Rather") {
                          _playWouldYouRather();
                        } else if (title == "Spin the Bottle") {
                          _playSpinTheBottle();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: primary.withValues(alpha: 0.6),
                        elevation: 10,
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                      child: Center(
                        child: Text(
                          "Play Now",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textLight, size: 16.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Polls & Games",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            color: textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Polls 📊",
                style: GoogleFonts.quicksand(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textLight,
                ),
              ),
              SizedBox(height: 2.h),
              StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('parties')
                        .doc(widget.partyId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading polls',
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final polls = List<Map<String, dynamic>>.from(
                    data?['polls'] ?? [],
                  );

                  if (polls.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Text(
                          "No polls yet!",
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      polls.length,
                      (index) => _pollCard(polls[index], index),
                    ),
                  );
                },
              ),
              SizedBox(height: 3.h),
              Text(
                "Mini-Games 🎲",
                style: GoogleFonts.quicksand(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textLight,
                ),
              ),
              SizedBox(height: 2.h),
              GridView.builder(
                itemCount: games.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 3.w,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) => _gameCard(games[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
