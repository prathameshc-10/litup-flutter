import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:litup/view/bottom_navigation_screen.dart';
import 'package:litup/view/snackbar_helper.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';

class PartyCodeScreen extends StatelessWidget {
  final String code;

  const PartyCodeScreen({super.key, required this.code});

  // Render QR to image and share
  Future<void> _shareQrCode(BuildContext context) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: code,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        // Render to image
        final picData = await painter.toImageData(300); // 300x300 pixels
        final bytes = picData!.buffer.asUint8List();

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/party_qr.png').create();
        await file.writeAsBytes(bytes);

        // Share image
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Join my party! Code: $code');
      }
    } catch (e) {
      showAppSnackBar(context, message: 'Error sharing QR code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
        title: Text(
          "Party Code",
          style: GoogleFonts.quicksand(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigationScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Share this code with your friends:",
              style: GoogleFonts.quicksand(
                color: Colors.grey.shade300,
                fontSize: 16.sp,
              ),
            ),
            const SizedBox(height: 20),

            // QR Code Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(33, 24, 48, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purpleAccent.shade100,
                  width: 1.5,
                ),
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Party Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(33, 24, 48, 1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purpleAccent.shade100,
                  width: 1.5,
                ),
              ),
              child: SelectableText(
                code,
                style: GoogleFonts.quicksand(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 30),

            // Copy & Share Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    showAppSnackBar(
                      context,
                      message: "Code copied to clipboard!",
                    );
                  },
                  icon: const Icon(Icons.copy, color: Colors.white),
                  label: Text(
                    "Copy",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _shareQrCode(context),
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: Text(
                    "Share QR",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(83, 17, 150, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
