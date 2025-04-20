import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_produit.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Tous';
  final List<String> _filterOptions = [
    'Tous',
    'Ce mois',
    'Bar',
    'Dorade',
    'Maquereau',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final fishService = Provider.of<FishService>(context);
    
    // Récupérer l'ID du pêcheur connecté
    final fishermanId = authService.currentUser?.id?.toString() ?? '0';
    
    // Récupérer les captures du pêcheur
    final List<MarketplaceProduit> captures = fishService.getFishesByFisherman(fishermanId);
    
    // Filtrer les captures selon le filtre sélectionné
    List<MarketplaceProduit> filteredCaptures = _filterCaptures(captures);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des captures'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrer par:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppTheme.primaryColor.withOpacity(
                                0.2,
                              ),
                              checkmarkColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? AppTheme.primaryColor
                                        : AppTheme.textColor,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Liste des captures
          Expanded(
            child:
                filteredCaptures.isEmpty
                    ? const Center(
                      child: Text(
                        'Aucune capture trouvée',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredCaptures.length,
                      itemBuilder: (context, index) {
                        final capture = filteredCaptures[index];
                        return _buildCaptureCard(context, capture, fishService);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/fisherman/scan');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<MarketplaceProduit> _filterCaptures(List<MarketplaceProduit> captures) {
    if (_selectedFilter == 'Tous') {
      return captures;
    } else if (_selectedFilter == 'Ce mois') {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      return captures.where((capture) {
        if (capture.dateDePeche == null) return false;
        final captureDate = DateTime.tryParse(capture.dateDePeche!);
        if (captureDate == null) return false;
        return captureDate.isAfter(firstDayOfMonth) || 
               captureDate.isAtSameMomentAs(firstDayOfMonth);
      }).toList();
    } else {
      // Filtrer par nom d'espèce
      return captures.where((capture) => 
        capture.nom.toLowerCase().contains(_selectedFilter.toLowerCase())
      ).toList();
    }
  }

  Widget _buildCaptureCard(
    BuildContext context, 
    MarketplaceProduit capture, 
    FishService fishService
  ) {
    // Formater la date
    String formattedDate = 'Date inconnue';
    if (capture.dateDePeche != null) {
      try {
        final date = DateTime.parse(capture.dateDePeche!);
        formattedDate = DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        formattedDate = capture.dateDePeche!.substring(0, 10);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du poisson
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/fish_placeholder.jpg',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // Informations sur la capture
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        capture.nom,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCaptureInfo(
                        'Prix',
                        '${capture.prix} €/kg',
                        Icons.euro,
                      ),
                      const SizedBox(width: 16),
                      _buildCaptureInfo(
                        'Stock',
                        '${capture.stock} kg',
                        Icons.inventory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildCaptureInfo(
                    'Lieu',
                    capture.zoneDePeche ?? 'Non spécifié',
                    Icons.location_on,
                  ),
                  const SizedBox(height: 8),
                  _buildCaptureInfo(
                    'Méthode',
                    capture.typologie ?? 'Non spécifié',
                    FontAwesomeIcons.fish,
                  ),
                  const SizedBox(height: 12),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // Naviguer vers l'écran de modification
                          Navigator.pushNamed(
                            context, 
                            '/fisherman/edit_fish',
                            arguments: capture.id
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Modifier'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // Afficher la boîte de dialogue de confirmation
                          _showDeleteConfirmation(context, capture, fishService);
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
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

  Widget _buildCaptureInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        icon == FontAwesomeIcons.fish
            ? FaIcon(icon, size: 16, color: Colors.grey.shade600)
            : Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    MarketplaceProduit capture,
    FishService fishService,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cette capture de ${capture.nom} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                // Supprimer la capture
                final success = await fishService.deleteFish(capture.id.toString());
                
                if (!context.mounted) return;
                Navigator.of(context).pop();
                
                // Afficher un message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Capture supprimée avec succès' 
                        : 'Erreur lors de la suppression'
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                
                // Rafraîchir l'écran
                setState(() {});
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
