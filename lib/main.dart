import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'qr_info_screen.dart';
import 'qr_scanner_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      title: 'Τεχνολογικό Μουσείο ΔΙΠΑΕ',
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('el'), // Ελληνικά
        Locale('en'), // Αγγλικά
      ],
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInternet();
  }

  Future<void> _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return; // ✅ Αποτρέπει σφάλματα αν το widget έχει αποσυναρμολογηθεί
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      });
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Χωρίς Σύνδεση"),
          content: const Text("Δεν υπάρχει διαθέσιμη σύνδεση στο διαδίκτυο. Παρακαλώ ελέγξτε τη σύνδεσή σας και προσπαθήστε ξανά."),
          actions: [
            TextButton(
              onPressed: () => _checkInternet(),
              child: const Text("Επαναπροσπάθεια"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Έξοδος"),
            ),
          ],
        );
      },
    );
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
            Text(
              AppLocalizations.of(context)!.welcomeMessage,
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
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchRandomExhibit();
    _startMonitoring();
  }

  Future<void> _fetchRandomExhibit() async {
    final response = await Supabase.instance.client
        .rpc('get_random_exhibit')
        .maybeSingle();

    if (response == null) {
      print("⚠️ Δεν βρέθηκε τυχαίο έκθεμα!");
      return;
    }

    setState(() {
      randomExhibit = {
        "id": response["id"] ?? "unknown_id",
        "name": response["name"] ?? "Άγνωστο Έκθεμα",
        "description": response["description"] ?? "Δεν υπάρχει διαθέσιμη περιγραφή.",
        "imageUrl": response["imageUrl"] ?? "https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg"
      };
    });
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
      print("🔍 Random Exhibit: $randomExhibit");
      print("🔍 Search Results: $searchResults");

    searchResults = List<Map<String, dynamic>>.from(response)
          .map((exhibit) => {
        "id": exhibit["id"] ?? "unknown_id",
        "name": exhibit["name"] ?? "Άγνωστο Έκθεμα",
        "description": exhibit["description"] ?? "Δεν υπάρχει διαθέσιμη περιγραφή.",
        "imageUrl": exhibit["imageUrl"] ?? "https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg"
      })
          .toList();
      isSearching = true;
    });
  }

  late StreamSubscription _subscription;

  void _startMonitoring() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasInternet = results.any((result) => result != ConnectivityResult.none);

      setState(() {
        _isOffline = !hasInternet;
      });

      if (_isOffline) {
        _showNoInternetSnackbar();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // Ακυρώνουμε το StreamSubscription για αποφυγή memory leaks
    super.dispose();
  }

  void _showNoInternetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Χάθηκε η σύνδεση στο διαδίκτυο!"),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF224366), // Μπλε background
          title: const Text(
            "Σχετικά με την εφαρμογή",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Λευκός τίτλος
            ),
          ),
          content: const Text(
            "Αυτή είναι μια εφαρμογή για το Τεχνολογικό Μουσείο του Διεθνούς Πανεπιστημίου της Ελλάδος.\n"
                "Δημιουργήθηκε για να παρέχει πληροφορίες για εκθέματα μέσω QR Codes και ερωτήσεις πολλαπλής επιλογής για το κάθε έκθεμα.",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔗 Κουμπί GitHub
                TextButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse("https://github.com/Sotos2013/dipae-tech-museum");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Δεν ήταν δυνατή η φόρτωση του GitHub.')),
                      );
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white),
                  label: const Text(
                    "GitHub",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // ❌ Κουμπί Κλείσιμο
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
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
        title: const Text("Τεχνολογικό Μουσείο ΔΙΠΑΕ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showAboutDialog(context), // Προσθήκη ανώνυμης συνάρτησης
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRandomExhibit, // 🔄 Ανανεώνει το exhibit με swipe down
        color: Color(0xFFD41C1C),
        child: GestureDetector(
          onTap: () {
            // Κλείνει το πληκτρολόγιο όταν ο χρήστης πατάει εκτός του πεδίου αναζήτησης
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20.0),
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
                    if (searchResults.isEmpty)
                      const Center(
                        child: Text(
                          "❌ Δεν βρέθηκαν αποτελέσματα",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    else
                      ...searchResults.map((exhibit) {
                        return ListTile(
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Προσθήκη padding για καλύτερη εμφάνιση
                          title: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  exhibit['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image, size: 50, color: Colors.red);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10), // Απόσταση εικόνας από το κείμενο
                              Expanded(
                                child: Text(
                                  exhibit['name'],
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            exhibit['description'],
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        );
                      })
                  else if (randomExhibit != null) ...[
                    // 🎲 Τυχαίο Έκθεμα της Ημέρας
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRInfoScreen(
                              id: randomExhibit!['id'] ?? 'Άγνωστο Έκθεμα',
                              name: randomExhibit!['name'] ?? 'Άγνωστο Έκθεμα',
                              description: randomExhibit!['description'] ?? 'Δεν υπάρχει διαθέσιμη περιγραφή.',
                              imageUrl: randomExhibit!['imageUrl'] ?? 'https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg',
                            ),
                          ),
                        ).then((_) {
                          _fetchRandomExhibit(); // 🔄 Επαναφέρει το τυχαίο έκθεμα όταν ο χρήστης επιστρέψει
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🎲 Τυχαίο Έκθεμα της Ημέρας
                          if (randomExhibit != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20), // Αποφυγή επικαλύψεων
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QRInfoScreen(
                                        id: randomExhibit!['id'] ?? 'unknown_id',
                                        name: randomExhibit!['name'] ?? 'Άγνωστο Έκθεμα',
                                        description: randomExhibit!['description'] ?? 'Δεν υπάρχει διαθέσιμη περιγραφή.',
                                        imageUrl: randomExhibit!['imageUrl'] ?? 'https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg',
                                      ),
                                    ),
                                  ).then((_) {
                                    _fetchRandomExhibit(); // 🔄 Επαναφέρει το τυχαίο έκθεμα όταν ο χρήστης επιστρέψει
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                        child: Image.network(
                                          randomExhibit!['imageUrl'],
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          "🔍 Τυχαίο Έκθεμα: ${randomExhibit?['name'] ?? 'Άγνωστο Έκθεμα'}",
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // ℹ️ Πληροφορίες Μουσείου (ΔΕΝ ΕΙΝΑΙ TAPABLE!)
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF005580), // 🔵 Μπλε background
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "🏛️ Μικρό Τεχνολογικό Μουσείο",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Σας καλωσορίζουμε στο Μικρό Τεχνολογικό Μουσείο του ΔΙΠΑΕ, "
                                        "έναν μοναδικό εκθεσιακό χώρο μέσα σε ένα παλιό βαγόνι τρένου! "
                                        "Εδώ, η ιστορία της τεχνολογίας ζωντανεύει, "
                                        "συνδέοντας το παρελθόν με το παρόν και το μέλλον.",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "🚂 Ένα Βαγόνι, Μια Ιστορία",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Το μουσείο στεγάζεται σε ένα αναπαλαιωμένο βαγόνι τρένου, "
                                        "συμβολίζοντας το ταξίδι της τεχνολογικής εξέλιξης. "
                                        "Μέσα σε αυτόν τον ιδιαίτερο χώρο, κάθε αντικείμενο αφηγείται τη δική του ιστορία, "
                                        "προκαλώντας σας σε ένα ταξίδι γνώσης και ανακάλυψης.",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "🔎 Τι θα ανακαλύψετε;",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "📌 Ιστορικές Συσκευές & Υπολογιστές\n"
                                        "   • Από τις πρώτες αριθμομηχανές έως τους πρώτους προσωπικούς υπολογιστές\n"
                                        "📡 Τηλεπικοινωνίες\n"
                                        "   • Ραδιόφωνα, τηλέφωνα και άλλες συσκευές που άλλαξαν τον τρόπο επικοινωνίας\n"
                                        "🔬 Επιστημονικά Όργανα\n"
                                        "   • Εργαλεία που χρησιμοποιήθηκαν για έρευνα και καινοτομία",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🏛️ **Λογότυπο ΔΙΠΑΕ**
                          Image.asset(
                            'assets/ihu_logo.png',
                            height: 80,
                          ),
                          const Text(
                            "Διεθνές Πανεπιστήμιο της Ελλάδος",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),

                          const SizedBox(height: 20),

                          // 🔴 Google Form Button
                          ElevatedButton(
                            onPressed: () async {
                              final Uri url = Uri.parse("https://docs.google.com/forms/d/e/1FAIpQLSeve-CdFpu5gper6D2QnmHu6cs99fqvGeK7A2UCNmk6JRZWjQ/viewform");

                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Δεν ήταν δυνατή η φόρτωση του Google Form')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Συμπλήρωσε το ερωτηματολόγιο'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
