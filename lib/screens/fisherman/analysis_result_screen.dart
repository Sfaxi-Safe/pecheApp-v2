import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_produit.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalysisResultScreen extends StatefulWidget {
  final File imageFile;
  final String species;

  const AnalysisResultScreen({
    super.key,
    required this.imageFile,
    required this.species,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de formulaire
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController(text: '15.90');
  final _stockController = TextEditingController(text: '1.0');
  
  String _selectedFishingMethod = 'Canne à pêche';
  final List<String> _fishingMethods = [
    'Canne à pêche',
    'Filet',
    'Ligne de traîne',
    'Palangre',
    'Autre'
  ];
  
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final fishService = Provider.of<FishService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat de l\'analyse'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image et espèce identifiée
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.file(
                        widget.imageFile,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Espèce identifiée:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.species,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informations générales sur l'espèce
              const Text(
                'Informations sur cette espèce',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Taille moyenne',
                        '40-65 cm',
                        Icons.straighten,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Habitat',
                        'Eaux côtières, estuaires',
                        Icons.water,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Réglementation',
                        'Taille min: 36 cm',
                        Icons.gavel,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Formulaire pour ajouter des détails
              const Text(
                'Ajouter des détails sur votre capture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Champ de poids
                        TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Poids (kg)',
                            prefixIcon: Icon(Icons.monitor_weight),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le poids';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Champ de taille
                        TextFormField(
                          controller: _lengthController,
                          decoration: const InputDecoration(
                            labelText: 'Taille (cm)',
                            prefixIcon: Icon(Icons.straighten),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la taille';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Champ de prix
                        TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Prix (€/kg)',
                            prefixIcon: Icon(Icons.euro),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le prix';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Champ de stock
                        TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock disponible (kg)',
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le stock disponible';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Champ de localisation
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Localisation',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la localisation';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Méthode de pêche (dropdown)
                        DropdownButtonFormField<String>(
                          value: _selectedFishingMethod,
                          decoration: InputDecoration(
                            labelText: 'Méthode de pêche',
                            prefixIcon: FaIcon(FontAwesomeIcons.fish),
                          ),
                          items: _fishingMethods.map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFishingMethod = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bouton d'enregistrement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : () => _submitForm(context, authService, fishService),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSubmitting
                        ? 'Enregistrement...'
                        : 'Enregistrer et partager',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    AuthService authService,
    FishService fishService
  ) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Récupérer l'ID du pêcheur connecté
        final userId = authService.currentUser?.id;
        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        // Créer un nouveau produit
        final newFish = MarketplaceProduit.create(
          nom: widget.species,
          description: 'Poisson frais pêché à ${_locationController.text}',
          prix: double.tryParse(_priceController.text) ?? 15.90,
          stock: double.tryParse(_stockController.text) ?? 1.0,
          dateDePeche: DateTime.now().toIso8601String(),
          zoneDePeche: _locationController.text,
          typologie: _selectedFishingMethod,
          userId: userId,
        );

        // Enregistrer le poisson dans la base de données
        final success = await fishService.addFish(newFish);

        if (!mounted) return;

        if (success) {
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Capture enregistrée avec succès!'),
              backgroundColor: Colors.green,
            ),
          );

          // Retourner à l'écran principal
          Navigator.popUntil(
            context,
            ModalRoute.withName('/fisherman/dashboard'),
          );
        } else {
          throw Exception('Erreur lors de l\'enregistrement du poisson');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
