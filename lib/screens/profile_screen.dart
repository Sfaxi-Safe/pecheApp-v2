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
import 'package:path/path.dart' as path;

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

      // Log pour déboguer
      debugPrint(
        'Utilisateur récupéré: id=${user.id}, nom=${user.nom}, prenom=${user.prenom}, telephone=${user.telephone}',
      );

      // Déterminer le type d'utilisateur et récupérer les détails
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

      // Log pour déboguer
      debugPrint('Détails utilisateur: ${userData.toString()}');

      // Créer un objet utilisateur complet en combinant les données de base et les détails
      final Map<String, dynamic> completeUserData = {
        'id': user.id,
        'nom': user.nom,
        'prenom': user.prenom,
        'telephone': user.telephone,
        'photo': user.photo,
        'email': user.email,
      };

      // Ajouter les détails supplémentaires s'ils existent
      if (userData != null) {
        // Mettre à jour les informations de base si elles sont disponibles dans les détails
        if (userData['nom'] != null && userData['nom'].toString().isNotEmpty) {
          completeUserData['nom'] = userData['nom'];
        }
        if (userData['prenom'] != null &&
            userData['prenom'].toString().isNotEmpty) {
          completeUserData['prenom'] = userData['prenom'];
        }
        if (userData['telephone'] != null &&
            userData['telephone'].toString().isNotEmpty) {
          completeUserData['telephone'] = userData['telephone'];
        }
        if (userData['photo'] != null &&
            userData['photo'].toString().isNotEmpty) {
          completeUserData['photo'] = userData['photo'];
        }
        if (userData['email'] != null &&
            userData['email'].toString().isNotEmpty) {
          completeUserData['email'] = userData['email'];
        }

        // Ajouter les champs spécifiques au type d'utilisateur
        if (user.isPecheur()) {
          completeUserData['matricule'] = userData['matricule'];
          completeUserData['bateau'] = userData['bateau'];
          completeUserData['port'] = userData['port'];
          completeUserData['cin'] = userData['cin'];
        } else if (user.isMaryeur()) {
          completeUserData['societe'] = userData['societe'];
          completeUserData['registre'] = userData['registre'];
          completeUserData['adresse'] = userData['adresse'];
        } else if (user.isVeterinaire()) {
          completeUserData['specialite'] = userData['specialite'];
          completeUserData['licence'] = userData['licence'];
          completeUserData['adresse'] = userData['adresse'];
        } else if (user.isClient()) {
          completeUserData['adresse'] = userData['adresse'];
        }
      }

      debugPrint('Données utilisateur complètes: $completeUserData');

      setState(() {
        _userData = completeUserData;
        _nomController.text = completeUserData['nom'] ?? '';
        _prenomController.text = completeUserData['prenom'] ?? '';
        _telephoneController.text =
            completeUserData['telephone']?.toString() ?? '';
        _photoPath = completeUserData['photo']?.toString();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');

      // Essayer de récupérer les données de base de l'utilisateur
      try {
        final user = await AuthService().getCurrentUser();
        if (user != null) {
          setState(() {
            _userData = {
              'id': user.id,
              'nom': user.nom,
              'prenom': user.prenom,
              'telephone': user.telephone,
              'photo': user.photo,
              'email': user.email,
            };

            _nomController.text = user.nom;
            _prenomController.text = user.prenom;
            _telephoneController.text = user.telephone ?? '';
            _photoPath = user.photo;
            _isLoading = false;
          });
          return;
        }
      } catch (secondError) {
        debugPrint('Erreur secondaire: $secondError');
      }

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
        _errorMessage = null;
        _successMessage = null;
      });

      // Sélectionner l'image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        requestFullMetadata:
            false, // Réduire les métadonnées pour alléger le fichier
      );

      if (pickedFile == null) {
        // L'utilisateur a annulé la sélection
        debugPrint('Sélection d\'image annulée par l\'utilisateur');
        setState(() {
          _isUploadingPhoto = false;
        });
        return;
      }

      // Vérifier l'extension du fichier
      final ext = path.extension(pickedFile.path).toLowerCase();
      final validExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.heic',
      ];
      if (!validExtensions.contains(ext)) {
        debugPrint('Extension de fichier non supportée: $ext');
        setState(() {
          _errorMessage =
              'Format d\'image non supporté. Utilisez JPG, PNG, GIF ou WebP.';
          _isUploadingPhoto = false;
        });
        return;
      }

      // Vérifier si l'utilisateur est connecté
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Préparer le fichier image
      final imageFile = File(pickedFile.path);
      debugPrint('Image sélectionnée: ${imageFile.path}');

      // Vérifier la taille du fichier
      final fileSize = await imageFile.length();
      debugPrint('Taille de l\'image: ${fileSize / 1024} KB');

      // Télécharger l'image sur le serveur avec gestion des erreurs
      debugPrint('Début du téléchargement de l\'image...');

      // Afficher un message de progression
      setState(() {
        _successMessage = 'Téléchargement en cours...';
      });

      final imageUrl = await ImageService.instance.uploadImage(imageFile);

      if (imageUrl == null) {
        throw Exception('Échec du téléchargement de l\'image');
      }

      debugPrint('Image téléchargée avec succès: $imageUrl');

      // Afficher un message de progression
      setState(() {
        _successMessage = 'Mise à jour du profil...';
      });

      // Déterminer l'endpoint en fonction du type d'utilisateur
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

      debugPrint('Mise à jour du profil utilisateur: $endpoint');

      // Mettre à jour le chemin de la photo dans la base de données
      final updatedData = {'id': user.id, 'photo': imageUrl};
      final response = await ApiService.instance.patch(endpoint, updatedData);

      debugPrint('Réponse de mise à jour du profil: $response');

      // Mettre à jour les données de l'utilisateur en session
      final updatedUser = await AuthService().refreshCurrentUser();
      debugPrint('Utilisateur mis à jour: ${updatedUser?.photo}');

      // Rafraîchir les données utilisateur
      await _loadUserData();

      setState(() {
        _successMessage = 'Photo de profil mise à jour avec succès';
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la photo: $e');

      // Message d'erreur plus convivial
      String errorMessage = 'Erreur lors de la mise à jour de la photo';

      if (e.toString().contains('taille')) {
        errorMessage = 'La taille de l\'image est trop grande. Maximum 5 MB.';
      } else if (e.toString().contains('connexion') ||
          e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage =
            'Problème de connexion au serveur. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('format') ||
          e.toString().contains('extension') ||
          e.toString().contains('type')) {
        errorMessage =
            'Format d\'image non supporté. Utilisez JPG, PNG ou GIF.';
      } else if (e.toString().contains('token') ||
          e.toString().contains('authentification') ||
          e.toString().contains('connecté')) {
        errorMessage = 'Vous devez être connecté pour télécharger une image.';
      } else if (e.toString().contains('permission') ||
          e.toString().contains('accès')) {
        errorMessage =
            'Problème de permission. Veuillez autoriser l\'accès à la caméra et aux photos.';
      }

      setState(() {
        _errorMessage = errorMessage;
        _successMessage = null;
      });
    } finally {
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    // Tester la connexion au serveur avant d'afficher le dialogue
    setState(() {
      _isUploadingPhoto = true;
      _errorMessage = null;
      _successMessage = 'Vérification de la connexion...';
    });

    final isConnected = await ImageService.instance.testImageUploadConnection();

    setState(() {
      _isUploadingPhoto = false;
      _successMessage = null;
    });

    if (!isConnected) {
      setState(() {
        _errorMessage =
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      });
      return;
    }

    if (!mounted) return;

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

      // Log pour déboguer
      debugPrint(
        'Sauvegarde du profil: id=${user.id}, nom=${_nomController.text}, prenom=${_prenomController.text}, telephone=${_telephoneController.text}',
      );

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

      debugPrint('Endpoint pour la mise à jour: $endpoint');
      final response = await ApiService.instance.patch(endpoint, updatedData);
      debugPrint('Réponse de la mise à jour: $response');

      // Mettre à jour les données de l'utilisateur en session
      final updatedUser = await AuthService().refreshCurrentUser();
      debugPrint(
        'Utilisateur mis à jour: ${updatedUser?.nom} ${updatedUser?.prenom}',
      );

      // Recharger les données utilisateur pour mettre à jour l'interface
      await _loadUserData();

      setState(() {
        _successMessage = 'Profil mis à jour avec succès';
        _isSaving = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');

      // Message d'erreur plus convivial
      String errorMessage = 'Erreur lors de la mise à jour du profil';

      if (e.toString().contains('connexion') ||
          e.toString().contains('network')) {
        errorMessage =
            'Problème de connexion au serveur. Vérifiez votre connexion internet';
      } else if (e.toString().contains('non trouvé') ||
          e.toString().contains('not found')) {
        errorMessage = 'Utilisateur non trouvé. Veuillez vous reconnecter';
      } else if (e.toString().contains('autorisation') ||
          e.toString().contains('authorization')) {
        errorMessage = 'Vous n\'êtes pas autorisé à effectuer cette action';
      }

      setState(() {
        _errorMessage = errorMessage;
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

    // Vérifier que le nouveau mot de passe est assez long
    if (_newPasswordController.text.length < 6) {
      setState(() {
        _errorMessage =
            'Le nouveau mot de passe doit contenir au moins 6 caractères';
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

      // Log pour déboguer
      debugPrint('Changement de mot de passe pour l\'utilisateur: ${user.id}');

      // Mettre à jour le mot de passe via l'API
      final passwordData = {
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      };

      final response = await ApiService.instance.patch(
        'auth/change-password',
        passwordData,
      );
      debugPrint('Réponse du changement de mot de passe: $response');

      // Effacer les champs
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      setState(() {
        _successMessage = 'Mot de passe mis à jour avec succès';
        _isChangingPassword = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du changement de mot de passe: $e');

      // Message d'erreur plus convivial
      String errorMessage = 'Erreur lors du changement de mot de passe';

      if (e.toString().contains('mot de passe actuel') ||
          e.toString().contains('current password') ||
          e.toString().contains('incorrect')) {
        errorMessage = 'Le mot de passe actuel est incorrect';
      } else if (e.toString().contains('connexion') ||
          e.toString().contains('network')) {
        errorMessage =
            'Problème de connexion au serveur. Vérifiez votre connexion internet';
      } else if (e.toString().contains('non trouvé') ||
          e.toString().contains('not found')) {
        errorMessage = 'Utilisateur non trouvé. Veuillez vous reconnecter';
      }

      setState(() {
        _errorMessage = errorMessage;
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
                            // Nom et prénom
                            if (_userData != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Bienvenue, ${_userData!['prenom']} ${_userData!['nom']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

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
                            const SizedBox(height: 8),

                            // Numéro de téléphone
                            if (_userData != null &&
                                _userData!['telephone'] != null &&
                                _userData!['telephone'].toString().isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _userData!['telephone'].toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
