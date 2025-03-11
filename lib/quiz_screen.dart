import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      print("🔍 Αναζήτηση ερωτήσεων για το QR Code: ${widget.qrCode}");
      // ✅ Φέρνουμε όλες τις ερωτήσεις με το ίδιο ID
      final List<dynamic> response = await Supabase.instance.client
          .from('quizzes')
          .select()
          .eq('id', widget.qrCode);
      if (response.isNotEmpty) {
        setState(() {
          questions = response.map((question) {
            return {
              'question': question['question'],
              'answers': jsonDecode(question['answers']), // ✅ Μετατροπή JSON
            };
          }).toList();

          isLoading = false;
        });

        print("✅ Φορτώθηκαν ${questions.length} ερωτήσεις για το ${widget.qrCode}!");
      } else {
        print("❌ Δεν βρέθηκαν ερωτήσεις!");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Σφάλμα φόρτωσης ερωτήσεων: $e");
      setState(() {
        isLoading = false;
      });
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
          title: const Text("Quiz Ολοκληρώθηκε!"),
          content: Text("Σκορ: $score / ${questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // ✅ Επιστροφή στην προηγούμενη οθόνη
              },
              child: const Text("Εντάξει"),
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(
          child: Text(
            "❌ Δεν υπάρχουν διαθέσιμες ερωτήσεις!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    var question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Ερώτηση ${currentQuestionIndex + 1} / ${questions.length}"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...(question['answers'] as List<dynamic>).map((answer) {
              return ElevatedButton(
                onPressed: () => _checkAnswer(answer['correct']),
                child: Text(answer['text']),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
