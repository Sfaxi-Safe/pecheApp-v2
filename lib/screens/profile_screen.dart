import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/image_service.dart';
import 'package:seatrace/utils/validators.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:seatrace/widgets/sea_widgets.dart';
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

  final _animationService = AnimationService();
  final _responsiveService = ResponsiveService();

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
        userData = await ApiService.instance.getPecheurDetails(user.id);
        _userType = 'Pêcheur';
      } else if (user.isVeterinaire()) {
        userData = await ApiService.instance.getVeterinaireDetails(user.id);
        _userType = 'Vétérinaire';
      } else if (user.isMaryeur()) {
        userData = await ApiService.instance.getMaryeurDetails(user.id);
        _userType = 'Maryeur';
      } else if (user.roles.contains('ROLE_ADMIN')) {
        userData = await ApiService.instance.getAdminById(user.id);
        _userType = 'Administrateur';
      } else {
        userData = await ApiService.instance.getClientDetails(user.id);
        _userType = 'Client';
      }

      // Utiliser une variable locale pour éviter les problèmes de null-safety
      final Map<String, dynamic> data = userData!;

      setState(() {
        _userData = data;

        // Accéder aux propriétés de manière sécurisée
        _nomController.text = (data['nom'] ?? '').toString();
        _prenomController.text = (data['prenom'] ?? '').toString();
        _telephoneController.text = (data['telephone'] ?? '').toString();
        _photoPath = data['photo']?.toString();
        _isLoading = false;
      });
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
        await ApiService.instance.patch(endpoint, updatedData);

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
                SeaListItem(
                  title: 'Appareil photo',
                  icon: Icons.camera_alt,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                  margin: const EdgeInsets.only(bottom: 8),
                ),
                SeaListItem(
                  title: 'Galerie',
                  icon: Icons.photo_library,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            actions: [
              SeaButton.text(
                text: 'Annuler',
                onPressed: () => Navigator.of(context).pop(),
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
        'telephone': _telephoneController.text.trim(),
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

      await ApiService.instance.patch(endpoint, updatedData);

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

      await ApiService.instance.patch('auth/change-password', passwordData);

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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

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
                ? _animationService.fadeIn(
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SeaButton.primary(
                          text: 'Réessayer',
                          icon: Icons.refresh,
                          onPressed: _loadUserData,
                        ),
                      ],
                    ),
                  ),
                )
                : SingleChildScrollView(
                  padding: _responsiveService.adaptivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _animationService.staggeredList([
                      // En-tête du profil avec photo
                      SeaCard(
                        elevated: true,
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
                                  child: SeaAvatar(
                                    imageUrl:
                                        _photoPath != null &&
                                                _photoPath!.isNotEmpty
                                            ? ImageService.instance.getImageUrl(
                                              _photoPath!,
                                            )
                                            : null,
                                    initials: _getInitials(),
                                    size: 120,
                                    backgroundColor: primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    foregroundColor: primaryColor,
                                    bordered: true,
                                    borderColor: primaryColor,
                                    isLoading: _isUploadingPhoto,
                                  ),
                                ),
                                if (!_isUploadingPhoto)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
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
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData!['email'],
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _userType,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Informations personnelles
                      SeaSectionHeader(
                        title: 'Informations personnelles',
                        icon: Icons.person,
                      ),

                      SeaCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _nomController,
                                decoration: const InputDecoration(
                                  labelText: 'Nom',
                                  hintText: 'Entrez votre nom',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: Validators.validateRequired,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _prenomController,
                                decoration: const InputDecoration(
                                  labelText: 'Prénom',
                                  hintText: 'Entrez votre prénom',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: Validators.validateRequired,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _telephoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Téléphone',
                                  hintText: 'Entrez votre numéro de téléphone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 24),

                              // Messages d'erreur ou de succès
                              if (_errorMessage != null && _userData != null)
                                _animationService.shake(
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.error
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              if (_successMessage != null)
                                _animationService.fadeIn(
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.secondary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: theme.colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _successMessage!,
                                            style: TextStyle(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              if (_errorMessage != null ||
                                  _successMessage != null)
                                const SizedBox(height: 24),

                              // Bouton d'enregistrement
                              SeaButton.primary(
                                text: 'Enregistrer les modifications',
                                icon: Icons.save,
                                onPressed: _isSaving ? null : _saveProfile,
                                isLoading: _isSaving,
                                width: double.infinity,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sécurité
                      SeaSectionHeader(
                        title: 'Sécurité',
                        icon: Icons.security,
                        subtitle:
                            'Modifiez votre mot de passe pour sécuriser votre compte',
                      ),

                      SeaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _currentPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe actuel',
                                hintText: 'Entrez votre mot de passe actuel',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Nouveau mot de passe',
                                hintText: 'Entrez votre nouveau mot de passe',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Confirmer le mot de passe',
                                hintText:
                                    'Confirmez votre nouveau mot de passe',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Bouton de changement de mot de passe
                            SeaButton.primary(
                              text: 'Changer le mot de passe',
                              icon: Icons.lock,
                              onPressed:
                                  _isChangingPassword ? null : _changePassword,
                              isLoading: _isChangingPassword,
                              width: double.infinity,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),

                      // Bouton de déconnexion
                      const SizedBox(height: 16),
                      SeaButton.outline(
                        text: 'Déconnexion',
                        icon: Icons.logout,
                        onPressed: _logout,
                        width: double.infinity,
                        color: theme.colorScheme.error,
                      ),
                    ]),
                  ),
                ),
      ),
    );
  }
}
