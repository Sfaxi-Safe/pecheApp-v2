import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/firestore_service.dart';
import 'package:seatrace/services/storage_service.dart';
import 'package:seatrace/utils/validators.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

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
  String? _photoUrl;

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

      DocumentSnapshot? userDoc;
      String collection = '';

      if (user.isPecheur()) {
        collection = 'pecheurs';
        _userType = 'Pêcheur';
      } else if (user.isVeterinaire()) {
        collection = 'vitirinaires';
        _userType = 'Vétérinaire';
      } else if (user.isMaryeur()) {
        collection = 'maryeurs';
        _userType = 'Maryeur';
      } else {
        collection = 'users';
        _userType = 'Client';
      }

      userDoc = await _firestore.collection(collection).doc(user.id).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _userData = data;
          _nomController.text = (data['nom'] ?? '').toString();
          _prenomController.text = (data['prenom'] ?? '').toString();
          _telephoneController.text = (data['telephone'] ?? '').toString();
          _photoUrl = data['photo']?.toString();
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
        // Télécharger l'image vers Firebase Storage
        final user = await AuthService().getCurrentUser();
        if (user == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Télécharger l'image
        final photoUrl = await _storageService.uploadProfileImage(
          File(pickedFile.path),
          user.id!,
        );

        // Mettre à jour l'URL de la photo dans Firestore
        String collection = '';
        if (user.isPecheur()) {
          collection = 'pecheurs';
        } else if (user.isVeterinaire()) {
          collection = 'vitirinaires';
        } else if (user.isMaryeur()) {
          collection = 'maryeurs';
        } else {
          collection = 'users';
        }

        await _firestore.collection(collection).doc(user.id).update({
          'photo': photoUrl,
        });

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
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'telephone':
            _telephoneController.text.isEmpty
                ? null
                : int.tryParse(_telephoneController.text),
      };

      String collection = '';
      if (user.isPecheur()) {
        collection = 'pecheurs';
      } else if (user.isVeterinaire()) {
        collection = 'vitirinaires';
      } else if (user.isMaryeur()) {
        collection = 'maryeurs';
      } else {
        collection = 'users';
      }

      await _firestore.collection(collection).doc(user.id).update(updatedData);

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
      // Réauthentifier l'utilisateur avec son mot de passe actuel
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Mettre à jour le mot de passe
      await user.updatePassword(_newPasswordController.text);

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
                                      ).primaryColor.withOpacity(0.1),
                                      backgroundImage:
                                          _photoUrl != null
                                              ? NetworkImage(_photoUrl!)
                                              : null,
                                      child:
                                          _photoUrl == null
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
                                  ).primaryColor.withOpacity(0.1),
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

                      // Messages d'erreur ou de succès
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.error,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_successMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
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

                      // Formulaire de profil
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nomController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nom',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre nom';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _prenomController,
                                  decoration: const InputDecoration(
                                    labelText: 'Prénom',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre prénom';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _telephoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Téléphone',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.phone),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: Validators.validatePhone,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSaving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child:
                                        _isSaving
                                            ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text(
                                              'Enregistrer les modifications',
                                              style: TextStyle(fontSize: 16),
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _currentPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Mot de passe actuel',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _newPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Nouveau mot de passe',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Confirmer le nouveau mot de passe',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isChangingPassword
                                          ? null
                                          : _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child:
                                      _isChangingPassword
                                          ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            'Changer le mot de passe',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton de déconnexion
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Déconnexion'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
      ),
    );
  }
}
