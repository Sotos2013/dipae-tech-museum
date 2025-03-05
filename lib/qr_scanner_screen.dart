import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'qr_info_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasShownInvalidMessage = false;
  bool _hasShownNoInternetMessage = false; // 🔥 Προσθήκη flag για το μήνυμα internet
  Timer? _debounceTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    cameraController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 🔥 Συνάρτηση για έλεγχο αν υπάρχει σύνδεση στο Internet
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // 🔥 Συνάρτηση για έλεγχο του QR code στο Firestore
  Future<void> _checkQRCode(String code) async {
    bool hasInternet = await _checkInternetConnection();

    if (!hasInternet) {
      if (!_hasShownNoInternetMessage) { // 🔥 Εμφάνιση μόνο μία φορά
        _hasShownNoInternetMessage = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Δεν υπάρχει σύνδεση στο Internet!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          _hasShownNoInternetMessage = false; // 🔥 Επαναφορά για μελλοντική χρήση
        });
      }
      return;
    }

    final doc = await _firestore.collection('valid_qr_codes').doc(code).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QRInfoScreen(
            qrData: '${data['name']}\n${data['description']}',
          ),
        ),
      );
    } else {
      if (!_hasShownInvalidMessage) { // 🔥 Εμφάνιση μηνύματος "Invalid QR Code" μόνο μία φορά
        _hasShownInvalidMessage = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Invalid QR Code',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          _hasShownInvalidMessage = false;
        });
      }
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
              if (!_isScanning) return;
              if (_debounceTimer?.isActive ?? false) return;

              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                final String? code = capture.barcodes.first.rawValue;
                if (code != null) {
                  setState(() {
                    _isScanning = false;
                  });

                  _checkQRCode(code).then((_) {
                    setState(() {
                      _isScanning = true;
                    });
                  });
                }
              });
            },
          ),
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
