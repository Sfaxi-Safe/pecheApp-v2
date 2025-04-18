import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/home_screen.dart';
import 'screens/fisherman/dashboard_screen.dart';
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
  
  // Initialiser la base de données
  await DatabaseHelper().database;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FishService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => MessageService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProxyProvider<FishService, StatisticsService>(
          create: (context) => StatisticsService(
            Provider.of<FishService>(context, listen: false),
          ),
          update: (context, fishService, previous) => 
            StatisticsService(fishService),
        ),
      ],
      child: Consumer2<AuthService, ThemeProvider>(
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
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Afficher un indicateur de chargement pendant la vérification de l'authentification
    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si l'utilisateur est authentifié, rediriger vers l'écran approprié
    if (authService.isAuthenticated) {
      if (authService.isFisherman) {
        // Initialiser les services nécessaires pour le pêcheur
        final fishService = Provider.of<FishService>(context, listen: false);
        final orderService = Provider.of<OrderService>(context, listen: false);
        final messageService = Provider.of<MessageService>(context, listen: false);
        final paymentService = Provider.of<PaymentService>(context, listen: false);
        
        // Initialiser les services avec l'ID de l'utilisateur
        WidgetsBinding.instance.addPostFrameCallback((_) {
          orderService.init(authService.currentUser!.id, 'fisherman');
          messageService.init(authService.currentUser!.id);
          paymentService.init(authService.currentUser!.id);
        });
        
        return const DashboardScreen();
      } else if (authService.isClient) {
        // Initialiser les services nécessaires pour le client
        final fishService = Provider.of<FishService>(context, listen: false);
        final orderService = Provider.of<OrderService>(context, listen: false);
        final messageService = Provider.of<MessageService>(context, listen: false);
        final paymentService = Provider.of<PaymentService>(context, listen: false);
        
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
