import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/models/fish_classification_result.dart';
import 'package:seatrace/services/fish_recognition_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/fish_classification_result_widget.dart';
import 'package:seatrace/widgets/optimized_image.dart';

/// Écran pour la classification des poissons
class FishClassificationScreen extends StatefulWidget {
  /// Callback appelé lorsque l'utilisateur sélectionne une espèce
  final Function(Espece espece)? onEspeceSelected;
  
  /// Indique si l'écran doit retourner l'espèce sélectionnée
  final bool returnResult;

  const FishClassificationScreen({
    Key? key,
    this.onEspeceSelected,
    this.returnResult = true,
  }) : super(key: key);

  @override
  State<FishClassificationScreen> createState() => _FishClassificationScreenState();
}

class _FishClassificationScreenState extends State<FishClassificationScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  FishClassificationResult? _classificationResult;
  Espece? _selectedEspece;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classification de poisson'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Construit le corps de l'écran
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image du poisson
          _buildImageSection(),
          
          // Résultat de la classification
          if (_isProcessing) ...[
            const SizedBox(height: 32),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Classification en cours...'),
                ],
              ),
            ),
          ] else if (_errorMessage != null) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _captureImage,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ] else if (_classificationResult != null) ...[
            const SizedBox(height: 16),
            FishClassificationResultWidget(
              result: _classificationResult!,
              imageUrl: _imageFile?.path,
              onConfirm: _confirmEspece,
              onSelectAlternative: _selectAlternative,
              showConfirmButton: widget.returnResult,
            ),
          ],
        ],
      ),
    );
  }

  /// Construit la section d'image
  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Image du poisson',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OptimizedImage(
                  imageUrl: _imageFile!.path,
                  height: 300,
                  fit: BoxFit.cover,
                  isFile: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Nouvelle photo'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerie'),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Prendre une photo'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choisir une image'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construit la barre inférieure
  Widget? _buildBottomBar() {
    if (_selectedEspece != null && widget.returnResult) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              if (widget.onEspeceSelected != null) {
                widget.onEspeceSelected!(_selectedEspece!);
              }
              Navigator.of(context).pop(_selectedEspece);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Utiliser cette espèce'),
          ),
        ),
      );
    }
    return null;
  }

  /// Capture une image avec la caméra
  Future<void> _captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _classificationResult = null;
          _selectedEspece = null;
          _errorMessage = null;
        });
        
        _classifyImage();
      }
    } catch (e) {
      ErrorHandler.instance.handleAndShowError(
        context,
        e,
        errorContext: 'Capture d\'image',
        showDialog: true,
      );
    }
  }

  /// Sélectionne une image depuis la galerie
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _classificationResult = null;
          _selectedEspece = null;
          _errorMessage = null;
        });
        
        _classifyImage();
      }
    } catch (e) {
      ErrorHandler.instance.handleAndShowError(
        context,
        e,
        errorContext: 'Sélection d\'image',
        showDialog: true,
      );
    }
  }

  /// Classifie l'image sélectionnée
  Future<void> _classifyImage() async {
    if (_imageFile == null) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    try {
      // Classifier l'image
      final result = await FishRecognitionService().classifyFish(_imageFile!);
      
      if (result == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Impossible de classifier cette image. Veuillez réessayer avec une autre image.';
        });
        return;
      }
      
      // Récupérer l'espèce correspondante
      final espece = await FishRecognitionService().recognizeFish(_imageFile!);
      
      setState(() {
        _classificationResult = result;
        _selectedEspece = espece;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Une erreur est survenue lors de la classification: ${e.toString()}';
      });
      
      ErrorHandler.instance.logError(
        e,
        context: 'Classification d\'image',
      );
    }
  }

  /// Confirme l'espèce sélectionnée
  void _confirmEspece(String espece) {
    if (_selectedEspece != null) {
      if (widget.onEspeceSelected != null) {
        widget.onEspeceSelected!(_selectedEspece!);
      }
      if (widget.returnResult) {
        Navigator.of(context).pop(_selectedEspece);
      }
    }
  }

  /// Sélectionne une alternative
  void _selectAlternative(FishClassificationResult alternative) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Mettre à jour le résultat de classification
      setState(() {
        _classificationResult = alternative;
      });
      
      // Récupérer l'espèce correspondante
      final espece = await FishRecognitionService().recognizeFish(_imageFile!);
      
      setState(() {
        _selectedEspece = espece;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Une erreur est survenue lors de la sélection de l\'alternative: ${e.toString()}';
      });
      
      ErrorHandler.instance.logError(
        e,
        context: 'Sélection d\'alternative',
      );
    }
  }

  /// Affiche les paramètres de classification
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres de classification'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Préférer l\'API en ligne'),
                  subtitle: const Text('Utiliser Google Vision API si disponible'),
                  value: FishRecognitionService()._preferOnlineRecognition,
                  onChanged: (value) {
                    setState(() {
                      FishRecognitionService().setPreferOnlineRecognition(value);
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
