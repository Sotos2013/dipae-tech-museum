import 'package:flutter/material.dart';

class QRInfoScreen extends StatelessWidget {
  final String qrData;

  const QRInfoScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Information'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            qrData,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}