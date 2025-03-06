import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRInfoScreen extends StatelessWidget {
  final String qrCode;

  const QRInfoScreen({Key? key, required this.qrCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Πληροφορίες Εκθέματος',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD41C1C),
      ),
      backgroundColor: const Color(0xFF224366),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('valid_qr_codes').doc(qrCode).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Το QR Code δεν αντιστοιχεί σε καταχωρημένο έκθεμα!",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String title = data['name'] ?? "Άγνωστο Έκθεμα";
          String description = data['description'] ?? "Δεν υπάρχουν πληροφορίες.";
          String imageUrl = data['imageUrl'] ?? "https://via.placeholder.com/300";

          return Padding(
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF224366),
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
          );
        },
      ),
    );
  }
}
