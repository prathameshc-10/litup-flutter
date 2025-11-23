import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:litup/services/party_service.dart';
import 'package:litup/view/party_code_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

class CreateParty extends StatefulWidget {
  const CreateParty({super.key});

  @override
  State<CreateParty> createState() => _CreatePartyState();
}

class _CreatePartyState extends State<CreateParty> {
  TextEditingController dateController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController themeController = TextEditingController();
  TextEditingController pollQuestionController = TextEditingController();
  List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  File? _posterFile;
  List<Map<String, dynamic>> polls = [];
  bool _loading = false;
  bool showPollSection = false;

  final _partyService = PartyService();

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon:
          icon != null ? Icon(icon, color: Colors.purpleAccent.shade100) : null,
      hintStyle: GoogleFonts.inter(
        color: Colors.grey.shade400,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color.fromRGBO(33, 24, 48, 1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.deepPurple.shade700, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color.fromRGBO(180, 90, 255, 1),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _posterFile = File(picked.path);
      });
    }
  }

  void _addPoll() {
    if (pollQuestionController.text.isEmpty ||
        optionControllers.any((c) => c.text.isEmpty)) {
      showAppSnackBar(
        context,
        message: "Please complete poll question and options",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      polls.add({
        'question': pollQuestionController.text,
        'options': optionControllers.map((c) => c.text).toList(),
      });
      pollQuestionController.clear();
      optionControllers = [TextEditingController(), TextEditingController()];
    });

    showAppSnackBar(context, message: "Poll added!");
  }

  void _addOptionField() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void _removeOptionField(int index) {
    if (optionControllers.length > 2) {
      setState(() {
        optionControllers.removeAt(index);
      });
    } else {
      showAppSnackBar(context, message: "A poll must have at least 2 options", backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Create Party",
          style: GoogleFonts.quicksand(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Party Name
            TextField(
              controller: nameController,
              textAlign: TextAlign.start,
              decoration: _inputDecoration(
                "Party Name",
                icon: Icons.celebration_outlined,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // Date
            TextField(
              controller: dateController,
              readOnly: true,
              textAlign: TextAlign.start,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color.fromRGBO(180, 90, 255, 1),
                          onPrimary: Colors.white,
                          surface: Color.fromRGBO(33, 24, 48, 1),
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    dateController.text = DateFormat.yMMMMd().format(
                      pickedDate,
                    );
                  });
                }
              },
              decoration: _inputDecoration(
                "Select Date",
                icon: Icons.calendar_month_outlined,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // Location
            TextField(
              controller: locationController,
              textAlign: TextAlign.start,
              decoration: _inputDecoration(
                "Location",
                icon: Icons.location_on_outlined,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),

            // Theme
            TextField(
              controller: themeController,
              textAlign: TextAlign.start,
              decoration: _inputDecoration(
                "Theme",
                icon: Icons.palette_outlined,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Poster Upload
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text(
                _posterFile == null ? "Upload Party Poster" : "Change Poster",
                style: GoogleFonts.quicksand(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(100.w, 6.h),
              ),
            ),
            if (_posterFile != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_posterFile!, height: 150, fit: BoxFit.cover),
              ),
            ],

            const SizedBox(height: 25),

            // Collapsible Poll Section Header
            GestureDetector(
              onTap: () {
                setState(() {
                  showPollSection = !showPollSection;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(33, 24, 48, 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showPollSection ? "Hide Poll Section" : "Add Poll",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      showPollSection
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  showPollSection
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    TextField(
                      controller: pollQuestionController,
                      textAlign: TextAlign.start,
                      decoration: _inputDecoration(
                        "Enter poll question",
                        icon: Icons.question_mark_outlined,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(optionControllers.length, (
                        index,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: optionControllers[index],
                                  textAlign: TextAlign.start,
                                  decoration: _inputDecoration(
                                    "Option ${index + 1}",
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _removeOptionField(index),
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addOptionField,
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.purpleAccent,
                        ),
                        label: const Text(
                          "Add Option",
                          style: TextStyle(color: Colors.purpleAccent),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addPoll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(100.w, 5.5.h),
                      ),
                      child: const Text(
                        "Save Poll",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox(),
            ),

            const SizedBox(height: 20),

            // Display Added Polls
            if (polls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Added Polls:",
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...polls.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> poll = entry.value;
                    return Card(
                      color: const Color.fromRGBO(33, 24, 48, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    poll['question'],
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      polls.removeAt(index);
                                    });
                                    showAppSnackBar(context, message: "Poll deleted!");
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...poll['options'].map<Widget>(
                              (opt) => Text(
                                "• $opt",
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade300,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),

            const SizedBox(height: 30),

            // Create Party Button
            ElevatedButton(
              onPressed:
                  _loading
                      ? null
                      : () async {
                        if (_posterFile == null) {
                          showAppSnackBar(context, message: "Please upload a poster", backgroundColor: Colors.red);
                          return;
                        }
                        setState(() => _loading = true);
                        try {
                          final code = await _partyService.createParty(
                            name: nameController.text.trim(),
                            date: dateController.text.trim(),
                            location: locationController.text.trim(),
                            theme: themeController.text.trim(),
                            posterFile: _posterFile!,
                            polls: polls,
                          );
                          showAppSnackBar(context, message: 'Party created! Code: $code');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PartyCodeScreen(code: code),
                            ),
                          );
                        } catch (e) {
                          showAppSnackBar(context, message: 'Error ocurred', backgroundColor: Colors.red);
                          log("Error: ${e.toString()}");
                        } finally {
                          setState(() => _loading = false);
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(115, 40, 200, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: Size(100.w, 6.5.h),
              ),
              child:
                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        "Create Party",
                        style: GoogleFonts.quicksand(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
