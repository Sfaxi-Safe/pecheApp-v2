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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pêche App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const LandingPage(), // 👈 ici
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
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!hasSeenOnboarding) {
      setState(() {
        _showOnboarding = true;
      });
    } else {
      if (isLoggedIn) {
        // Tu peux ici ajouter une logique supplémentaire pour charger l’utilisateur
        Get.offAll(() => const DashboardScreen());
      } else {
        setState(() {
          _showOnboarding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: _showOnboarding! ? const OnboardingPage() : const LoginScreen(),
    );
  }
}
