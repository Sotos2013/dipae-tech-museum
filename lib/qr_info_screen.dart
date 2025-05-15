import 'package:flutter/material.dart';
import 'package:untitled1/quiz_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';

class QRInfoScreen extends StatefulWidget {
  final String id;
  final String name;
  final String name_en;
  final String description;
  final String description_en;
  final String imageUrl;

  const QRInfoScreen({
    Key? key,
    required this.id,
    required this.name,
    required this.name_en,
    required this.description,
    required this.description_en,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<QRInfoScreen> createState() => _QRInfoScreenState();
}

class _QRInfoScreenState extends State<QRInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final encodedUrl = Uri.encodeFull(widget.imageUrl);

    final name = locale == 'en'
        ? (widget.name_en.isNotEmpty ? widget.name_en : widget.name)
        : (widget.name.isNotEmpty ? widget.name : widget.name_en);

    final description = locale == 'en'
        ? (widget.description_en.isNotEmpty ? widget.description_en : widget.description)
        : (widget.description.isNotEmpty ? widget.description : widget.description_en);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.exhibitInfoTitle,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () async {
              final newLocale = locale == 'el' ? const Locale('en') : const Locale('el');
              MyApp.setLocale(context, newLocale);
              setState(() {}); // 🔁 Εξαναγκάζει rebuild για να αλλάξει η περιγραφή
            },
          ),
        ],
        backgroundColor: const Color(0xFF005580),
      ),
      backgroundColor: const Color(0xFF224366),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Card(
            elevation: 8,
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
                        return Column(
                          children: [
                            const Icon(Icons.broken_image, size: 100, color: Colors.red),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.imageLoadError,
                              style: const TextStyle(color: Colors.red),
                            ),
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
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!.backButton,
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD41C1C),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(qrCode: widget.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.quiz, color: Colors.white),
                    label: Text(
                      AppLocalizations.of(context)!.startQuizButton,
                      style: const TextStyle(color: Colors.white),
                    ),
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
      ),
    );
  }
}
