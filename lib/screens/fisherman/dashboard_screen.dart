import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_produit.dart';
import 'package:peche_app/models/marketplace_user.dart';
import 'package:peche_app/screens/fisherman/scan_fish_screen.dart';
import 'package:peche_app/screens/fisherman/history_screen.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/services/statistics_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final statisticsService = Provider.of<StatisticsService>(context);
    final fishService = Provider.of<FishService>(context);

    // Obtenir les statistiques pour le pêcheur connecté
    final MarketplaceUser? currentUser = authService.currentUser;
    final fishermanId = currentUser?.id?.toString() ?? '0';
    
    // Récupérer les statistiques
    final capturesThisMonth = statisticsService.getCapturesThisMonth(fishermanId);
    final differentSpeciesCount = statisticsService.getDifferentSpeciesCount(fishermanId);
    final totalWeight = statisticsService.getTotalWeight(fishermanId);
    final MarketplaceProduit? lastCapture = fishService.getLastCaptureByFisherman(fishermanId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord pêcheur'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec salutation
                Text(
                  'Bonjour, ${currentUser != null ? "${currentUser.prenom} ${currentUser.nom}" : 'Pêcheur'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Que souhaitez-vous faire aujourd\'hui?',
                  style: TextStyle(fontSize: 16, color: AppTheme.textColor),
                ),
                const SizedBox(height: 30),

                // Cartes d'actions principales
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        'Scanner un poisson',
                        Icons.camera_alt,
                        Colors.blue.shade700,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanFishScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        'Historique des captures',
                        Icons.history,
                        Colors.green.shade700,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Deuxième rangée d'actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context,
                        'Commandes',
                        Icons.shopping_cart,
                        Colors.orange.shade700,
                        () {
                          Navigator.pushNamed(context, '/fisherman/orders');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionCard(
                        context,
                        'Statistiques',
                        Icons.bar_chart,
                        Colors.purple.shade700,
                        () {
                          Navigator.pushNamed(context, '/fisherman/statistics');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Statistiques rapides
                const Text(
                  'Statistiques rapides',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Cartes de statistiques
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStatisticRow(
                        'Captures ce mois-ci',
                        capturesThisMonth.toString(),
                        Icons.catching_pokemon,
                        Colors.blue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 24),
                      _buildStatisticRow(
                        'Espèces différentes',
                        differentSpeciesCount.toString(),
                        Icons.diversity_1,
                        Colors.orange,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 24),
                      _buildStatisticRow(
                        'Poids total',
                        '${totalWeight.toStringAsFixed(1)} kg',
                        Icons.monitor_weight,
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Dernière capture
                const Text(
                  'Dernière capture',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Carte de dernière capture
                lastCapture == null
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Aucune capture récente',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                    : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/fish_placeholder.jpg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lastCapture.nom,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Prix: ${lastCapture.prix} €/kg'),
                                Text('Stock: ${lastCapture.stock} kg'),
                                Text(
                                  'Date: ${lastCapture.dateDePeche != null ? lastCapture.dateDePeche!.substring(0, 10) : "Non spécifié"}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(75),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, color: AppTheme.textColor),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
