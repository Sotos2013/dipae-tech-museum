import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationHelper {
  static const String _email = 'www.sotihatzi@gmail.com';

  static Future<String> translate(String text, String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'translation_${from}_$to:$text';
    final _apiKey = dotenv.env['MYMEMORY_API_KEY'];
    if (_apiKey == null) return text;

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      return cached;
    }

    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}'
            '&langpair=$from|$to'
            '&de=$_email'
            '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['responseData']['translatedText'];

        // 💾 Αποθηκεύει τη μετάφραση στο SharedPreferences
        await prefs.setString(cacheKey, translatedText);

        print('🌍 Μετάφραση απο API και αποθήκευση: "$text" ➜ "$translatedText"');
        return translatedText;
      } else {
        print('❌ Σφάλμα MyMemory: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Σφάλμα κατά την κλήση του API: $e');
    }

    return text;
  }
}
