import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_info_screen.dart'; // Εισαγωγή της οθόνης πληροφοριών
import 'dart:async'; // Προσθήκη για το Timer

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true; // Flag για έλεγχο πολλαπλών κλήσεων
  Timer? _debounceTimer; // Timer για debounce

  @override
  void dispose() {
    cameraController.dispose();
    _debounceTimer?.cancel(); // Ακύρωση του timer
    super.dispose();
  }

  // Συνάρτηση για έλεγχο του περιεχομένου του QR κωδικού
  bool _isValidQRCode(String code) {
    // Παράδειγμα: Ο QR κωδικός πρέπει να περιέχει τη λέξη "SPECIAL"
    return code.contains("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (!_isScanning) return; // Αν η σάρωση δεν είναι ενεργή, σταματάμε

          if (_debounceTimer?.isActive ?? false) return; // Αν το timer είναι ενεργό, σταματάμε

          _debounceTimer = Timer(const Duration(milliseconds: 500), () {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null && _isValidQRCode(code)) {
              setState(() {
                _isScanning = false; // Απενεργοποίηση της σάρωσης
              });

              // Πλοήγηση στην οθόνη πληροφοριών
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QRInfoScreen(qrData: code),
                ),
              ).then((_) {
                // Επαναφορά της σάρωσης
                setState(() {
                  _isScanning = true;
                });
              });
            } else {
              // Εμφάνιση μηνύματος λάθους αν ο QR κωδικός δεν είναι έγκυρος
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid QR Code'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
        },
      ),
    );
  }
}