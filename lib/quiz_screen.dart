import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  final String qrCode; // 🔥 Παίρνουμε το QR Code του εκθέματος

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
      final doc = await FirebaseFirestore.instance.collection('quizzes').doc(widget.qrCode).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        setState(() {
          questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
          isLoading = false;
        });
      } else {
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
                Navigator.pop(context); // Κλείνει το quiz
                Navigator.pop(context); // Επιστροφή στην αρχική οθόνη
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
        body: const Center(child: CircularProgressIndicator()), // 🔄 Φόρτωση
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
        title: const Text("Quiz"),
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
