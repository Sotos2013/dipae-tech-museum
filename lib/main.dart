import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled1/translation_helper.dart';
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

// 🔁 Κάνε το Stateful για δυναμική αλλαγή γλώσσας
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('el'); // default Greek

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'el';
    setState(() {
      _locale = Locale(langCode);
    });
  }

  void setLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Τεχνολογικό Μουσείο ΔΙΠΑΕ',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('el'), // 🇬🇷 Ελληνικά
        Locale('en'), // 🇬🇧 Αγγλικά
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFFD41C1C),
        scaffoldBackgroundColor: const Color(0xFF224366),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD41C1C),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD41C1C),
        ),
      ),
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

    // Εκτελείται αφού φορτωθεί πλήρως η πρώτη frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConnectionCheckScreen()),
        );
      });
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
            Text(
              AppLocalizations.of(context)!.museumTitle,
              style: const TextStyle(fontSize: 20, color: Colors.white),
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
class ConnectionCheckScreen extends StatefulWidget {
  const ConnectionCheckScreen({Key? key}) : super(key: key);

  @override
  _ConnectionCheckScreenState createState() => _ConnectionCheckScreenState();
}

class _ConnectionCheckScreenState extends State<ConnectionCheckScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternet();
    });
  }

  Future<void> _checkInternet() async {
    bool hasInternet = false;

    if (kIsWeb) {
      hasInternet = true; // Web workaround
    } else {
      hasInternet = await _hasRealInternet();
    }

    if (!mounted) return;

    if (hasInternet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
      });
    } else {
      setState(() => _isChecking = false);
    }
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF005580),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.signal_wifi_connected_no_internet_4, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noInternet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(AppLocalizations.of(context)!.noInternetMessage, style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkInternet,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
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
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchRandomExhibit().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    _startMonitoring();
  }

  Future<void> _fetchRandomExhibit() async {
    setState(() => _isLoading = true);

    final response = await Supabase.instance.client
        .rpc('get_random_exhibit')
        .maybeSingle();

    if (response == null) {
      setState(() => _isLoading = false);
      return;
    }

    String name = response["name"] ?? "Άγνωστο Έκθεμα";
    String description = response["description"] ?? "Δεν υπάρχει διαθέσιμη περιγραφή.";

    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'en') {
      final translated = await Future.wait([
        TranslationHelper.translate(name, 'el', 'en'),
        TranslationHelper.translate(description, 'el', 'en'),
      ]);
      name = translated[0];
      description = translated[1];
    }

    setState(() {
      randomExhibit = {
        "id": response["id"],
        "name": name,
        "description": description,
        "imageUrl": response["imageUrl"] ?? "",
      };
      _isLoading = false;
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

    final results = await Supabase.instance.client
        .from('valid_qr_codes')
        .select()
        .ilike('name', '%$query%');

    final locale = Localizations.localeOf(context).languageCode;

    final translated = <Map<String, dynamic>>[];

    for (var exhibit in results) {
      String name = exhibit["name"] ?? "Άγνωστο Έκθεμα";
      String description = exhibit["description"] ?? "Δεν υπάρχει περιγραφή.";

      if (locale == 'en') {
        final t = await Future.wait([
          TranslationHelper.translate(name, 'el', 'en'),
          TranslationHelper.translate(description, 'el', 'en'),
        ]);
        name = t[0];
        description = t[1];
      }

      translated.add({
        "id": exhibit["id"],
        "name": name,
        "description": description,
        "imageUrl": exhibit["imageUrl"] ?? "",
      });
    }

    setState(() {
      searchResults = translated;
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
      SnackBar(
        content: Text(AppLocalizations.of(context)!.noInternet),
        duration: const Duration(seconds: 3),
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
          title: Text(
            AppLocalizations.of(context)!.aboutAppTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Λευκός τίτλος
            ),
          ),
          content: Text(AppLocalizations.of(context)!.museumDes,
            style: const TextStyle(fontSize: 16, color: Colors.white),
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
                        SnackBar(content: Text(AppLocalizations.of(context)!.noGithub)),
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
        title: Text(AppLocalizations.of(context)!.museumTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showAboutDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              final currentLang = Localizations.localeOf(context).languageCode;
              final newLocale = currentLang == 'el' ? const Locale('en') : const Locale('el');
              MyApp.setLocale(context, newLocale);
            },
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Stack(
              children: [
              ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // 🔍 Πεδίο Αναζήτησης
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.searchPlaceholder,
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
                      Center(
                        child: Text(
                            AppLocalizations.of(context)!.noResults,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
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
                                          "${AppLocalizations.of(context)!.randomExhibit} :"" ${randomExhibit?['name'] ?? 'Άγνωστο Έκθεμα'}",
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
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.museumInfoTitle,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppLocalizations.of(context)!.museumInfo1,
                                    style: const TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    AppLocalizations.of(context)!.trainStoryTitle,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppLocalizations.of(context)!.trainStory,
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    AppLocalizations.of(context)!.discoverTitle,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppLocalizations.of(context)!.discoverItems,
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
                          Text(
                            AppLocalizations.of(context)!.ihuName,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),

                          const SizedBox(height: 20),

                          // 🔴 Google Form Button
                          ElevatedButton(
                            onPressed: () async {
                              final Uri url = Uri.parse("https://docs.google.com/forms/d/e/1FAIpQLSeve-CdFpu5gper6D2QnmHu6cs99fqvGeK7A2UCNmk6JRZWjQ/viewform");

                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.noInternet)),
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
                            child: Text(AppLocalizations.of(context)!.questionnaire),
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