import 'package:flutter/material.dart';
import 'package:untitled1/quiz_screen.dart';

class QRInfoScreen extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const QRInfoScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String encodedUrl = Uri.encodeFull(imageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Πληροφορίες Εκθέματος',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD41C1C),
      ),
      backgroundColor: const Color(0xFF224366),
      body: Padding(
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
                    encodedUrl,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("❌ Σφάλμα στη φόρτωση εικόνας: $error"); // Debugging
                      return Column(
                        children: const [
                          Icon(Icons.broken_image, size: 100, color: Colors.red),
                          SizedBox(height: 10),
                          Text("Η εικόνα δεν φορτώθηκε!", style: TextStyle(color: Colors.red)),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
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

                // 🔴 Κουμπί για επιστροφή
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

                const SizedBox(height: 10),

                // 🟢 Κουμπί για το Quiz
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(qrCode: id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz, color: Colors.white),
                  label: const Text("Ξεκινήστε το Quiz", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
    );
  }
}
