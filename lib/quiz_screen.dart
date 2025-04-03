import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled1/translation_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuizScreen extends StatefulWidget {
  final String qrCode;

  const QuizScreen({Key? key, required this.qrCode}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }
  String? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context).languageCode;

    if (_currentLocale != locale) {
      _currentLocale = locale;
      _fetchQuestions(locale);
    }
  }

  Future<void> _fetchQuestions(String locale) async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .rpc('get_quiz_questions', params: {'qr_id': widget.qrCode});

      if (response.isNotEmpty) {
        final translated = await Future.wait(response.map((question) async {
          final originalQ = question['question'];
          final answers = List<Map<String, dynamic>>.from(question['answers']);
          String translatedQ = originalQ;

          if (locale == 'en') {
            translatedQ = await TranslationHelper.translate(originalQ, 'el', 'en');
            for (var answer in answers) {
              answer['text'] = await TranslationHelper.translate(answer['text'], 'el', 'en');
            }
          }

          return {
            'question': translatedQ,
            'answers': answers,
          };
        }));

        setState(() {
          questions = List<Map<String, dynamic>>.from(translated);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Σφάλμα φόρτωσης ερωτήσεων: $e");
      setState(() => isLoading = false);
    }
  }

  void _checkAnswer(bool isCorrect) {
    if (isCorrect) {
      score++;
    }

    // ✅ Ελέγχουμε αν υπάρχει άλλη ερώτηση ή αν τελείωσε το Quiz
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.quizComplete),
          content: Text("$score / ${questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // ✅ Επιστροφή στην προηγούμενη οθόνη
              },
              child: const Text("ΟΚ"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: CircularProgressIndicator(color: Colors.white,)),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.noQuestions,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    var question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.question}  ${currentQuestionIndex + 1} / ${questions.length}"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    question['question'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF224366),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...(question['answers'] as List<dynamic>).map((answer) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ElevatedButton(
                        onPressed: () => _checkAnswer(answer['correct']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD41C1C),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          textStyle: const TextStyle(fontSize: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(answer['text']),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
