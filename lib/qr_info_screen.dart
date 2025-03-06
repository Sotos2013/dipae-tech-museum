import 'package:flutter/material.dart';

class QRInfoScreen extends StatelessWidget {
  final String qrData;

  const QRInfoScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> qrInfoParts = qrData.split("\n");
    String title = qrInfoParts.isNotEmpty ? qrInfoParts[0] : "Άγνωστο Έκθεμα";
    String description = qrInfoParts.length > 1 ? qrInfoParts[1] : "Δεν υπάρχουν πληροφορίες.";
    String imageUrl = qrInfoParts[1] ; // 🔥 Παίρνουμε το URL από τη Firestore

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Πληροφορίες Εκθέματος',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD41C1C),
      ),
      backgroundColor: const Color(0xFF224366),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator()); // 🔄 Δείχνει loading όσο φορτώνει
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          children: const [
                            Icon(Icons.broken_image, size: 100, color: Color(0xFF224366)),
                            SizedBox(height: 10),
                            Text("Η εικόνα δεν φορτώθηκε!", style: TextStyle(color: Color(0xFF224366))),
                          ],
                        );
                      },
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
        ),
      ),
    );
  }
}
