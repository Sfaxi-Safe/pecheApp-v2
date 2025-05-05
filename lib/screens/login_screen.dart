import 'package:flutter/material.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/screens/pecheur/dashboard_screen.dart';
import 'package:seatrace/screens/veterinaire/dashboard_screen.dart';
import 'package:seatrace/screens/maryeur/dashboard_screen.dart';
import 'package:seatrace/screens/client/dashboard_screen.dart';
import 'package:seatrace/screens/signup_screen.dart';
import 'package:seatrace/utils/validators.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/error_display.dart';
import 'package:seatrace/widgets/sea_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user == null) {
        setState(() {
          _errorMessage = 'Email ou mot de passe incorrect';
          _isLoading = false;
        });
        return;
      }

      // Navigate to the appropriate dashboard based on user role
      if (!mounted) return;

      if (user.isPecheur()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PecheurDashboardScreen()),
        );
      } else if (user.isVeterinaire()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VeterinaireDashboardScreen()),
        );
      } else if (user.isMaryeur()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MaryeurDashboardScreen()),
        );
      } else if (user.isClient()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ClientDashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Rôle utilisateur non reconnu';
          _isLoading = false;
        });
      }
    } on AppError catch (e) {
      // Utiliser le message d'erreur convivial de AppError
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });

      // Journaliser l'erreur
      ErrorHandler.instance.logError(e, context: 'LoginScreen._login');
    } catch (e) {
      // Créer une AppError pour les autres types d'erreurs
      final appError = ErrorHandler.instance.handleException(
        e,
        context: 'LoginScreen._login',
      );

      setState(() {
        _errorMessage = appError.message;
        _isLoading = false;
      });

      // Journaliser l'erreur
      ErrorHandler.instance.logError(appError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDarkMode
                        ? [const Color(0xFF0F0F1A), const Color(0xFF1A1A2E)]
                        : [const Color(0xFFF8F9FA), const Color(0xFFE1F5FE)],
              ),
            ),
          ),

          // Wave pattern decoration
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://raw.githubusercontent.com/flutter/website/main/examples/layout/lakes/step5/images/lake.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and app name
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sailing,
                              size: 64,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // App name
                          Text(
                            'SeaTrace',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Tagline
                          Text(
                            'De la mer à l\'assiette, la transparence est le meilleur enchérisseur',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Connexion',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Entrez votre adresse email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                hintText: 'Entrez votre mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: Validators.validatePassword,
                            ),

                            // Error message
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              FormErrorDisplay(message: _errorMessage),
                              const SizedBox(height: 8),
                              if (_errorMessage!.contains('trop de temps') ||
                                  _errorMessage!.contains('connexion') ||
                                  _errorMessage!.contains('internet')) ...[
                                Text(
                                  'Conseils de dépannage:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '• Vérifiez votre connexion internet\n'
                                  '• Assurez-vous que le serveur est en cours d\'exécution\n'
                                  '• Essayez de vous connecter plus tard',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomButton.outline(
                                  text: 'Réessayer',
                                  onPressed: _isLoading ? null : _login,
                                  size: CustomButtonSize.small,
                                ),
                              ],
                            ],

                            const SizedBox(height: 24),

                            // Login button
                            CustomButton.filled(
                              text: 'Se connecter',
                              onPressed: _isLoading ? null : _login,
                              isLoading: _isLoading,
                              size: CustomButtonSize.large,
                              width: double.infinity,
                            ),

                            const SizedBox(height: 16),

                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Vous n\'avez pas de compte?',
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CustomButton.text(
                                  text: 'Créer un compte',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                                  size: CustomButtonSize.small,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
