import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/home_screen.dart';
import 'screens/fisherman/dashboard_screen.dart';

// Services Firebase
import 'services/firebase_auth_service.dart';
import 'services/firebase_fish_service.dart';
import 'services/firebase_order_service.dart';
import 'services/firebase_statistics_service.dart';
import 'services/firebase_message_service.dart';
import 'services/firebase_payment_service.dart';

// Services locaux (pour la compatibilité pendant la migration)
import 'services/auth_service.dart';
import 'services/fish_service.dart';
import 'services/order_service.dart';
import 'services/statistics_service.dart';
import 'services/database_helper.dart';
import 'services/message_service.dart';
import 'services/payment_service.dart';

import 'utils/app_theme.dart';
import 'utils/theme_provider.dart';

void main() async {
  // Assurez-vous que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

  // Initialiser la base de données locale (pour la compatibilité pendant la migration)
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services Firebase
        ChangeNotifierProvider(create: (_) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (_) => FirebaseFishService()),
        ChangeNotifierProvider(create: (_) => FirebaseOrderService()),
        ChangeNotifierProvider(create: (_) => FirebaseMessageService()),
        ChangeNotifierProvider(create: (_) => FirebasePaymentService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<
          FirebaseFishService,
          FirebaseStatisticsService
        >(
          create:
              (context) => FirebaseStatisticsService(
                Provider.of<FirebaseFishService>(context, listen: false),
              ),
          update:
              (context, fishService, previous) =>
                  FirebaseStatisticsService(fishService),
        ),

        // Services locaux (pour la compatibilité pendant la migration)
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FishService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => MessageService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
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
      child: Consumer2<FirebaseAuthService, ThemeProvider>(
        builder: (context, authService, themeProvider, _) {
          // Ajouter des utilisateurs de test pour le développement
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authService.addTestUsers();
          });

          return MaterialApp(
            title: 'Pêche App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/fisherman/dashboard': (context) => const DashboardScreen(),
              '/client/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context);

    // Afficher un indicateur de chargement pendant la vérification de l'authentification
    if (authService.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si l'utilisateur est authentifié, rediriger vers l'écran approprié
    if (authService.isAuthenticated) {
      if (authService.isFisherman) {
        // Initialiser les services nécessaires pour le pêcheur
        final fishService = Provider.of<FirebaseFishService>(
          context,
          listen: false,
        );
        final orderService = Provider.of<FirebaseOrderService>(
          context,
          listen: false,
        );
        final messageService = Provider.of<FirebaseMessageService>(
          context,
          listen: false,
        );
        final paymentService = Provider.of<FirebasePaymentService>(
          context,
          listen: false,
        );

        // Initialiser les services avec l'ID de l'utilisateur
        WidgetsBinding.instance.addPostFrameCallback((_) {
          orderService.init(authService.currentUser!.id, 'fisherman');
          messageService.init(authService.currentUser!.id);
          paymentService.init(authService.currentUser!.id);
        });

        return const DashboardScreen();
      } else if (authService.isClient) {
        // Initialiser les services nécessaires pour le client
        final fishService = Provider.of<FirebaseFishService>(
          context,
          listen: false,
        );
        final orderService = Provider.of<FirebaseOrderService>(
          context,
          listen: false,
        );
        final messageService = Provider.of<FirebaseMessageService>(
          context,
          listen: false,
        );
        final paymentService = Provider.of<FirebasePaymentService>(
          context,
          listen: false,
        );

        // Initialiser les services avec l'ID de l'utilisateur
        WidgetsBinding.instance.addPostFrameCallback((_) {
          orderService.init(authService.currentUser!.id, 'client');
          messageService.init(authService.currentUser!.id);
          paymentService.init(authService.currentUser!.id);
        });

        return const HomeScreen();
      }
    }

    // Si l'utilisateur n'est pas authentifié, afficher l'écran d'accueil
    return const WelcomeScreen();
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
