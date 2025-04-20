// Importation des packages Flutter nécessaires
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pour la gestion d'état
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Pour les icônes supplémentaires

// Importation des écrans de l'application
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/client/home_screen.dart';
import 'screens/fisherman/dashboard_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/messaging/conversations_screen.dart';
import 'screens/messaging/chat_screen.dart';
import 'screens/payment/payment_screen.dart';

// Importation des services de l'application
import 'services/auth_service.dart';
import 'services/fish_service.dart';
import 'services/order_service.dart';
import 'services/statistics_service.dart';
import 'services/database_helper.dart';
import 'services/message_service.dart';
import 'services/payment_service.dart';
import 'services/notification_service.dart';

// Importation des utilitaires
import 'utils/app_theme.dart';
import 'utils/theme_provider.dart';
import 'utils/image_cache_manager.dart';

// Point d'entrée de l'application
void main() async {
  // Assurez-vous que les widgets Flutter sont initialisés avant d'utiliser des plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données SQLite
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Initialiser le gestionnaire de cache d'images pour optimiser le chargement des images
  await ImageCacheManager.initialize();

  // Lancer l'application
  runApp(const MyApp());
}

/// Classe principale de l'application
/// Définit la structure globale et les fournisseurs d'état
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Configuration des fournisseurs d'état (providers) pour la gestion d'état
      providers: [
        // Fournir une instance unique de DatabaseHelper
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper()),
        
        // Services avec ChangeNotifier pour la réactivité
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FishService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => MessageService()),
        ChangeNotifierProvider(create: (_) => PaymentService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Services dépendant d'autres services
        ChangeNotifierProxyProvider<FishService, StatisticsService>(
          create: (context) => StatisticsService(
            Provider.of<FishService>(context, listen: false),
          ),
          update: (context, fishService, previous) =>
              previous?.update(fishService) ?? StatisticsService(fishService),
        ),
      ],
      // Construction de l'application en fonction de l'état d'authentification et du thème
      child: Consumer2<AuthService, ThemeProvider>(
        builder: (context, authService, themeProvider, _) {
          // Ajouter des utilisateurs de test pour le développement
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authService.addTestUsers();
          });

          // Configuration de l'application MaterialApp
          return MaterialApp(
            title: 'Pêche App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(), // Écran initial déterminé par l'état d'authentification
            
            // Définition des routes nommées pour la navigation
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/fisherman/dashboard': (context) => const DashboardScreen(),
              '/client/home': (context) => const HomeScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/statistics': (context) => const StatisticsScreen(),
              '/conversations': (context) => const ConversationsScreen(),
            },
            
            // Générateur de routes pour les écrans qui nécessitent des paramètres
            onGenerateRoute: (settings) {
              // Route pour l'écran de chat qui nécessite des paramètres
              if (settings.name == '/chat') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    otherUserId: args['otherUserId'],
                    otherUserName: args['otherUserName'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

/// Wrapper d'authentification qui détermine quel écran afficher
/// en fonction de l'état d'authentification de l'utilisateur
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    // Récupérer le service d'authentification
    final authService = Provider.of<AuthService>(context);

    // Afficher un indicateur de chargement pendant la vérification de l'authentification
    if (authService.isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade300, Colors.blue.shade900],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sailing, size: 80, color: Colors.white),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si l'utilisateur est authentifié, rediriger vers l'écran approprié
    if (authService.isAuthenticated) {
      if (authService.isFisherman) {
        // Initialiser les services nécessaires pour le pêcheur
        final orderService = Provider.of<OrderService>(context, listen: false);
        final messageService = Provider.of<MessageService>(context, listen: false);
        final paymentService = Provider.of<PaymentService>(context, listen: false);
        final notificationService = Provider.of<NotificationService>(context, listen: false);

        // Initialiser les services avec l'ID de l'utilisateur après le rendu
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authService.currentUser?.id != null) {
            final userId = authService.currentUser!.id.toString();
            orderService.init(userId, 'fisherman');
            messageService.init(userId);
            paymentService.init(userId);
            notificationService.init(userId);
          }
        });

        // Afficher le tableau de bord du pêcheur
        return const DashboardScreen();
      } else if (authService.isClient) {
        // Initialiser les services nécessaires pour le client
        final orderService = Provider.of<OrderService>(context, listen: false);
        final messageService = Provider.of<MessageService>(context, listen: false);
        final paymentService = Provider.of<PaymentService>(context, listen: false);
        final notificationService = Provider.of<NotificationService>(context, listen: false);

        // Initialiser les services avec l'ID de l'utilisateur après le rendu
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authService.currentUser?.id != null) {
            final userId = authService.currentUser!.id.toString();
            orderService.init(userId, 'client');
            messageService.init(userId);
            paymentService.init(userId);
            notificationService.init(userId);
          }
        });

        // Afficher l'écran d'accueil du client
        return const HomeScreen();
      }
    }

    // Si l'utilisateur n'est pas authentifié, afficher l'écran d'accueil
    return const WelcomeScreen();
  }
}

/// Écran d'accueil de l'application
/// Permet à l'utilisateur de choisir son profil (pêcheur ou client)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fond dégradé pour l'écran d'accueil
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
                // Logo de l'application
                const Icon(Icons.sailing, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                
                // Titre de l'application
                const Text(
                  'Bienvenue sur Pêche App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Description de l'application
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Connectez directement les pêcheurs et les clients pour des produits frais et de qualité',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Instruction pour choisir un profil
                const Text(
                  'Choisissez votre profil',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 30),
                
                // Bouton pour les pêcheurs
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userType: 'fisherman'),
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
                
                // Bouton pour les clients
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(userType: 'client'),
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
                const SizedBox(height: 40),
                
                // Bouton d'information sur l'application
                TextButton(
                  onPressed: () {
                    // Afficher les informations sur l'application
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('À propos de Pêche App'),
                        content: const Text(
                          'Pêche App est une plateforme qui connecte directement les pêcheurs et les clients, '
                          'permettant l\'achat de produits frais de la mer sans intermédiaires.\n\n'
                          'Version 1.0.0',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fermer'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'À propos',
                    style: TextStyle(color: Colors.white),
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
