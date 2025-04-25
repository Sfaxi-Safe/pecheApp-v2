import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/app_theme.dart';
import 'services/firebase_service.dart';
import 'screens/video_splash_screen.dart';
import 'firebase_options.dart';
import 'utils/firebase_data_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase service
  await FirebaseService().initialize();

  // Initialize demo data in Firebase
  await FirebaseDataInitializer().initializeDemoData();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  final Widget _initialScreen =
      const VideoSplashScreen(); // Utiliser l'écran de démarrage vidéo

  @override
  void initState() {
    super.initState();
    // Nous n'avons plus besoin de vérifier l'utilisateur ici car l'écran de démarrage vidéo
    // redirigera vers l'écran de connexion
    _loadApp();
  }

  Future<void> _loadApp() async {
    // Simuler un temps de chargement pour l'initialisation de l'application
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeaTrace',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home:
          _isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _initialScreen,
    );
  }
}
