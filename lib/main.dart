import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:peche_app/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peche_app/screens/auth/login_screen.dart';
import 'package:peche_app/screens/client/home_screen.dart';
import 'package:peche_app/screens/fisherman/dashboard_screen.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/services/order_service.dart';
import 'package:peche_app/services/statistics_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FishService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProxyProvider<FishService, StatisticsService>(
          create:
              (context) => StatisticsService(
                Provider.of<FishService>(context, listen: false),
              ),
          update:
              (context, fishService, previous) =>
                  StatisticsService(fishService),
        ),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pêche App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: hasSeenOnboarding ? const LoginScreen() : const OnboardingPage(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/fisherman/dashboard': (context) => const DashboardScreen(),
        '/client/home': (context) => const HomeScreen(),
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool? _showOnboarding;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _showOnboarding = !hasSeenOnboarding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sailing, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue sur Pêche App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Choisissez votre profil',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.fish),
                  label: const Text('Je suis pêcheur'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Je suis client'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
