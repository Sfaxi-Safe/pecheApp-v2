import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/firestore_service.dart';
import 'package:seatrace/services/storage_service.dart';
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
  _FishDetailsScreenState createState() => _FishDetailsScreenState();
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

  @override
  void initState() {
    super.initState();
    _enginController.text = 'Filet'; // Default value
  }

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
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _isGettingLocation = false;
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

      // Create a new prise (catch)
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final firestoreService = FirestoreService();
      final storageService = StorageService();

      // Upload the image to Firebase Storage
      final imageUrl = await storageService.uploadFishImage(widget.imageFile);

      // Create a new prise (catch) in Firestore
      final priseData = {
        'pecheur_id': user.id,
        'nom': 'Prise du ${DateFormat('dd/MM/yyyy').format(now)}',
        'debut': dateFormat.format(now.subtract(const Duration(hours: 2))),
        'fin': dateFormat.format(now),
        'latitude': _latitude,
        'longitude': _longitude,
        'engin': _enginController.text,
        'zone': _zoneController.text,
        'datedebarquement': dateFormat.format(now),
        'createdAt': now.toIso8601String(),
      };

      final priseId = await firestoreService.addPrise(priseData);

      // Create a new lot in Firestore
      final lotData = {
        'identifiant': 'LOT-${now.millisecondsSinceEpoch}',
        'photo': imageUrl,
        'quantite': _quantiteController.text,
        'poid': _poidController.text,
        'espece': widget.espece.nom,
        'temperature': _temperatureController.text,
        'datetest': dateFormat.format(now),
        'test': false, // Not tested yet
        'status': false, // Not approved yet
        'vendre': false, // Not sold yet
        'prise_id': priseId,
        'pecheur_id': user.id,
        'datesoumettre': dateFormat.format(now),
        'is_produit': true,
        'createdAt': now.toIso8601String(),
      };

      await firestoreService.addLot(
        lotData,
        null,
      ); // null because we already uploaded the image

      if (!mounted) return;

      // Show success message and navigate back to dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Poisson enregistré avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'enregistrement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du poisson')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fish identification result
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Espèce identifiée',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              widget.imageFile,
                              width: 100,
                              height: 100,
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Identification réussie avec notre système d\'IA',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fish details form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations complémentaires',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // Quantity
                        TextFormField(
                          controller: _quantiteController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantité (nombre)',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la quantité';
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
                            prefixIcon: Icon(Icons.scale),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le poids';
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
                            prefixIcon: Icon(Icons.thermostat),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la température';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Fishing method
                        TextFormField(
                          controller: _enginController,
                          decoration: const InputDecoration(
                            labelText: 'Méthode de pêche',
                            prefixIcon: Icon(Icons.sailing),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la méthode de pêche';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Fishing zone
                        TextFormField(
                          controller: _zoneController,
                          decoration: const InputDecoration(
                            labelText: 'Zone de pêche',
                            prefixIcon: Icon(Icons.map),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la zone de pêche';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Location
                        Text(
                          'Localisation',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (_latitude != null && _longitude != null) ...[
                          Text(
                            'Latitude: $_latitude',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Longitude: $_longitude',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ] else
                          Text(
                            'Aucune localisation enregistrée',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              _isGettingLocation ? null : _getCurrentLocation,
                          icon: const Icon(Icons.location_on),
                          label:
                              _isGettingLocation
                                  ? const Text('Récupération...')
                                  : const Text('Obtenir ma position actuelle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveFishData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isLoading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Enregistrement...'),
                          ],
                        )
                        : const Text('Enregistrer et soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
