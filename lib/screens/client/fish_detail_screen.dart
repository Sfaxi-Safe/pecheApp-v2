import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_avis.dart';
import 'package:peche_app/screens/client/order_screen.dart';
import 'package:peche_app/screens/client/review_screen.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FishDetailScreen extends StatelessWidget {
  final String fishId;

  const FishDetailScreen({super.key, required this.fishId});

  @override
  Widget build(BuildContext context) {
    final fishService = Provider.of<FishService>(context);
    final authService = Provider.of<AuthService>(context);
    final fish = fishService.getFishById(fishId);
    final reviews = fishService.getReviewsForFish(fishId);
    final averageRating = fishService.getAverageRating(fishId);

    if (fish == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du poisson'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Poisson non trouvé')),
      );
    }

    final formattedDate =
        fish.dateDePeche != null
            ? fish.dateDePeche!.substring(0, 10)
            : 'Date inconnue';

    return Scaffold(
      appBar: AppBar(
        title: Text(fish.nom),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du poisson
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.asset(
                'assets/images/fish_placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Informations principales
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fish.nom,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Disponible',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        averageRating > 0
                            ? averageRating.toStringAsFixed(1)
                            : 'Pas encore d\'avis',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${reviews.length} avis)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Détails du poisson
                  const Text(
                    'Détails',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Prix',
                            '${fish.prix} €/kg',
                            Icons.euro,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Stock',
                            '${fish.stock} kg',
                            Icons.inventory,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Lieu de pêche',
                            fish.zoneDePeche ?? 'Non spécifié',
                            Icons.location_on,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            'Date de capture',
                            formattedDate,
                            Icons.calendar_today,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.fish,
                                size: 20,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Méthode de pêche',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              Text(
                                fish.typologie ?? 'Non spécifié',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Prix estimé
                  const Text(
                    'Prix estimé',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppTheme.primaryColor.withAlpha(25),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prix au kilo',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Text(
                            '${(15.90).toStringAsFixed(2)} €/kg',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avis des clients
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Avis des clients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      if (authService.isAuthenticated && authService.isClient)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReviewScreen(
                                      fishId: fish.id.toString(),
                                    ),
                              ),
                            );
                          },
                          child: const Text('Ajouter un avis'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  reviews.isEmpty
                      ? const Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Aucun avis pour le moment',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                      : Column(
                        children:
                            reviews
                                .map((review) => _buildReviewCard(review))
                                .toList(),
                      ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Simuler un numéro de téléphone
                            const phoneNumber = '+33612345678';
                            final url = 'tel:$phoneNumber';

                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Impossible d\'ouvrir l\'application téléphone',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.phone),
                          label: const Text('Contacter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (authService.isAuthenticated &&
                                authService.isClient) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => OrderScreen(
                                        fishId: fish.id.toString(),
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vous devez être connecté en tant que client pour commander',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Commander'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
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

  Widget _buildReviewCard(MarketplaceAvis review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text('U')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Utilisateur',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < review.etoileNb
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            review.etoileNb.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.commentaire,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
