import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class QRInfoScreen extends StatelessWidget {
  final String qrData;

  const QRInfoScreen({Key? key, required this.qrData}) : super(key: key);

  Future<Uint8List?> _fetchImage(String imageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {"User-Agent": "Mozilla/5.0"},
      );
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<String> qrInfoParts = qrData.split("\n");
    String title = qrInfoParts.isNotEmpty ? qrInfoParts[0] : "Άγνωστο Έκθεμα";
    String description = qrInfoParts.length > 1 ? qrInfoParts[1] : "Δεν υπάρχουν πληροφορίες.";
    String imageUrl = qrInfoParts.length > 2 ? qrInfoParts[2] : "https://via.placeholder.com/150";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Πληροφορίες Εκθέματος'),
        backgroundColor: const Color(0xFFD41C1C),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder<Uint8List?>(
                    future: _fetchImage(imageUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        return Image.memory(snapshot.data!, height: 200, fit: BoxFit.cover);
                      } else {
                        return const Icon(Icons.broken_image, size: 100, color: Colors.red);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD41C1C),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text("Πίσω", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD41C1C),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
