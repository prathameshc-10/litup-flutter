import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/bottom_navigation_screen.dart';
import 'package:sizer/sizer.dart';

class ConfirmedPartyScreen extends StatefulWidget {
  const ConfirmedPartyScreen({super.key});

  @override
  State<ConfirmedPartyScreen> createState() => _ConfirmedPartyScreenState();
}

class _ConfirmedPartyScreenState extends State<ConfirmedPartyScreen> {
  final List<Map<String, dynamic>> users = [
    {
      "heading": "Neon Nights Rave",
      "description": "Friday, July 2024",
      "icon": Icons.calendar_month_outlined,
    },
    {
      "heading": "Time",
      "description": "9:00 PM - Late",
      "icon": Icons.lock_clock_outlined,
    },
    {
      "heading": "Location",
      "description": "Warehouse District, Downtown",
      "icon": Icons.location_on_outlined,
    },
    {
      "heading": "Track RSVPs",
      "description": "",
      "icon": Icons.chat_bubble_outline,
    },
  ];

  TextStyle get headingStyle => GoogleFonts.quicksand(
    color: Colors.white,
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );

  TextStyle get descStyle => GoogleFonts.inter(
    color: const Color.fromRGBO(160, 160, 160, 1),
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      appBar: AppBar(
        leading: IconButton(
          onPressed:
              () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) {
                    return BottomNavigationScreen();
                  },
                ),
                (route) => false,
              ),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text("Create Party", style: headingStyle),
        backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Party Created!",
              style: GoogleFonts.quicksand(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.sp),
            Text(
              "Review the details below and confirm to send out the invites.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color.fromRGBO(160, 160, 160, 1),
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.sp),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.sp),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 29.sp,
                          width: 29.sp,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(83, 17, 150, 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            users[index]["icon"],
                            color: const Color.fromRGBO(180, 90, 255, 1),
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              users[index]["heading"],
                              style: GoogleFonts.quicksand(
                                color: Colors.white,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (users[index]["description"]!.isNotEmpty)
                              Text(
                                users[index]["description"],
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: Color.fromRGBO(160, 160, 160, 1),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 15.sp),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(33, 24, 48, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color.fromRGBO(90, 50, 140, 1),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        "Edit",
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Confirm & Invite",
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.sp),
          ],
        ),
      ),
    );
  }
}
