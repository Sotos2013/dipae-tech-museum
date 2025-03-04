import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Αρχικοποίηση Flutter
  await Firebase.initializeApp(); // ✅ Αρχικοποίηση Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Setup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Setup Complete')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 🔥 Δοκιμή σύνδεσης με Firestore
            await FirebaseFirestore.instance
                .collection('test')
                .add({'message': 'Hello, Firebase!'});
          },
          child: const Text("Send Data to Firestore"),
        ),
      ),
    );
  }
}
