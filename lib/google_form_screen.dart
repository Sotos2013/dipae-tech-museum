import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleFormScreen extends StatelessWidget {
  final String formUrl = "https://forms.gle/iqXLLLfEHeTtEhtd6";

  Future<void> _launchForm() async {
    if (!await launchUrl(Uri.parse(formUrl), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $formUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ερωτηματολόγιο')),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // 🔴 Κόκκινο background
            foregroundColor: Colors.white, // ⚪ Άσπρο κείμενο
          ),
          child: const Text('Άνοιξε τη φόρμα'),
        ),
      ),
    );
  }
}
