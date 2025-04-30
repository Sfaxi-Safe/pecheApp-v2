import 'package:flutter/material.dart';
import '../utils/error_handler.dart';

/// Widget pour afficher une erreur avec une action de réessai
class ErrorDisplay extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool fullScreen;

  const ErrorDisplay({
    Key? key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.fullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = message ?? 'Une erreur est survenue';
    
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: fullScreen ? 64 : 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          errorMessage,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: fullScreen ? 16 : 14,
          ),
          textAlign: TextAlign.center,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ],
    );
    
    if (fullScreen) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: content,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.5),
        ),
      ),
      child: content,
    );
  }
}

/// Widget pour afficher un message d'erreur dans un formulaire
class FormErrorDisplay extends StatelessWidget {
  final String? message;

  const FormErrorDisplay({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher un message de succès
class SuccessDisplay extends StatelessWidget {
  final String message;
  final IconData icon;

  const SuccessDisplay({
    Key? key,
    required this.message,
    this.icon = Icons.check_circle_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.green.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
