import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/confirm_party_screen.dart';
import 'package:sizer/sizer.dart';

class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  final List<Map<String, dynamic>> users = [
    {
      "name": "Emma Wilson",
      "username": "@emma.wilson",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/female-user-image-illustration-svg-download-png-6515859.png",
      "icon": Icons.check_box_outline_blank,
    },
    {
      "name": "Liam Evans",
      "username": "@liam.evans",
      "image": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
      "icon": Icons.check_box,
    },
    {
      "name": "Olivia Clark",
      "username": "@olivia.clark",
      "image": "https://cdn-icons-png.freepik.com/512/17735/17735516.png",
      "icon": Icons.check_box_outline_blank,
    },
    {
      "name": "Noah Baker",
      "username": "@noah.baker",
      "image": "https://cdn-icons-png.flaticon.com/512/5234/5234205.png",
      "icon": Icons.check_box,
    },
    {
      "name": "Isabella Hall",
      "username": "@isabella.hall",
      "image": "https://cdn-icons-png.flaticon.com/256/3135/3135789.png",
      "icon": Icons.check_box_outline_blank,
    },
    {
      "name": "Jackson Carter",
      "username": "@jackson.carter",
      "image": "https://cdn-icons-png.flaticon.com/512/7077/7077313.png",
      "icon": Icons.check_box,
    },
  ];
  dynamic textStyle() {
    return GoogleFonts.quicksand(
      color: Colors.white,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(24, 15, 33, 1),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text("Invite Friends", style: textStyle()),
        backgroundColor: Color.fromRGBO(24, 15, 33, 1),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(33, 24, 48, 1),
                hintText: "Search Friends",
                prefixIcon: Icon(Icons.search),
                hintStyle: GoogleFonts.inter(
                  color: Color.fromRGBO(160, 160, 160, 1),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(90, 50, 140, 1),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(180, 90, 255, 1),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18.sp,
                  vertical: 14.sp,
                ),
              ),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              cursorColor: Color.fromRGBO(180, 90, 255, 1),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 70,
                          width: 70,
                          child: Image.network(
                            users[index]["image"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              users[index]["name"]!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              users[index]["username"]!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            users[index]["icon"],
                            color: Colors.deepPurple,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                //handle condition
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ConfirmedPartyScreen();
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100.w, 6.h),
                backgroundColor: Color.fromRGBO(83, 17, 150, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(13),
              ),
              child: Text(
                "Invite",
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                //handle condition
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100.w, 6.h),
                backgroundColor: Color.fromRGBO(83, 17, 150, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(13),
              ),
              child: Text(
                "Share Link",
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
