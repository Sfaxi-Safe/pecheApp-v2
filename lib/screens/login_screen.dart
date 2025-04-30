import 'package:flutter/material.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/screens/pecheur/dashboard_screen.dart';
import 'package:seatrace/screens/vitirinaire/dashboard_screen.dart';
import 'package:seatrace/screens/maryeur/dashboard_screen.dart';
import 'package:seatrace/screens/client/dashboard_screen.dart';
import 'package:seatrace/screens/signup_screen.dart';
import 'package:seatrace/utils/validators.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/error_display.dart';

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
          MaterialPageRoute(builder: (_) => const VitirinaireScreen()),
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and app name
                Column(
                  children: [
                    Icon(
                      Icons.sailing,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SeaTrace',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Application de traçabilité et de vente de produits de la mer',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
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
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        FormErrorDisplay(message: _errorMessage),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Se connecter'),
                      ),

                      const SizedBox(height: 16),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Vous n\'avez pas de compte?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text('Créer un compte'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Demo accounts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comptes de démonstration:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildDemoAccount(
                          'Pêcheur',
                          'pecheur@example.com',
                          'password123',
                        ),
                        const Divider(),
                        _buildDemoAccount(
                          'Vétérinaire',
                          'vet@example.com',
                          'password123',
                        ),
                        const Divider(),
                        _buildDemoAccount(
                          'Maryeur',
                          'maryeur@example.com',
                          'password123',
                        ),
                        const Divider(),
                        _buildDemoAccount(
                          'Client',
                          'client@example.com',
                          'password123',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccount(String role, String email, String password) {
    return InkWell(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = password;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(email, style: const TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
