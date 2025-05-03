import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seatrace/services/fish_recognition_service.dart';
import 'package:seatrace/screens/pecheur/fish_details_screen.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/widgets/sea_widgets.dart';

class ScanFishScreen extends StatefulWidget {
  const ScanFishScreen({Key? key}) : super(key: key);

  @override
  State<ScanFishScreen> createState() => _ScanFishScreenState();
}

class _ScanFishScreenState extends State<ScanFishScreen> with SingleTickerProviderStateMixin {
  File? _imageFile;
  bool _isAnalyzing = false;
  String? _errorMessage;
  bool _useOnlineApi = true; // Par défaut, utiliser l'API en ligne
  final FishRecognitionService _recognitionService = FishRecognitionService();
  final AnimationService _animationService = AnimationService();
  final ResponsiveService _responsiveService = ResponsiveService();
  final NavigationService _navigationService = NavigationService();
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _recognitionService.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) {
      setState(() {
        _errorMessage = 'Veuillez d\'abord sélectionner une image';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      // Configurer le service de reconnaissance pour utiliser l'API en ligne ou le modèle local
      _recognitionService.setPreferOnlineRecognition(_useOnlineApi);

      // Afficher un message indiquant la méthode utilisée
      final String methodMessage = _useOnlineApi
          ? 'Analyse avec Google Cloud Vision API...'
          : 'Analyse avec le modèle local...';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(methodMessage),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      final espece = await _recognitionService.recognizeFish(_imageFile!);

      if (!mounted) return;

      if (espece != null) {
        _navigationService.navigateToWithSlideUp(
          context,
          FishDetailsScreen(imageFile: _imageFile!, espece: espece),
        );
      } else {
        setState(() {
          _errorMessage = 'Impossible d\'identifier l\'espèce de poisson';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isPhone = _responsiveService.isPhone(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un poisson'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _responsiveService.adaptivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _animationService.staggeredList([
              // Instructions
              SeaCard(
                title: 'Comment scanner un poisson',
                icon: Icons.help_outline,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionStep(
                      context,
                      number: '1',
                      title: 'Prendre une photo',
                      description: 'Prenez une photo claire du poisson ou importez-en une depuis votre galerie.',
                      icon: Icons.camera_alt,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionStep(
                      context,
                      number: '2',
                      title: 'Analyser',
                      description: 'Notre IA identifiera automatiquement l\'espèce de poisson.',
                      icon: Icons.search,
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionStep(
                      context,
                      number: '3',
                      title: 'Ajouter les détails',
                      description: 'Complétez les informations sur votre capture pour l\'enregistrer.',
                      icon: Icons.edit_note,
                    ),
                  ],
                ),
              ),

              // Image preview
              SeaCard(
                title: 'Image du poisson',
                icon: Icons.image,
                actionIcon: _imageFile != null ? Icons.delete : null,
                onActionPressed: _imageFile != null ? () {
                  setState(() {
                    _imageFile = null;
                    _errorMessage = null;
                  });
                } : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 48,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Aucune image sélectionnée',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.textTheme.bodySmall?.color,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Prenez une photo ou importez-en une',
                                          style: theme.textTheme.bodySmall,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _animationService.shake(
                        Container(
                          padding: const EdgeInsets.all(12),
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
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Image source buttons
                    Row(
                      children: [
                        Expanded(
                          child: SeaButton.primary(
                            text: 'Appareil photo',
                            icon: Icons.camera_alt,
                            onPressed: _isAnalyzing ? null : () => _getImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SeaButton.outline(
                            text: 'Galerie',
                            icon: Icons.photo_library,
                            onPressed: _isAnalyzing ? null : () => _getImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // API selection
              SeaCard(
                title: 'Méthode d\'analyse',
                icon: _useOnlineApi ? Icons.cloud : Icons.phone_android,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Utiliser Google Cloud Vision API'),
                      subtitle: Text(
                        _useOnlineApi
                            ? 'Analyse en ligne (plus précise, nécessite une connexion internet)'
                            : 'Analyse locale (fonctionne hors ligne)',
                        style: theme.textTheme.bodySmall,
                      ),
                      value: _useOnlineApi,
                      onChanged: (value) {
                        setState(() {
                          _useOnlineApi = value;
                        });
                      },
                      secondary: Icon(
                        _useOnlineApi ? Icons.cloud : Icons.phone_android,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Note: L\'analyse en ligne offre une meilleure précision mais nécessite une connexion internet. L\'analyse locale fonctionne hors ligne mais peut être moins précise.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Analyze button
              const SizedBox(height: 16),
              SeaButton.primary(
                text: _isAnalyzing ? 'Analyse en cours...' : 'Analyser l\'image',
                icon: _isAnalyzing ? null : Icons.search,
                onPressed: _isAnalyzing || _imageFile == null ? null : _analyzeImage,
                isLoading: _isAnalyzing,
                width: double.infinity,
                size: SeaButtonSize.large,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
