import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString('language_code');

    if (savedLangCode != null && ['en', 'el'].contains(savedLangCode)) {
      // Αν υπάρχει αποθηκευμένη γλώσσα και είναι έγκυρη
      setState(() {
        _locale = Locale(savedLangCode);
      });
    } else {
      // Χρήση της κύριας γλώσσας του συστήματος Android
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      final systemLangCode = systemLocales.isNotEmpty
          ? systemLocales.first.languageCode
          : 'en';

      setState(() {
        _locale = Locale(systemLangCode == 'el' ? 'el' : 'en');
      });
    }
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
        Locale('el'),
        Locale('en'),
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
      backgroundColor: const Color(0xFF163E66),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/playstore-icon.png',
              height: 100,
            ),
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
      hasInternet = true;
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
      backgroundColor: const Color(0xFF224366),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
            Text(AppLocalizations.of(context)!.noInternetMessage, style: const TextStyle(color: Colors.white)),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? randomExhibit;
  bool _showWebCategoryMenu = false;
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchFocused = false;
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  bool _isOffline = false;
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _showCategories = false;

  final List<Map<String, dynamic>> categories = [
    {
      'id': 'all',
      'name': 'Όλα τα εκθέματα',
      'name_en': 'All Exhibits',
      'icon': MdiIcons.formatListBulletedSquare,
    },
    {
      'id': 'computers',
      'name': 'Υπολογιστές',
      'name_en': 'Computers',
      'icon': MdiIcons.desktopClassic,
    },
    {
      'id': 'telecommunications',
      'name': 'Τηλεπικοινωνίες',
      'name_en': 'Telecommunications',
      'icon': MdiIcons.transmissionTower,
    },
    {
      'id': 'audio',
      'name': 'Ήχος & Μουσική',
      'name_en': 'Audio & Music',
      'icon': MdiIcons.music,
    },
    {
      'id': 'electronic_components',
      'name': 'Ηλεκτρονικά Εξαρτήματα',
      'name_en': 'Electronic Components',
      'icon': MdiIcons.resistor,
    },
  ];

  @override
  void initState() {
    _searchFocusNode.addListener(() {
      if (mounted) {
        final hasFocus = _searchFocusNode.hasFocus;

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _searchFocused = hasFocus;
              _showWebCategoryMenu = kIsWeb && hasFocus;
            });
          }
        });

        if (hasFocus) {
          _searchExhibits('%');
        }
      }
    });
    super.initState();
    _fetchRandomExhibit().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        return;
      }

      final response = await Supabase.instance.client
          .rpc('get_random_exhibit')
          .maybeSingle();

      if (response == null) return;

      final locale = Localizations.localeOf(context).languageCode;

      String name = response["name"] ?? "Άγνωστο Έκθεμα";
      String name_en = response["name_en"] ?? "Unknown Exhibit";
      String description = response["description"] ?? "Δεν υπάρχει περιγραφή.";
      String description_en = response["description_en"] ?? "No description.";
      String imageUrl = response["imageUrl"] ?? "No image.";
      setState(() {
        randomExhibit = {
          "id": response["id"],
          "name": name,
          "name_en": name_en,
          "description": description,
          "description_en": description_en,
          "imageUrl": imageUrl,
        };
      });
    } catch (e) {
      print("❌ Σφάλμα: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllExhibitsByCategory(String categoryId) async {
    final locale = Localizations.localeOf(context).languageCode;

    final searchColumn = locale == 'en' ? 'name_en' : 'name';

    final response = await Supabase.instance.client
        .rpc('search_exhibits', params: {
      'search_term': '%',
      'lang': searchColumn,
      'category_id': categoryId,
    });

    final items = <Map<String, dynamic>>[];

    for (var exhibit in response) {
      items.add({
        "id": exhibit["id"] ?? "",
        "name": exhibit["name"] ?? "",
        "name_en": exhibit["name_en"] ?? "",
        "description": exhibit["description"] ?? "",
        "description_en": exhibit["description_en"] ?? "",
        "imageUrl": exhibit["imageUrl"] ?? "",
      });
    }

    if (mounted) {
      setState(() {
        searchResults = items;
      });
    }
  }

  Future<void> _fetchExhibitsByCategory(String categoryId) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    if (categoryId == 'all') {
      await _fetchRandomExhibit();
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .rpc('get_exhibits_by_category', params: {
        'category_input': categoryId,
      });

      if (!mounted || response.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final exhibit = response[Random().nextInt(response.length)];
      final locale = Localizations.localeOf(context).languageCode;

      setState(() {
        randomExhibit = {
          "id": exhibit["id"],
          "name": exhibit["name"],
          "name_en": exhibit["name_en"],
          "description": exhibit["description"],
          "description_en": exhibit["description_en"],
          "imageUrl": exhibit["imageUrl"],
          "category": exhibit["category"],
        };
      });
    } catch (e) {
      print("❌ Σφάλμα φόρτωσης κατηγορίας: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Timer? _debounce;

  Future<void> _searchExhibits(String query) async {
    final trimmed = query.trim();
    final searchTerm = trimmed.isEmpty ? '%' : '%$trimmed';

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final locale = Localizations.localeOf(context).languageCode;
      String searchColumn = locale == 'en' ? 'name_en' : 'name';

      final categoryId = categories[_selectedIndex]['id'];
      final shouldFilterCategory = categoryId != 'all';

      final response = await Supabase.instance.client
          .rpc('search_exhibits', params: {
        'search_term': searchTerm,
        'lang': searchColumn,
        'category_id': shouldFilterCategory ? categoryId : 'all',
      });

      final translated = <Map<String, dynamic>>[];
      print("🔍 Response: $response");


      for (var exhibit in response) {
        translated.add({
          "id": exhibit["id"] ?? "",
          "name": exhibit["name"] ?? "",
          "name_en": exhibit["name_en"] ?? "",
          "description": exhibit["description"] ?? "Δεν υπάρχει περιγραφή.",
          "description_en": exhibit["description_en"] ?? "No description.",
          "imageUrl": exhibit["imageUrl"] ?? "",
        });
        print("🔍 Response: ${exhibit['imageUrl']}");
      }

      if (mounted) {
        setState(() {
          searchResults = translated;
          isSearching = true;
        });
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
    _searchFocusNode.dispose();
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
          backgroundColor: const Color(0xFF224366),
          title: Text(
            AppLocalizations.of(context)!.aboutAppTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(AppLocalizations.of(context)!.museumDes,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              _buildHelpRow(Icons.category, AppLocalizations.of(context)!.categoryHelp),
              _buildHelpRow(Icons.info_outline, AppLocalizations.of(context)!.tapExhibitHelp),
              _buildHelpRow(Icons.qr_code_scanner, AppLocalizations.of(context)!.scanQrHelp),
              _buildHelpRow(Icons.language, AppLocalizations.of(context)!.changeLanguageHelp),
              _buildHelpRow(Icons.touch_app_rounded, AppLocalizations.of(context)!.tapHelp),
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

  Widget _buildCategoriesMenu(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showCategories ? 200 : 0,
      decoration: BoxDecoration(
        color: const Color(0xFF163E66),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: categories.map((category) => ListTile(
            leading: Icon(category['icon'], color: Colors.white),
            title: Text(
              locale == 'en' ? category['name_en'] : category['name'],
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = categories.indexOf(category);
                _showCategories = false;
              });
              _fetchExhibitsByCategory(category['id']);
            },
          )).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // Αν υπάρχει αναζήτηση ή οποιαδήποτε κατηγορία έχει επιλεγεί
        if (isSearching || _selectedIndex != 0) {
          setState(() {
            isSearching = false;
            searchController.clear();
            _selectedIndex = 0;
          });
          await _fetchRandomExhibit(); // Επαναφορά αρχικής οθόνης
        } else {
          // Αν είμαστε ήδη στην αρχική, τότε επιτρέπουμε έξοδο
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyHomePage()),
              );
            },
            child: Text(
              AppLocalizations.of(context)!.museumTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
              onPressed: () async {
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
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() => _showCategories = false);
            },
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: 10),
                    _buildCategoriesMenu(context),
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
    final locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchPlaceholder,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF005580)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              onChanged: _searchExhibits,
            ),
          ),
          IconButton(
            icon: Icon(categories[_selectedIndex]['icon'], color: Colors.white),
            tooltip: AppLocalizations.of(context)!.chooseCategory,
            onPressed: () async {
              // Καθυστέρηση ώστε να μη χαθεί το focus και εξαφανιστεί το menu αμέσως
              await Future.delayed(const Duration(milliseconds: 100));

              final selected = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                items: categories.map((category) {
                  final title = locale == 'en' ? category['name_en'] : category['name'];
                  return PopupMenuItem<String>(
                    value: category['id'],
                    child: Row(
                      children: [
                        Icon(category['icon'], color: Colors.black),
                        const SizedBox(width: 10),
                        Text(title),
                      ],
                    ),
                  );
                }).toList(),
              );

              if (!mounted || selected == null) return;

              final index = categories.indexWhere((c) => c['id'] == selected);
              setState(() => _selectedIndex = index);

              final query = searchController.text.trim();
              if (query.isEmpty) {
                await _fetchAllExhibitsByCategory(selected);
                setState(() => isSearching = true);
              } else {
                _searchExhibits(query);
              }
            },
          ),
        ],
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
    final locale = Localizations.localeOf(context).languageCode;
    final displayName = locale == 'en' ? exhibit['name_en'] : exhibit['name'];
    final displayDescription = locale == 'en' ? exhibit['description_en'] : exhibit['description'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF163E66),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QRInfoScreen(
                id: exhibit['id'] ?? '',
                name: exhibit['name'] ?? '',
                name_en: exhibit['name_en'] ?? '',
                description: exhibit['description'] ?? '',
                description_en: exhibit['description_en'] ?? '',
                imageUrl: exhibit['imageUrl'] ?? '',
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            exhibit['imageUrl'] ?? '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image,
              size: 50,
              color: Color(0xFFD41C1C),
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          displayDescription,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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
        final locale = Localizations.localeOf(context).languageCode;

        final url = Uri.parse(
          locale == 'en'
              ? "https://docs.google.com/forms/d/e/1FAIpQLScNlIzKkxiP1jgLTaUS-3xiQjYt6O7UMpZ3rm1gGygJazSiKg/viewform"
              : "https://docs.google.com/forms/d/e/1FAIpQLSeve-CdFpu5gper6D2QnmHu6cs99fqvGeK7A2UCNmk6JRZWjQ/viewform",
        );

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
              id: randomExhibit!['id'] ?? '',
              name: randomExhibit!['name'] ?? '',
              name_en: randomExhibit!['name_en'] ?? '',
              description: randomExhibit!['description'] ?? '',
              description_en: randomExhibit!['description_en'] ?? '',
              imageUrl: randomExhibit!['imageUrl'] ?? '',
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
              child: randomExhibit!['imageUrl'] != null && randomExhibit!['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                randomExhibit!['imageUrl'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100, color: Colors.red),
              )
                  : const Icon(Icons.broken_image, size: 150, color: Colors.red),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "${AppLocalizations.of(context)!.randomExhibit} : ${(Localizations.localeOf(context).languageCode == 'en'
                    ? randomExhibit!['name_en']
                    : randomExhibit!['name']) ?? ''}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}