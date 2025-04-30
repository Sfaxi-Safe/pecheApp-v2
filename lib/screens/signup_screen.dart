import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:seatrace/utils/validators.dart';
import 'package:seatrace/widgets/password_strength_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();

  // Champs spécifiques pour les différents types d'utilisateurs
  final _cinController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _bateauController = TextEditingController();
  final _portController = TextEditingController();
  final _capaciteController = TextEditingController();

  String _selectedRole = 'ROLE_CLIENT';
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Pour l'indicateur de force du mot de passe
  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _cinController.dispose();
    _matriculeController.dispose();
    _bateauController.dispose();
    _portController.dispose();
    _capaciteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String password) {
    double strength = 0;

    if (password.isEmpty) {
      strength = 0;
    } else {
      // Length contribution
      if (password.length >= 8) strength += 0.2;

      // Uppercase contribution
      if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;

      // Lowercase contribution
      if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;

      // Digit contribution
      if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;

      // Special character contribution
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    }

    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to the first error
      _scrollToFirstError();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create user based on selected role
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final nom = _nomController.text.trim();
      final prenom = _prenomController.text.trim();
      int? telephone;

      if (_telephoneController.text.isNotEmpty) {
        telephone = int.tryParse(_telephoneController.text);
      }

      // Préparer les données utilisateur de base
      final userData = {
        'email': email,
        'password': password,
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
      };

      // Ajouter les champs spécifiques selon le rôle
      if (_selectedRole == 'ROLE_PECHEUR') {
        userData['role'] = 'ROLE_PECHEUR';
        userData['cin'] = _cinController.text.trim();
        userData['matricule'] = _matriculeController.text.trim();
        userData['bateau'] = _bateauController.text.trim();
        userData['port'] = _portController.text.trim();
        userData['capacite'] = _capaciteController.text.trim();
      } else if (_selectedRole == 'ROLE_VETERINAIRE') {
        userData['role'] = 'ROLE_VETERINAIRE';
        userData['cin'] = _cinController.text.trim();
        userData['matricule'] = _matriculeController.text.trim();
        userData['port'] = _portController.text.trim();
      } else if (_selectedRole == 'ROLE_MARYEUR') {
        userData['role'] = 'ROLE_MARYEUR';
        userData['cin'] = _cinController.text.trim();
        userData['matricule'] = _matriculeController.text.trim();
        userData['port'] = _portController.text.trim();
      } else {
        userData['role'] = 'ROLE_CLIENT';
      }

      // Envoyer la requête d'inscription à l'API
      await ApiService.instance.register(userData);

      // Envoyer un email de vérification (simulé)
      await _sendVerificationEmail(email);

      // Navigate to login screen
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé avec succès. Veuillez vérifier votre email pour activer votre compte.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      setState(() {
        // Vérifier si l'erreur concerne un email déjà utilisé
        if (e.toString().contains('email') &&
            e.toString().contains('utilisé')) {
          _errorMessage = 'Cet email est déjà utilisé';
        } else {
          _errorMessage = 'Une erreur est survenue: ${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _sendVerificationEmail(String email) async {
    // Simulation d'envoi d'email de vérification
    // Dans une application réelle, vous utiliseriez un service d'email
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Email de vérification envoyé à $email');
  }

  void _scrollToFirstError() {
    // Scroll to the top of the form to show the first error
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            controller: _scrollController,
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
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SeaTrace',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Créez votre compte',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Signup form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Role selection
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Type de compte',
                          prefixIcon: _getRoleIcon(_selectedRole),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ROLE_CLIENT',
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 10),
                                Text('Client'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ROLE_PECHEUR',
                            child: Row(
                              children: [
                                Icon(Icons.sailing, color: Colors.blue),
                                SizedBox(width: 10),
                                Text('Pêcheur'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ROLE_VETERINAIRE',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 10),
                                Text('Vétérinaire'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ROLE_MARYEUR',
                            child: Row(
                              children: [
                                Icon(Icons.gavel, color: Colors.orange),
                                SizedBox(width: 10),
                                Text('Maryeur'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          helperText: 'Nous enverrons un email de vérification',
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Password
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
                        validator: Validators.validateStrongPassword,
                        onChanged: (value) {
                          _updatePasswordStrength(value);
                        },
                      ),
                      const SizedBox(height: 8),

                      // Password strength indicator
                      PasswordStrengthIndicator(strength: _passwordStrength),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator:
                            (value) => Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Nom
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),

                      // Prénom
                      TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),

                      // Téléphone
                      TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone (optionnel)',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: Validators.validatePhone,
                      ),

                      // Champs spécifiques selon le rôle
                      if (_selectedRole != 'ROLE_CLIENT') ...[
                        const SizedBox(height: 24),
                        Text(
                          'Informations spécifiques',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // CIN
                        TextFormField(
                          controller: _cinController,
                          decoration: const InputDecoration(
                            labelText: 'CIN',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: Validators.validateCIN,
                        ),
                        const SizedBox(height: 16),

                        // Matricule
                        TextFormField(
                          controller: _matriculeController,
                          decoration: const InputDecoration(
                            labelText: 'Matricule',
                            prefixIcon: Icon(Icons.numbers_outlined),
                          ),
                          validator: Validators.validateMatricule,
                        ),
                        const SizedBox(height: 16),

                        // Port
                        TextFormField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            prefixIcon: Icon(Icons.anchor_outlined),
                          ),
                          validator: Validators.validatePort,
                        ),
                      ],

                      // Champs spécifiques pour les pêcheurs
                      if (_selectedRole == 'ROLE_PECHEUR') ...[
                        const SizedBox(height: 16),

                        // Bateau
                        TextFormField(
                          controller: _bateauController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du bateau',
                            prefixIcon: Icon(Icons.directions_boat_outlined),
                          ),
                          validator: Validators.validateBateau,
                        ),
                        const SizedBox(height: 16),

                        // Capacité
                        TextFormField(
                          controller: _capaciteController,
                          decoration: const InputDecoration(
                            labelText: 'Capacité (kg)',
                            prefixIcon: Icon(Icons.scale_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator:
                              (value) => Validators.validateNumeric(
                                value,
                                fieldName: 'Capacité',
                              ),
                        ),
                      ],

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Submit button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
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
                                : const Text('Créer un compte'),
                      ),

                      const SizedBox(height: 16),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Vous avez déjà un compte?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text('Se connecter'),
                          ),
                        ],
                      ),

                      // Mot de passe oublié
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Mot de passe oublié?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text('Réinitialiser'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getRoleIcon(String role) {
    switch (role) {
      case 'ROLE_CLIENT':
        return const Icon(Icons.person, color: Colors.blue);
      case 'ROLE_PECHEUR':
        return const Icon(Icons.sailing, color: Colors.blue);
      case 'ROLE_VETERINAIRE':
        return const Icon(Icons.medical_services, color: Colors.green);
      case 'ROLE_MARYEUR':
        return const Icon(Icons.gavel, color: Colors.orange);
      default:
        return const Icon(Icons.person, color: Colors.blue);
    }
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Appeler l'API pour réinitialiser le mot de passe
      try {
        // Simuler un appel API pour vérifier si l'email existe
        await ApiService.instance.post('auth/request-reset', {
          'email': _emailController.text.trim(),
        });

        setState(() {
          _message =
              'Un email de réinitialisation a été envoyé à ${_emailController.text}';
          _isLoading = false;
          _isSuccess = true;
        });
      } catch (apiError) {
        // Si l'API renvoie une erreur indiquant que l'email n'existe pas
        setState(() {
          _message = 'Aucun compte associé à cet email';
          _isLoading = false;
          _isSuccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Une erreur est survenue: ${e.toString()}';
        _isLoading = false;
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Réinitialisation du mot de passe',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Entrez votre adresse email pour recevoir un lien de réinitialisation de mot de passe',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
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
                      const SizedBox(height: 24),
                      if (_message != null) ...[
                        Text(
                          _message!,
                          style: TextStyle(
                            color:
                                _isSuccess
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                      ],
                      ElevatedButton(
                        onPressed: _isLoading ? null : _resetPassword,
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
                                : const Text(
                                  'Envoyer le lien de réinitialisation',
                                ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Retour à la connexion'),
                      ),
                    ],
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
