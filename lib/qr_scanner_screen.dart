import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Εισαγωγή του Firestore
import 'dart:async';

import 'package:untitled1/qr_info_screen.dart'; // Προσθήκη για το Timer

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true; // Flag για έλεγχο πολλαπλών κλήσεων
  Timer? _debounceTimer; // Timer για debounce
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  @override
  void dispose() {
    cameraController.dispose();
    _debounceTimer?.cancel(); // Ακύρωση του timer
    super.dispose();
  }

  // Συνάρτηση για έλεγχο του QR code στο Firestore
  Future<void> _checkQRCode(String code) async {
    final doc = await _firestore.collection('valid_qr_codes').doc(code).get();
    if (doc.exists) {
      // Ο QR code είναι έγκυρος
      final data = doc.data() as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRInfoScreen(
            qrData: '${data['name']}\n${data['description']}',
          ),
        ),
      );
    } else {
      // Ο QR code δεν είναι έγκυρος
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR Code'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isScanning) return; // Αν η σάρωση δεν είναι ενεργή, σταματάμε

              if (_debounceTimer?.isActive ?? false) return; // Αν το timer είναι ενεργό, σταματάμε

              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _isScanning = false; // Απενεργοποίηση της σάρωσης
                  });

                  // Έλεγχος του QR code στο Firestore
                  _checkQRCode(code).then((_) {
                    // Επαναφορά της σάρωσης
                    setState(() {
                      _isScanning = true;
                    });
                  });
                }
              });
            },
          ),
          // Προσθήκη overlay για την κάμερα
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}