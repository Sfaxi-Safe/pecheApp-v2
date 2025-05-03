import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'services/api_service.dart';
import 'screens/video_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  ApiService.instance; // Initialize singleton

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
      // Désactiver la bannière de débogage et les indicateurs de débordement
      builder: (context, child) {
        // Désactiver les indicateurs de débordement (barre jaune et noire)
        return MediaQuery(
          // Définir un padding de sécurité pour éviter les débordements
          data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
          child: child!,
        );
      },
      // Utiliser des transitions de page personnalisées
      onGenerateRoute: (settings) {
        // Si nous avons une route nommée, nous pouvons l'utiliser ici
        if (settings.name == null) {
          return MaterialPageRoute(
            builder:
                (context) =>
                    _isLoading
                        ? const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        )
                        : _initialScreen,
          );
        }

        // Sinon, utiliser une transition par défaut
        return PageRouteBuilder(
          settings: settings,
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  _isLoading
                      ? const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      )
                      : _initialScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
      home:
          _isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _initialScreen,
    );
  }
}
//