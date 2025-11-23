import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatelessWidget {
  final Function(String) onCodeScanned;

  const QRScanScreen({super.key, required this.onCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: GoogleFonts.quicksand(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
        backgroundColor: const Color.fromRGBO(24, 15, 33, 1),
      ),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isEmpty) return;

          final code = barcodes.first.rawValue;
          if (code == null) return;

          onCodeScanned(code);
          Navigator.of(context).pop(); 
        },
      ),
    );
  }
}
