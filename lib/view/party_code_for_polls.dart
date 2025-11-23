import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/poll_games_screen.dart';
import 'package:litup/view/qr_scan_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';

const Color primary = Color.fromRGBO(83, 17, 150, 1);
const Color background = Color.fromRGBO(24, 15, 33, 1);
const Color cardColor = Color.fromRGBO(27, 29, 44, 1);
const Color textLight = Color.fromRGBO(217, 217, 217, 1);

class EnterPartyCodeScreen extends StatefulWidget {
  const EnterPartyCodeScreen({super.key});

  @override
  _EnterPartyCodeScreenState createState() => _EnterPartyCodeScreenState();
}

class _EnterPartyCodeScreenState extends State<EnterPartyCodeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  void _submitCode() async {
    setState(() => _loading = true);
    final code = _controller.text.trim();
    final snapshot =
        await FirebaseFirestore.instance.collection('parties').doc(code).get();

    if (snapshot.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PollsGamesScreen(partyId: code)),
      );
    } else {
      showAppSnackBar(
        context,
        message: 'Invalid party code!',
        backgroundColor: Colors.red,
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Enter Party Code',
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: background,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Party Code',
                  prefixIcon: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => QRScanScreen(
                                onCodeScanned: (scannedCode) {
                                  setState(() {
                                    _controller.text = scannedCode;
                                  });
                                  if (scannedCode.isNotEmpty) {
                                    _submitCode();
                                  }
                                },
                              ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.qr_code_2,
                      color: Colors.purpleAccent.shade100,
                    ),
                  ),
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: const Color.fromRGBO(33, 24, 48, 1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.shade700,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(180, 90, 255, 1),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.sp,
                    vertical: 14.sp,
                  ),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(150, 50),
                  backgroundColor: primary,
                ),
                onPressed: _loading ? null : _submitCode,
                child:
                    _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
