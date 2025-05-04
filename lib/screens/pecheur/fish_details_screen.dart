import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/image_service.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/utils/color_extensions.dart';
import 'package:seatrace/widgets/sea_widgets.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class FishDetailsScreen extends StatefulWidget {
  final File imageFile;
  final Espece espece;

  const FishDetailsScreen({
    Key? key,
    required this.imageFile,
    required this.espece,
  }) : super(key: key);

  @override
  State<FishDetailsScreen> createState() => _FishDetailsScreenState();
}

class _FishDetailsScreenState extends State<FishDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantiteController = TextEditingController();
  final _poidController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _enginController = TextEditingController();
  final _zoneController = TextEditingController();

  String? _latitude;
  String? _longitude;
  bool _isLoading = false;
  bool _isGettingLocation = false;
  String? _errorMessage;
  String? _successMessage;

  // Liste des mareyeurs disponibles
  List<Map<String, dynamic>> _maryeurs = [];
  // Mareyeur sélectionné
  Map<String, dynamic>? _selectedMaryeur;

  final _animationService = AnimationService();
  final _responsiveService = ResponsiveService();
  final _navigationService = NavigationService();

  final List<String> _methodesDepeche = [
    'Filet',
    'Ligne',
    'Chalut',
    'Casier',
    'Palangre',
    'Autre',
  ];

  final List<String> _zonesDepeche = [
    'Méditerranée Nord',
    'Méditerranée Sud',
    'Atlantique Nord',
    'Atlantique Sud',
    'Manche',
    'Mer du Nord',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _enginController.text = 'Filet'; // Default value
    _zoneController.text = 'Méditerranée Nord'; // Default value
    _temperatureController.text = '4'; // Default value

    // Charger la liste des mareyeurs
    _loadMaryeurs();
  }

  // Charger la liste des mareyeurs disponibles
  Future<void> _loadMaryeurs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Chargement des mareyeurs...');

      // Vérifier si l'utilisateur est connecté
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      debugPrint('Utilisateur connecté: ${user.prenom} ${user.nom}');

      // Récupérer les mareyeurs
      final maryeurs = await ApiService.instance.getAllMaryeurs();

      debugPrint('Nombre de mareyeurs récupérés: ${maryeurs.length}');

      // Afficher les détails de chaque mareyeur pour le débogage
      for (var i = 0; i < maryeurs.length; i++) {
        final maryeur = maryeurs[i];
        debugPrint(
          'Mareyeur $i: ${maryeur['prenom']} ${maryeur['nom']} (ID: ${maryeur['_id'] ?? maryeur['id']})',
        );
      }

      if (mounted) {
        setState(() {
          _maryeurs = maryeurs;
          _isLoading = false;

          // Sélectionner le premier mareyeur par défaut s'il y en a
          if (maryeurs.isNotEmpty) {
            _selectedMaryeur = maryeurs[0];
            debugPrint(
              'Mareyeur sélectionné par défaut: ${_selectedMaryeur!['prenom']} ${_selectedMaryeur!['nom']}',
            );
          } else {
            debugPrint('Aucun mareyeur disponible dans la base de données');
            _selectedMaryeur = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _maryeurs = [];
          _selectedMaryeur = null;

          // Message d'erreur plus convivial
          if (e.toString().contains('network') ||
              e.toString().contains('connexion')) {
            _errorMessage =
                'Problème de connexion au serveur. Vérifiez votre connexion internet et réessayez.';
          } else {
            _errorMessage =
                'Aucun mareyeur disponible. Veuillez demander à des mareyeurs de créer un compte dans l\'application.';
          }
        });
      }
      debugPrint('Erreur lors du chargement des mareyeurs: $e');
    }
  }

  // La méthode _loadMaryeurDirectement a été supprimée car elle n'est plus nécessaire

  @override
  void dispose() {
    _quantiteController.dispose();
    _poidController.dispose();
    _temperatureController.dispose();
    _enginController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _errorMessage = null;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Les permissions de localisation sont refusées');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Les permissions de localisation sont définitivement refusées',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _isGettingLocation = false;
        _successMessage = 'Position récupérée avec succès';
      });

      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de localisation: ${e.toString()}';
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _saveFishData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isPecheur()) {
        throw Exception('Utilisateur non autorisé');
      }

      // Vérifier si un mareyeur est sélectionné
      if (_selectedMaryeur == null) {
        throw Exception(
          'Veuillez sélectionner un mareyeur pour enregistrer votre prise.',
        );
      }

      // Récupérer l'ID du mareyeur sélectionné
      final maryeurId = _selectedMaryeur!['_id'] ?? _selectedMaryeur!['id'];

      if (maryeurId == null) {
        throw Exception(
          'ID du mareyeur invalide. Veuillez sélectionner un autre mareyeur.',
        );
      }

      debugPrint(
        'Enregistrement de la prise pour le mareyeur: ${_selectedMaryeur!['prenom']} ${_selectedMaryeur!['nom']} (ID: $maryeurId)',
      );

      // Create a new prise (catch)
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

      // Créer une nouvelle prise via l'API
      final priseResponse = await ApiService.instance.post('prises', {
        'pecheur': user.id,
        'maryeur': maryeurId,
        'nom': 'Prise du ${DateFormat('dd/MM/yyyy').format(now)}',
        'debut': dateFormat.format(now.subtract(const Duration(hours: 2))),
        'fin': dateFormat.format(now),
        'latitude': _latitude,
        'longitude': _longitude,
        'engin': _enginController.text,
        'zone': _zoneController.text,
        'affectationDate': dateFormat.format(now),
        'dateDebarquement': dateFormat.format(now),
      });

      // Récupérer l'ID de la prise créée
      final priseId = priseResponse['data']['_id'];

      // Télécharger l'image sur le serveur
      String? imageUrl = await ImageService.instance.uploadImage(
        widget.imageFile,
      );

      if (imageUrl == null) {
        throw Exception('Échec du téléchargement de l\'image');
      }

      // Créer un nouveau lot via l'API
      await ApiService.instance.post('lots', {
        'identifiant': 'LOT-${now.millisecondsSinceEpoch}',
        'photo': imageUrl,
        'quantite': int.parse(_quantiteController.text),
        'poids': double.parse(_poidController.text),
        'espece': widget.espece.nom,
        'temperature': double.parse(_temperatureController.text),
        'dateTest': dateFormat.format(now),
        'test': false, // Pas encore testé
        'status': false, // Pas encore approuvé
        'vendu': false, // Pas encore vendu
        'prise': priseId,
        'user': user.id,
        'dateSoumission': dateFormat.format(now),
        'isProduit': true,
      });

      if (!mounted) return;

      // Show success message and navigate back to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Poisson enregistré avec succès!'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement: $e');

      // Formater le message d'erreur pour qu'il soit plus convivial
      String errorMessage = 'Erreur lors de l\'enregistrement';

      if (e.toString().contains('Pêcheur, mareyeur et nom sont requis')) {
        errorMessage = 'Veuillez remplir tous les champs obligatoires';
      } else if (e.toString().contains('mareyeur')) {
        errorMessage =
            'Erreur avec le mareyeur. Veuillez réessayer ou contacter l\'administrateur';
      } else if (e.toString().contains('connexion') ||
          e.toString().contains('network')) {
        errorMessage =
            'Problème de connexion au serveur. Vérifiez votre connexion internet';
      } else if (e.toString().contains('Aucun mareyeur disponible')) {
        errorMessage =
            'Aucun mareyeur disponible. Veuillez contacter l\'administrateur';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Détails du poisson'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _responsiveService.adaptivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _animationService.staggeredList([
              // Fish identification result
              SeaCard(
                elevated: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Espèce identifiée avec succès',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.imageFile,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.espece.nom,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nom scientifique: ${widget.espece.nomScientifique}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Identification réussie avec notre système d\'IA',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Fish details form
              SeaSectionHeader(
                title: 'Informations complémentaires',
                icon: Icons.edit_note,
                subtitle:
                    'Veuillez compléter les informations sur votre capture',
              ),

              SeaCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity
                      TextFormField(
                        controller: _quantiteController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantité (nombre)',
                          hintText: 'Entrez le nombre de poissons',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la quantité';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weight
                      TextFormField(
                        controller: _poidController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Poids (kg)',
                          hintText: 'Entrez le poids total en kg',
                          prefixIcon: Icon(Icons.scale),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le poids';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Temperature
                      TextFormField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Température (°C)',
                          hintText: 'Entrez la température de conservation',
                          prefixIcon: Icon(Icons.thermostat),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer la température';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fishing method
                      DropdownButtonFormField<String>(
                        value: _enginController.text,
                        decoration: const InputDecoration(
                          labelText: 'Méthode de pêche',
                          prefixIcon: Icon(Icons.sailing),
                        ),
                        items:
                            _methodesDepeche.map((String method) {
                              return DropdownMenuItem<String>(
                                value: method,
                                child: Text(method),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _enginController.text = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une méthode de pêche';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Fishing zone
                      DropdownButtonFormField<String>(
                        value: _zoneController.text,
                        decoration: const InputDecoration(
                          labelText: 'Zone de pêche',
                          prefixIcon: Icon(Icons.map),
                        ),
                        items:
                            _zonesDepeche.map((String zone) {
                              return DropdownMenuItem<String>(
                                value: zone,
                                child: Text(zone),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _zoneController.text = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner une zone de pêche';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Sélection du mareyeur
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mareyeur destinataire',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sélectionnez un mareyeur à qui envoyer votre prise',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),

                          // Affichage conditionnel selon l'état du chargement
                          if (_isLoading && _maryeurs.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chargement des mareyeurs...',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            )
                          else if (_maryeurs.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Aucun mareyeur disponible dans la base de données',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: theme.colorScheme.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Veuillez demander à des mareyeurs de créer un compte dans l\'application pour pouvoir leur envoyer vos prises.',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  CustomButton.outline(
                                    text: 'Actualiser la liste',
                                    icon: Icons.refresh,
                                    onPressed: _loadMaryeurs,
                                    color: theme.primaryColor,
                                  ),
                                ],
                              ),
                            )
                          else
                            DropdownButtonFormField<Map<String, dynamic>>(
                              value: _selectedMaryeur,
                              decoration: const InputDecoration(
                                labelText: 'Sélectionnez un mareyeur',
                                prefixIcon: Icon(Icons.business),
                                hintText: 'Choisir un mareyeur',
                              ),
                              items:
                                  _maryeurs.map((maryeur) {
                                    final nom = maryeur['nom'] ?? '';
                                    final prenom = maryeur['prenom'] ?? '';
                                    final nomComplet = '$prenom $nom';

                                    return DropdownMenuItem<
                                      Map<String, dynamic>
                                    >(value: maryeur, child: Text(nomComplet));
                                  }).toList(),
                              onChanged: (Map<String, dynamic>? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedMaryeur = newValue;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un mareyeur';
                                }
                                return null;
                              },
                              isExpanded: true,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Mareyeur sélectionné
              if (_selectedMaryeur != null) ...[
                SeaSectionHeader(
                  title: 'Mareyeur sélectionné',
                  icon: Icons.business,
                  subtitle:
                      'Informations sur le mareyeur qui recevra votre prise',
                ),

                SeaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: theme.colorScheme.primary,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedMaryeur!['prenom'] ?? ''} ${_selectedMaryeur!['nom'] ?? ''}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_selectedMaryeur!['matricule'] != null)
                                  Text(
                                    'Matricule: ${_selectedMaryeur!['matricule']}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                if (_selectedMaryeur!['telephone'] != null)
                                  Text(
                                    'Tél: ${_selectedMaryeur!['telephone']}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Location
              SeaSectionHeader(
                title: 'Localisation',
                icon: Icons.location_on,
                subtitle: 'Enregistrez votre position actuelle',
              ),

              SeaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Position enregistrée',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Latitude: $_latitude',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Longitude: $_longitude',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_off,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aucune position enregistrée. Veuillez cliquer sur le bouton ci-dessous pour obtenir votre position actuelle.',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: CustomButton.filled(
                        text:
                            _isGettingLocation
                                ? 'Récupération...'
                                : 'Obtenir ma position actuelle',
                        icon: Icons.my_location,
                        onPressed:
                            _isGettingLocation ? null : _getCurrentLocation,
                        isLoading: _isGettingLocation,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Error or success messages
              if (_errorMessage != null)
                _animationService.shake(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
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
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (_successMessage != null)
                _animationService.fadeIn(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 0.3,
                        ),
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
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Save button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton.filled(
                  text:
                      _isLoading
                          ? 'Enregistrement...'
                          : 'Enregistrer et soumettre',
                  icon: _isLoading ? null : Icons.save,
                  onPressed:
                      (_isLoading || _selectedMaryeur == null)
                          ? null
                          : _saveFishData,
                  isLoading: _isLoading,
                  color: theme.primaryColor,
                  size: CustomButtonSize.large,
                ),
              ),
              if (_selectedMaryeur == null && !_isLoading) ...[
                const SizedBox(height: 8),
                Text(
                  'Vous devez sélectionner un mareyeur pour enregistrer votre prise.',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
    );
  }
}
