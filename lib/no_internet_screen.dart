import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Δεν υπάρχει σύνδεση στο διαδίκτυο",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Παρακαλώ σύνδεσε στο internet και δοκίμασε ξανά."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Επαναπροσπάθεια"),
            ),
          ],
        ),
      ),
    );
  }
}
