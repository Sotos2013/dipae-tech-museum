import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled1/quiz_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'main.dart';

class QRInfoScreen extends StatefulWidget {
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
  State<QRInfoScreen> createState() => _QRInfoScreenState();
}

class _QRInfoScreenState extends State<QRInfoScreen> {
  String translatedName = '';
  String translatedDescription = '';
  bool isTranslating = false;
  String? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = Localizations.localeOf(context).languageCode;
    _handleTranslation();
  }

  Future<void> _handleTranslation() async {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'en') {
      setState(() => isTranslating = true);

      translatedName = await translateWithMyMemory(widget.name);
      translatedDescription = await translateWithMyMemory(widget.description);

      setState(() => isTranslating = false);
    } else {
      translatedName = widget.name;
      translatedDescription = widget.description;
      setState(() => isTranslating = false);
    }
  }

  Future<String> translateWithMyMemory(String text) async {
    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=el|en',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']['translatedText'];
      } else {
        print('❌ MyMemory error: ${response.statusCode} - ${response.body}');
        return text;
      }
    } catch (e) {
      print('❌ Exception during translation: $e');
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    // Αν αλλάξει η γλώσσα, κάνε νέα μετάφραση
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _handleTranslation();
    }

    String encodedUrl = Uri.encodeFull(widget.imageUrl);

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
            },
          ),
        ],
        backgroundColor: const Color(0xFFD41C1C),
      ),
      backgroundColor: const Color(0xFF224366),
      body: isTranslating
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                    translatedName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF224366),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    translatedDescription,
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
