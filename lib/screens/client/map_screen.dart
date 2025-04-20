import 'package:flutter/material.dart';
import 'package:peche_app/screens/client/fish_detail_screen.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Dans une application réelle, vous utiliseriez une bibliothèque comme google_maps_flutter
  // Ici, nous simulons une carte avec une image
  
  // Points de vente simulés
  final List<Map<String, dynamic>> _salesPoints = [
    {
      'id': '1',
      'name': 'Marché aux poissons du port',
      'address': '15 Quai du Port, 13001 Marseille',
      'distance': '1.2 km',
      'rating': 4.7,
      'openingHours': '6h00 - 13h00',
      'position': const Offset(150, 200),
      'fish': [
        {
          'id': '1',
          'species': 'Bar commun',
          'price': 25.90,
          'weight': 2.5,
          'fisherman': 'Pierre Dupont',
        },
        {
          'id': '2',
          'species': 'Dorade royale',
          'price': 22.50,
          'weight': 1.8,
          'fisherman': 'Marie Laurent',
        },
        {
          'id': '3',
          'species': 'Maquereau',
          'price': 12.90,
          'weight': 0.9,
          'fisherman': 'Jean Martin',
        },
      ],
    },
    {
      'id': '2',
      'name': 'Poissonnerie de la Plage',
      'address': '45 Avenue de la Plage, 13008 Marseille',
      'distance': '3.5 km',
      'rating': 4.5,
      'openingHours': '8h00 - 19h00',
      'position': const Offset(250, 300),
      'fish': [
        {
          'id': '4',
          'species': 'Sole',
          'price': 32.90,
          'weight': 1.2,
          'fisherman': 'Pierre Dupont',
        },
        {
          'id': '2',
          'species': 'Dorade royale',
          'price': 23.50,
          'weight': 1.5,
          'fisherman': 'Marie Laurent',
        },
      ],
    },
    {
      'id': '3',
      'name': 'Marché de la Criée',
      'address': '10 Rue de la Criée, 13002 Marseille',
      'distance': '2.8 km',
      'rating': 4.8,
      'openingHours': '5h00 - 12h00',
      'position': const Offset(180, 150),
      'fish': [
        {
          'id': '1',
          'species': 'Bar commun',
          'price': 24.90,
          'weight': 2.2,
          'fisherman': 'Pierre Dupont',
        },
        {
          'id': '3',
          'species': 'Maquereau',
          'price': 11.90,
          'weight': 0.8,
          'fisherman': 'Jean Martin',
        },
        {
          'id': '5',
          'species': 'Thon rouge',
          'price': 45.90,
          'weight': 3.5,
          'fisherman': 'Marie Laurent',
        },
      ],
    },
  ];
  
  Map<String, dynamic>? _selectedSalesPoint;

  @override
  Widget build(BuildContext context) {
    final fishService = Provider.of<FishService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte interactive'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Carte simulée
          Expanded(
            child: Stack(
              children: [
                // Image de carte simulée
                Image.network(
                  'https://images.unsplash.com/photo-1569336415962-a4bd9f69c07a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                
                // Points de vente sur la carte
                ..._salesPoints.map((point) {
                  final isSelected = _selectedSalesPoint == point;
                  return Positioned(
                    left: (point['position'] as Offset).dx,
                    top: (point['position'] as Offset).dy,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSalesPoint = point;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: isSelected ? 50 : 40,
                        width: isSelected ? 50 : 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.store,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryColor,
                            size: isSelected ? 24 : 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                
                // Bouton de localisation
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Simuler la localisation de l'utilisateur
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Localisation en cours...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Détails du point de vente sélectionné
          if (_selectedSalesPoint != null)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSalesPoint!['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedSalesPoint!['rating'].toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedSalesPoint!['address'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedSalesPoint!['distance'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ouvert: ${_selectedSalesPoint!['openingHours']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'Poissons disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Liste des poissons disponibles
                    ...(_selectedSalesPoint!['fish'] as List).map<Widget>((fish) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Vérifier si le poisson existe dans notre service
                            final fishFromService = fishService.getFishById(fish['id']);
                            if (fishFromService != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FishDetailScreen(
                                    fishId: fish['id'],
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Détails du poisson non disponibles'),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fish['species'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Pêcheur: ${fish['fisherman']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        'Poids: ${fish['weight']} kg',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${fish['price'].toStringAsFixed(2)} €',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(fish['price'] / fish['weight']).toStringAsFixed(2)} €/kg',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    
                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              // Ouvrir l'itinéraire dans Google Maps
                              final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_selectedSalesPoint!['address'])}';
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Impossible d\'ouvrir Google Maps'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Itinéraire'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(color: AppTheme.primaryColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Naviguer vers l'écran de commande
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sélectionnez un poisson spécifique pour commander'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Commander'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
