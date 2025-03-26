import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'main.dart';

class ConnectionCheckScreen extends StatefulWidget {
  const ConnectionCheckScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionCheckScreen> createState() => _ConnectionCheckScreenState();
}

class _ConnectionCheckScreenState extends State<ConnectionCheckScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    setState(() {
      _isChecking = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() => _isChecking = false);
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
        return;
      }
    } on SocketException catch (_) {
    }

    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF224366),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Δεν υπάρχει σύνδεση στο διαδίκτυο!",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _checkInternet,
              child: const Text("Επαναπροσπάθεια"),
            ),
          ],
        ),
      ),
    );
  }
}
