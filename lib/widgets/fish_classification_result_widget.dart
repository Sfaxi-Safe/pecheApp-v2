import 'package:flutter/material.dart';
import 'package:seatrace/models/fish_classification_result.dart';
import 'package:seatrace/widgets/optimized_image.dart';

/// Widget pour afficher les résultats de classification d'un poisson
class FishClassificationResultWidget extends StatelessWidget {
  /// Résultat de la classification
  final FishClassificationResult result;
  
  /// URL de l'image du poisson
  final String? imageUrl;
  
  /// Callback appelé lorsque l'utilisateur confirme l'espèce
  final Function(String espece)? onConfirm;
  
  /// Callback appelé lorsque l'utilisateur sélectionne une alternative
  final Function(FishClassificationResult alternative)? onSelectAlternative;
  
  /// Indique si le widget doit afficher les alternatives
  final bool showAlternatives;
  
  /// Indique si le widget doit afficher un bouton de confirmation
  final bool showConfirmButton;

  const FishClassificationResultWidget({
    Key? key,
    required this.result,
    this.imageUrl,
    this.onConfirm,
    this.onSelectAlternative,
    this.showAlternatives = true,
    this.showConfirmButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            Text(
              'Espèce identifiée',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Image du poisson
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: OptimizedImage(
                  imageUrl: imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Résultat principal
            _buildMainResult(context),
            
            // Alternatives
            if (showAlternatives && result.alternatives != null && result.alternatives!.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                'Autres possibilités',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...result.alternatives!.map((alternative) => _buildAlternativeResult(context, alternative)),
            ],
            
            // Bouton de confirmation
            if (showConfirmButton && onConfirm != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => onConfirm!(result.espece),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmer cette espèce'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Construit le widget pour afficher le résultat principal
  Widget _buildMainResult(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.espece,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(result.confiance),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(result.confiance * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Source: ${result.source}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le widget pour afficher une alternative
  Widget _buildAlternativeResult(BuildContext context, FishClassificationResult alternative) {
    return InkWell(
      onTap: onSelectAlternative != null ? () => onSelectAlternative!(alternative) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                alternative.espece,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getConfidenceColor(alternative.confiance),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${(alternative.confiance * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (onSelectAlternative != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Retourne une couleur en fonction du niveau de confiance
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else if (confidence >= 0.4) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}
