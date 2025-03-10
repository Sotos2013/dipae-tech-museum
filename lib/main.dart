import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'qr_scanner_screen.dart'; // Οθόνη Scanner QR
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fqnctdcarcmzowvfbcax.supabase.co', // Βάλε εδώ το Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxbmN0ZGNhcmNtem93dmZiY2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE2MDU2NDQsImV4cCI6MjA1NzE4MTY0NH0.9XZICl5hcF5a9VE42BZms6jBotUL9JLDPS2w0Bogk38', // Βάλε εδώ το Supabase Anon Key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Museum QR Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF224366)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// 🔥 Splash Screen για 3 δευτερόλεπτα πριν μεταφερθεί στην εφαρμογή
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnectionCheckScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005580),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.museum, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Καλώς ήρθατε στο Μικρό Τεχνολογικό Μουσείο",
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// 🔥 Οθόνη Ελέγχου Σύνδεσης στο Internet
class ConnectionCheckScreen extends StatefulWidget {
  const ConnectionCheckScreen({Key? key}) : super(key: key);

  @override
  _ConnectionCheckScreenState createState() => _ConnectionCheckScreenState();
}

class _ConnectionCheckScreenState extends State<ConnectionCheckScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  Future<void> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool hasInternet = connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Δεν υπάρχει σύνδεση στο internet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Συνδεθείτε ξανά στο internet (WiFi ή Mobile Data) και ανοίξτε ξανά την εφαρμογή."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => checkInternet(),
              child: const Text("Ξαναπροσπαθήστε"),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 Αρχική Οθόνη
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF224366), // 🔵 Μπλε background
      appBar: AppBar(
        title: const Text(
          'Μικρό Τεχνολογικό Μουσείο',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD41C1C), // 🔴 Κόκκινο AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.museum, size: 100, color: Colors.white),
            Image.asset(
              'assets/ihu_logo.png',
              height: 100, // Μπορείς να αλλάξεις το μέγεθος
            ),
            const SizedBox(height: 20),
            const Text(
              'Σκανάρετε ένα QR Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text(
                "Έναρξη Σάρωσης",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD41C1C), // 🔴 Κόκκινο κουμπί
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
