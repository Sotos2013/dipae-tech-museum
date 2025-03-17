import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleFormScreen extends StatefulWidget {
  @override
  _GoogleFormScreenState createState() => _GoogleFormScreenState();
}

class _GoogleFormScreenState extends State<GoogleFormScreen> {
  late final WebViewController _controller;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://forms.gle/iGzVPVczSft26V8d9')) // Replace with your Google Form link
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) async {
          bool value = await _controller.canGoBack();
          setState(() {
            canGoBack = value;
          });
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ερωτηματολόγιο"),
        actions: [
          if (canGoBack)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  _controller.goBack();
                }
              },
            ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
