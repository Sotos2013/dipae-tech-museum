import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'qr_info_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasShownNoInternetMessage = false;
  bool _isFlashOn = false;
  bool _hasShownInvalidQrMessage = false;
  Timer? _debounceTimer;
  @override

  void initState() {
    super.initState();

    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.webFlashTip,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }
  @override
  void dispose() {
    cameraController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 🔥 Έλεγχος σύνδεσης στο Internet
  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _checkQRCode(String code) async {
    bool hasInternet = await _checkInternetConnection();

    if (!hasInternet) {
      if (!_hasShownNoInternetMessage) {
        _hasShownNoInternetMessage = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.noInternetMessage,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          _hasShownNoInternetMessage = false;
        });
      }
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('valid_qr_codes')
          .select()
          .eq('id', code)
          .maybeSingle();

      if (response != null) {
        print("✅ Βρέθηκε εγγραφή στο Supabase: ${response['name']}");
        print("🔍 Εικόνα από Supabase: ${response['imageUrl']}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QRInfoScreen(
              id: response['id'], // id εκθέματος
              name: response['name'], // Όνομα εκθέματος
              description: response['description'], // Περιγραφή
              imageUrl: response['imageUrl'], // URL εικόνας
            ),
          ),
        );
      } else {
        if (!_hasShownInvalidQrMessage) {
          _hasShownInvalidQrMessage = true; // Αποτρέπει την πολλαπλή εμφάνιση του μηνύματος
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.invalidQrMessage,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          Future.delayed(const Duration(seconds: 3), () {
            _hasShownInvalidQrMessage = false; // Επαναφέρει τη μεταβλητή μετά από 3 δευτερόλεπτα
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.qrSearchError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF224366),
        title: Text(
          AppLocalizations.of(context)!.qrScannerTitle,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!kIsWeb)
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFlashOn = !_isFlashOn;
                  cameraController.toggleTorch();
                });
              },
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isScanning) return;
              if (_debounceTimer?.isActive ?? false) return;

              _debounceTimer = Timer(const Duration(milliseconds: 800), () {
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
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}