import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'services/api_service.dart';
import 'screens/video_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  final apiService = ApiService.instance;

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
//