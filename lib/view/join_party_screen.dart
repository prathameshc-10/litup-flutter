import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/services/party_service.dart';
import 'package:litup/view/join_party_confirmation.dart';
import 'package:litup/view/qr_scan_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

class JoinPartyScreen extends StatefulWidget {
  const JoinPartyScreen({super.key});

  @override
  State<JoinPartyScreen> createState() => _JoinPartyScreenState();
}

class _JoinPartyScreenState extends State<JoinPartyScreen> {
  TextEditingController codeController = TextEditingController();

  dynamic textStyle() {
    return GoogleFonts.quicksand(
      color: Colors.white,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    );
  }

  final PartyService _partyService = PartyService();
  bool _loading = false;

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
        title: Text("Join Party", style: textStyle()),
        backgroundColor: Color.fromRGBO(24, 15, 33, 1),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromRGBO(33, 24, 48, 1),
                  hintText: "Enter Party Code",
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
              const SizedBox(height: 20),
              Text(
                "OR",
                style: GoogleFonts.quicksand(
                  color: Color.fromRGBO(90, 50, 140, 1),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => QRScanScreen(
                            onCodeScanned: (scannedCode) {
                              setState(() {
                                codeController.text = scannedCode;
                              });
                            },
                          ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 24,
                ),
                label: Text(
                  "Scan QR code",
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100.w, 6.h),
                  backgroundColor: const Color.fromRGBO(90, 50, 140, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),

              Spacer(),
              ElevatedButton(
                onPressed:
                    _loading
                        ? null
                        : () async {
                          if (codeController.text.trim().isEmpty) {
                            showAppSnackBar(
                              context,
                              message: 'Enter a party code',
                              backgroundColor: Colors.red,
                            );
                            return;
                          }

                          setState(() => _loading = true);
                          try {
                            await _partyService.joinParty(
                              codeController.text.trim(),
                            );
                            showAppSnackBar(
                              context,
                              message: 'Joined the party successfully! 🎉',
                            );

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => JoinPartyConfirmation(
                                      partyCode: codeController.text.trim(),
                                    ),
                              ),
                            );
                          } catch (e) {
                            showAppSnackBar(
                              context,
                              message:
                                  "Error ocurred! please try again after some time",
                              backgroundColor: Colors.red,
                            );
                            log(e.toString());
                          } finally {
                            setState(() => _loading = false);
                          }
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
                  "Join party",
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // child:
                //     _loading
                //         ? CircularProgressIndicator(color: Colors.white)
                //         : Text(
                //           "Join party",
                //           style: GoogleFonts.quicksand(
                //             fontSize: 20,
                //             color: Colors.white,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
