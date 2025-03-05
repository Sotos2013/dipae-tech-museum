import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRInfoScreen extends StatelessWidget {
  final String qrData;

  const QRInfoScreen({Key? key, required this.qrData}) : super(key: key);

  Future<String?> _fetchWikipediaImage(String imageName) async {
    if (imageName.isEmpty) return null;

    final String apiUrl =
        "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=imageinfo&iiprop=url&titles=File:$imageName";

    print("Fetching image from: $apiUrl"); // **DEBUG: Εκτύπωση του API URL για έλεγχο**

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final pages = jsonData['query']['pages'];
        final page = pages.values.first;

        if (page.containsKey('imageinfo')) {
          String imageUrl = page['imageinfo'][0]['url'];
          print("Wikipedia Image URL: $imageUrl"); // **DEBUG: Εκτύπωση του τελικού URL**
          return imageUrl;
        } else {
          print("No imageinfo found in response");
        }
      } else {
        print("Wikipedia API returned status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching Wikipedia image: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    List<String> qrInfoParts = qrData.split("\n");
    String title = qrInfoParts.isNotEmpty ? qrInfoParts[0] : "Άγνωστο Έκθεμα";
    String description = qrInfoParts.length > 1 ? qrInfoParts[1] : "Δεν υπάρχουν πληροφορίες.";
    String imageName = qrInfoParts.length > 2 ? qrInfoParts[2] : "";

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
                  FutureBuilder<String?>(
                    future: _fetchWikipediaImage(imageName),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(snapshot.data!,
                              height: 200, fit: BoxFit.cover),
                        );
                      } else {
                        return Column(
                          children: const [
                            Icon(Icons.broken_image, size: 100, color: Colors.red),
                            SizedBox(height: 10),
                            Text("Η εικόνα δεν φορτώθηκε!", style: TextStyle(color: Colors.red)),
                          ],
                        );
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
