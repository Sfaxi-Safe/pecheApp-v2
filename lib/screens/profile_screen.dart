import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/image_service.dart';
import 'package:seatrace/utils/validators.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;
  String? _successMessage;

  Map<String, dynamic>? _userData;
  String _userType = '';
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      Map<String, dynamic>? userData;

      if (user.isPecheur()) {
        userData = await ApiService.instance.getPecheurDetails(user.id!);
        _userType = 'Pêcheur';
      } else if (user.isVeterinaire()) {
        userData = await ApiService.instance.getVeterinaireDetails(user.id!);
        _userType = 'Vétérinaire';
      } else if (user.isMaryeur()) {
        userData = await ApiService.instance.getMaryeurDetails(user.id!);
        _userType = 'Maryeur';
      } else if (user.roles.contains('ROLE_ADMIN')) {
        userData = await ApiService.instance.getAdminById(user.id);
        _userType = 'Administrateur';
      } else {
        userData = await ApiService.instance.get('clients/${user.id}');
        _userType = 'Client';
      }

      // Utiliser une variable locale pour éviter les problèmes de null-safety
      if (userData != null) {
        final Map<String, dynamic> data = userData;

        setState(() {
          _userData = data;

          // Accéder aux propriétés de manière sécurisée
          _nomController.text = (data['nom'] ?? '').toString();
          _prenomController.text = (data['prenom'] ?? '').toString();
          _telephoneController.text = (data['telephone'] ?? '').toString();
          _photoPath = data['photo']?.toString();
          _isLoading = false;
        });
      } else {
        throw Exception('Données utilisateur non trouvées');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Télécharger l'image sur le serveur
        final imageFile = File(pickedFile.path);
        final imageUrl = await ImageService.instance.uploadImage(imageFile);

        if (imageUrl == null) {
          throw Exception('Échec du téléchargement de l\'image');
        }

        // Mettre à jour le chemin de la photo dans la base de données
        final user = await AuthService().getCurrentUser();
        if (user == null) {
          throw Exception('Utilisateur non connecté');
        }

        final updatedData = {'id': user.id, 'photo': imageUrl};

        String endpoint = '';
        if (user.isPecheur()) {
          endpoint = 'pecheurs/${user.id}';
        } else if (user.isVeterinaire()) {
          endpoint = 'veterinaires/${user.id}';
        } else if (user.isMaryeur()) {
          endpoint = 'maryeurs/${user.id}';
        } else if (user.roles.contains('ROLE_ADMIN')) {
          endpoint = 'admins/${user.id}';
        } else {
          endpoint = 'clients/${user.id}';
        }
        await ApiService.instance.put(endpoint, updatedData);

        // Rafraîchir les données utilisateur
        await _loadUserData();

        setState(() {
          _successMessage = 'Photo de profil mise à jour avec succès';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Erreur lors de la mise à jour de la photo: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choisir une source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Appareil photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final updatedData = {
        'id': user.id,
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'telephone':
            _telephoneController.text.isEmpty
                ? null
                : int.tryParse(_telephoneController.text),
      };

      String endpoint = '';
      if (user.isPecheur()) {
        endpoint = 'pecheurs/${user.id}';
      } else if (user.isVeterinaire()) {
        endpoint = 'veterinaires/${user.id}';
      } else if (user.isMaryeur()) {
        endpoint = 'maryeurs/${user.id}';
      } else if (user.roles.contains('ROLE_ADMIN')) {
        endpoint = 'admins/${user.id}';
      } else {
        endpoint = 'clients/${user.id}';
      }

      await ApiService.instance.put(endpoint, updatedData);

      // Mettre à jour les données de l'utilisateur en session
      await AuthService().refreshCurrentUser();

      setState(() {
        _successMessage = 'Profil mis à jour avec succès';
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les nouveaux mots de passe ne correspondent pas';
      });
      return;
    }

    setState(() {
      _isChangingPassword = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier l'ancien mot de passe
      // Mettre à jour le mot de passe via l'API
      final passwordData = {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      };

      await ApiService.instance.put('auth/change-password', passwordData);

      // Effacer les champs
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      setState(() {
        _successMessage = 'Mot de passe mis à jour avec succès';
        _isChangingPassword = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isChangingPassword = false;
      });
    }
  }

  // Méthode pour obtenir les initiales de l'utilisateur
  String _getInitials() {
    if (_userData == null) return '?';

    final prenom = _userData!['prenom'] as String?;
    final nom = _userData!['nom'] as String?;

    String initials = '';

    if (prenom != null && prenom.isNotEmpty) {
      initials += prenom[0];
    }

    if (nom != null && nom.isNotEmpty) {
      initials += nom[0];
    }

    return initials.isEmpty ? '?' : initials;
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null && _userData == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête du profil avec photo
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Photo de profil
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  GestureDetector(
                                    onTap:
                                        _isUploadingPhoto
                                            ? null
                                            : _showImageSourceDialog,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor.withAlpha(25),
                                      backgroundImage:
                                          _photoPath != null &&
                                                  _photoPath!.isNotEmpty
                                              ? NetworkImage(
                                                ImageService.instance
                                                    .getImageUrl(_photoPath!),
                                              )
                                              : null,
                                      child:
                                          _photoPath == null ||
                                                  _photoPath!.isEmpty
                                              ? Text(
                                                _getInitials(),
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              )
                                              : null,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child:
                                        _isUploadingPhoto
                                            ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : IconButton(
                                              icon: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              onPressed: _showImageSourceDialog,
                                              tooltip: 'Changer la photo',
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_userData!['prenom']} ${_userData!['nom']}',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _userData!['email'],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _userType,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Messages de succès ou d'erreur
                      if (_successMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
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

                      // Formulaire de modification du profil
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informations personnelles',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
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
                                const SizedBox(height: 24),

                                // Bouton de sauvegarde
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveProfile,
                                    child:
                                        _isSaving
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Text(
                                              'Enregistrer les modifications',
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Formulaire de changement de mot de passe
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Changer le mot de passe',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),

                              // Mot de passe actuel
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Mot de passe actuel',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Nouveau mot de passe
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Nouveau mot de passe',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  helperText:
                                      'Au moins 8 caractères avec lettres, chiffres et symboles',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Confirmation du nouveau mot de passe
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Confirmer le nouveau mot de passe',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bouton de changement de mot de passe
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isChangingPassword
                                          ? null
                                          : _changePassword,
                                  child:
                                      _isChangingPassword
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text(
                                            'Changer le mot de passe',
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
