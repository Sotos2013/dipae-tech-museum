import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled1/translation_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FinalQuizScreen extends StatefulWidget {
  const FinalQuizScreen({Key? key}) : super(key: key);

  @override
  State<FinalQuizScreen> createState() => _FinalQuizScreenState();
}

class _FinalQuizScreenState extends State<FinalQuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchRandomQuestions(Localizations.localeOf(context).languageCode);
  }

  Future<void> _fetchRandomQuestions(String locale) async {
    try {
      final response = await Supabase.instance.client
          .rpc('get_random_quiz_questions', params: {'limit_count': 5});

      final translated = await Future.wait(response.map<Future<Map<String, dynamic>>>((question) async {
        final originalQ = question['question'];
        final answers = List<Map<String, dynamic>>.from(question['answers']);

        String translatedQ = originalQ;

        if (locale == 'en') {
          translatedQ = await TranslationHelper.translate(originalQ, 'el', 'en');
          for (var answer in answers) {
            answer['text'] = await TranslationHelper.translate(answer['text'], 'el', 'en');
          }
        }
        answers.shuffle();
        return {
          'question': translatedQ,
          'answers': answers,
        };
      }));

      setState(() {
        questions = List<Map<String, dynamic>>.from(translated);
        isLoading = false;
      });
    } catch (e) {
      print("❌ Σφάλμα στο final quiz: $e");
      setState(() => isLoading = false);
    }
  }

  void _checkAnswer(bool isCorrect) {
    if (isCorrect) score++;

    if (currentQuestionIndex < questions.length - 1) {
      setState(() => currentQuestionIndex++);
    } else {
      _showResults();
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.quizComplete),
        content: Text("$score / ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.finalQuiz),
        ),
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.noQuestions,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final q = questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("${AppLocalizations.of(context)!.question} ${currentQuestionIndex + 1} / ${questions.length}"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    q['question'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...(q['answers'] as List).map((a) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ElevatedButton(
                      onPressed: () => _checkAnswer(a['correct']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD41C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(a['text']),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}