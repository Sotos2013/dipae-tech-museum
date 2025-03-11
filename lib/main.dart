import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'qr_info_screen.dart';
import 'qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fqnctdcarcmzowvfbcax.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxbmN0ZGNhcmNtem93dmZiY2F4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE2MDU2NDQsImV4cCI6MjA1NzE4MTY0NH0.9XZICl5hcF5a9VE42BZms6jBotUL9JLDPS2w0Bogk38',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Museum QR Scanner',
      theme: ThemeData(
        primaryColor: const Color(0xFFD41C1C),
        scaffoldBackgroundColor: const Color(0xFF224366),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD41C1C),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD41C1C),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// 🔥 **Splash Screen** για 3 δευτερόλεπτα πριν μεταφερθεί στην εφαρμογή
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF005580),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.museum, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Καλώς ήρθατε στο Μικρό Τεχνολογικό Μουσείο",
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ✅ **Αρχική Οθόνη**
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? randomExhibit;
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRandomExhibit();
  }

  Future<void> _fetchRandomExhibit() async {
    final response = await Supabase.instance.client
        .from('valid_qr_codes')
        .select()
        .limit(1)
        .maybeSingle();

    if (response != null) {
      setState(() {
        randomExhibit = response;
      });
    }
  }

  Future<void> _searchExhibits(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
      return;
    }

    final response = await Supabase.instance.client
        .from('valid_qr_codes')
        .select()
        .ilike('name', '%$query%');

    setState(() {
      searchResults = List<Map<String, dynamic>>.from(response);
      isSearching = true;
    });
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Σχετικά με την εφαρμογή"),
          content: const Text(
            "Αυτή είναι μια εφαρμογή QR Scanner για το Μικρό Τεχνολογικό Μουσείο. "
                "Δημιουργήθηκε για να παρέχει πληροφορίες για εκθέματα μέσω QR Codes και Quiz."
                "\n\nGitHub: https://github.com/your-repository",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Μικρό Τεχνολογικό Μουσείο"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 🔍 Πεδίο Αναζήτησης
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Αναζήτηση εκθέματος...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _searchExhibits,
            ),
            const SizedBox(height: 20),

            // ✅ Αν γίνεται αναζήτηση, δείξε τα αποτελέσματα
            if (isSearching)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    var exhibit = searchResults[index];
                    return ListTile(
                      title: Text(exhibit['name'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text(exhibit['description'], style: const TextStyle(color: Colors.white70)),
                      leading: Image.network(
                        exhibit['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRInfoScreen(
                              id: exhibit['id'],
                              name: exhibit['name'],
                              description: exhibit['description'],
                              imageUrl: exhibit['imageUrl'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            else ...[
              // 🎲 Τυχαίο Έκθεμα της Ημέρας
              if (randomExhibit != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRInfoScreen(
                          id: randomExhibit!['id'],
                          name: randomExhibit!['name'],
                          description: randomExhibit!['description'],
                          imageUrl: randomExhibit!['imageUrl'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        Image.network(
                          randomExhibit!['imageUrl'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "🔍 Τυχαίο Έκθεμα: ${randomExhibit!['name']}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen()));
        },
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
}
