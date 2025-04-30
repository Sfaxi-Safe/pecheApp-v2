import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: Colors.grey[300],
                color: _getColorForStrength(strength),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getLabelForStrength(strength),
              style: TextStyle(
                color: _getColorForStrength(strength),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getColorForStrength(double strength) {
    if (strength < 0.2) return Colors.red;
    if (strength < 0.4) return Colors.orange;
    if (strength < 0.6) return Colors.yellow;
    if (strength < 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String _getLabelForStrength(double strength) {
    if (strength < 0.2) return 'Très faible';
    if (strength < 0.4) return 'Faible';
    if (strength < 0.6) return 'Moyen';
    if (strength < 0.8) return 'Fort';
    return 'Très fort';
  }
}
