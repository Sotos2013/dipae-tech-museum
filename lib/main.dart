import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled1/translation_helper.dart';
import 'final_quiz_screen.dart';
import 'qr_info_screen.dart';
import 'qr_scanner_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("❌ Σφάλμα φόρτωσης .env: $e");
  }
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

// Stateful για δυναμική αλλαγή γλώσσας
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
        primaryColor: const Color(0xFF005580),
        scaffoldBackgroundColor: const Color(0xFF224366),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF005580),
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

    // Εκτελείται αφού φορτωθεί πλήρως το πρώτο frame
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
      backgroundColor: Color(0xFF224366),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator(color: Colors.white,))
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
              child: Text(AppLocalizations.of(context)!.retry, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF224366))),
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
    _checkAndShowHelpDialog();
  }

  Future<void> _checkAndShowHelpDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHelp = prefs.getBool('hasSeenHelp') ?? false;
    if (!hasSeenHelp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showHelpDialog(context);
      });
      await prefs.setBool('hasSeenHelp', true);
    }
  }

  Future<void> _fetchRandomExhibit() async {
    setState(() => _isLoading = true);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult != ConnectivityResult.none;

      if (!hasInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noInternet),
            backgroundColor: Colors.red,
          ),
        );
        return; // 🛑 Βγαίνουμε χωρίς να αλλάξουμε το randomExhibit
      }

      final response = await Supabase.instance.client
          .rpc('get_random_exhibit')
          .maybeSingle();

      if (response == null) return;

      String name = response["name"] ?? "Άγνωστο Έκθεμα";
      String description = response["description"] ?? "Δεν υπάρχει περιγραφή.";
      final locale = Localizations.localeOf(context).languageCode;

      if (locale == 'en') {
        final translations = await Future.wait([
          TranslationHelper.translate(name, 'el', 'en'),
          TranslationHelper.translate(description, 'el', 'en'),
        ]);
        name = translations[0];
        description = translations[1];
      }

      setState(() {
        randomExhibit = {
          "id": response["id"],
          "name": name,
          "description": description,
          "imageUrl": response["imageUrl"] ?? "",
        };
      });
    } catch (e) {
      print("❌ Σφάλμα: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Timer? _debounce;

  Future<void> _searchExhibits(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults.clear();
        isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final currentQuery = searchController.text.trim();

      if (currentQuery.isEmpty) {
        if (mounted) {
          setState(() {
            searchResults.clear();
            isSearching = false;
          });
        }
        return;
      }

      final response = await Supabase.instance.client
          .rpc('search_exhibits', params: {
        'search_term': currentQuery,
      });

      final locale = Localizations.localeOf(context).languageCode;
      final translated = <Map<String, dynamic>>[];

      for (var exhibit in response) {
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

      //Εξασφάλιση ότι το query δεν άλλαξε στο μεταξύ
      if (currentQuery == searchController.text.trim()) {
        if (mounted) {
          setState(() {
            searchResults = translated;
            isSearching = true;
          });
        }
      }
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
    _debounce?.cancel();
    _subscription.cancel();
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
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF224366),
          title: Text(
            AppLocalizations.of(context)!.helpTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpRow(Icons.search, AppLocalizations.of(context)!.searchHelp),
              _buildHelpRow(Icons.info_outline, AppLocalizations.of(context)!.tapExhibitHelp),
              _buildHelpRow(Icons.qr_code_scanner, AppLocalizations.of(context)!.scanQrHelp),
              _buildHelpRow(Icons.language, AppLocalizations.of(context)!.changeLanguageHelp),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.museumTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(context),
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFFD41C1C),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  if (isSearching)
                    _buildSearchResults(context)
                  else if (randomExhibit != null)
                    _buildMainInfo(context),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
          );
        },
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
  Widget _buildMainInfo(BuildContext context) {
    return Column(
      children: [
        if (randomExhibit != null) _buildRandomExhibitCard(context),
        const SizedBox(height: 20),
        _buildMuseumInfoSection(context),
        const SizedBox(height: 20),
        _buildUniversityLogo(context),
        const SizedBox(height: 20),
        _buildFinalQuizButton(context),
        const SizedBox(height: 20),
        _buildFeedbackButton(context),
      ],
    );
  }
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF005580),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchPlaceholder,
          prefixIcon: const Icon(Icons.search, color: Color(0xFF005580)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        onChanged: _searchExhibits,
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noResults,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return Column(
      children: searchResults.map((exhibit) => _buildExhibitTile(context, exhibit)).toList(),
    );
  }
  Widget _buildExhibitTile(BuildContext context, Map<String, dynamic> exhibit) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QRInfoScreen(
              id: exhibit['id'],
              name: exhibit['name'],
              description: exhibit['description'],
              imageUrl: exhibit['imageUrl'],
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              exhibit['imageUrl'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Color(0xFFD41C1C)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              exhibit['name'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        exhibit['description'],
        style: const TextStyle(fontSize: 14, color: Colors.white70),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  Future<void> _onRefresh() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      await _fetchRandomExhibit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noInternet),
          backgroundColor: const Color(0xFFD41C1C),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  Widget _buildFeedbackButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final url = Uri.parse("https://docs.google.com/forms/d/e/1FAIpQLSeve-CdFpu5gper6D2QnmHu6cs99fqvGeK7A2UCNmk6JRZWjQ/viewform");
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.noInternet)),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD41C1C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(AppLocalizations.of(context)!.questionnaire),
    );
  }
  Widget _buildFinalQuizButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FinalQuizScreen()));
      },
      icon: const Icon(Icons.school),
      label: Text(AppLocalizations.of(context)!.finalQuiz),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget _buildUniversityLogo(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/ihu_logo.png', height: 80),
        Text(
          AppLocalizations.of(context)!.ihuName,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
  Widget _buildMuseumInfoSection(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF005580),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.trainStory,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              AppLocalizations.of(context)!.discoverTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.discoverItems,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRandomExhibitCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QRInfoScreen(
              id: randomExhibit!['id'],
              name: randomExhibit!['name'],
              description: randomExhibit!['description'],
              imageUrl: randomExhibit!['imageUrl'],
            ),
          ),
        ).then((_) => _fetchRandomExhibit());
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
                "${AppLocalizations.of(context)!.randomExhibit} : ${randomExhibit!['name']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}