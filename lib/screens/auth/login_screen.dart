// Importation des packages Flutter nécessaires
import 'package:flutter/material.dart';
import 'package:peche_app/screens/auth/register_screen.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

/// Écran de connexion
/// Permet à l'utilisateur de se connecter à l'application
class LoginScreen extends StatefulWidget {
  final String? userType; // Type d'utilisateur (client ou pêcheur)
  
  const LoginScreen({super.key, this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clé pour le formulaire (permet la validation)
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de texte
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Variables d'état
  bool _isPasswordVisible = false; // Contrôle la visibilité du mot de passe
  bool _rememberMe = false;        // Option "Se souvenir de moi"
  bool _isLoading = false;         // Indique si une opération est en cours
  String? _errorMessage;           // Message d'erreur à afficher

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Méthode pour gérer la connexion
  Future<void> _login() async {
    // Valider le formulaire
    if (_formKey.currentState!.validate()) {
      // Mettre à jour l'état pour afficher le chargement et effacer les erreurs
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Récupérer le service d'authentification
        final authService = Provider.of<AuthService>(context, listen: false);
        
        // Tenter de se connecter avec les identifiants fournis
        final success = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Vérifier si le widget est toujours monté
        if (!mounted) return;

        if (success) {
          // Redirection en fonction du type d'utilisateur
          if (authService.isFisherman) {
            Navigator.pushReplacementNamed(context, '/fisherman/dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/client/home');
          }
        } else {
          // Afficher un message d'erreur en cas d'échec
          setState(() {
            _errorMessage = 'Email ou mot de passe incorrect';
          });
        }
      } catch (e) {
        // Gérer les exceptions
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Erreur de connexion: $e';
        });
      } finally {
        // Mettre à jour l'état pour masquer le chargement
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer le type d'utilisateur (client par défaut)
    final userType = widget.userType ?? 'client';
    final isClient = userType == 'client';
    
    return Scaffold(
      body: Container(
        // Fond dégradé pour l'écran de connexion
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icône différente selon le type d'utilisateur
                        Icon(
                          isClient ? Icons.shopping_cart : Icons.sailing,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        
                        // Titre avec le type d'utilisateur
                        Text(
                          'Connexion ${isClient ? 'Client' : 'Pêcheur'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Afficher le message d'erreur s'il y en a un
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Champ de saisie pour l'email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!value.contains('@')) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Champ de saisie pour le mot de passe
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer  {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Option "Se souvenir de moi" et lien "Mot de passe oublié"
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text('Se souvenir de moi'),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Naviguer vers l'écran de récupération de mot de passe
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fonctionnalité à venir'),
                                  ),
                                );
                              },
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Bouton de connexion
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Lien vers l'écran d'inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Vous n\'avez pas de compte ?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(userType: userType),
                                  ),
                                );
                              },
                              child: const Text('S\'inscrire'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Bouton pour retourner à l'écran d'accueil
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/welcome');
                          },
                          child: const Text('Retour à l\'accueil'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
