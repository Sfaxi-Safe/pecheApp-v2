import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_produit.dart';
import 'package:peche_app/screens/client/fish_detail_screen.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<MarketplaceProduit> _searchResults = [];
  String _selectedCategory = '';

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Récupérer les résultats de recherche
    final fishService = Provider.of<FishService>(context, listen: false);
    final results = fishService.searchFishes(query);

    // Filtrer par catégorie si nécessaire
    final filteredResults = _selectedCategory.isEmpty
        ? results
        : results.where((fish) {
            return fish.categorie != null &&
                fish.categorie!.nom.toLowerCase() ==
                    _selectedCategory.toLowerCase();
          }).toList();

    setState(() {
      _searchResults = filteredResults;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fishService = Provider.of<FishService>(context);
    final categories = fishService.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un poisson...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _performSearch,
            ),
          ),

          // Filtres par catégorie
          if (categories.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Tous'),
                      selected: _selectedCategory.isEmpty,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = '';
                          _performSearch(_searchController.text);
                        });
                      },
                    ),
                  ),
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.nom),
                        selected: _selectedCategory == category.nom,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category.nom : '';
                            _performSearch(_searchController.text);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

          // Résultats de recherche
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _searchController.text.isEmpty
                        ? _buildSearchSuggestions()
                        : const Center(
                            child: Text(
                              'Aucun résultat trouvé',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final fish = _searchResults[index];
                          return _buildFishResultCard(fish);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final fishService = Provider.of<FishService>(context);
    final popularFishes = fishService.fishes
        .where((fish) => fishService.getAverageRating(fish.id.toString()) >= 4.0)
        .take(5)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggestions de recherche',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('Bar'),
              _buildSuggestionChip('Dorade'),
              _buildSuggestionChip('Maquereau'),
              _buildSuggestionChip('Sole'),
              _buildSuggestionChip('Thon'),
              _buildSuggestionChip('Sardine'),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Poissons populaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...popularFishes.map((fish) => _buildPopularSearchItem(
                fish.nom,
                fish.description,
                Icons.trending_up,
                fish.id.toString(),
              )),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildPopularSearchItem(String title, String subtitle, IconData icon, String fishId) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FishDetailScreen(fishId: fishId),
          ),
        );
      },
    );
  }

  Widget _buildFishResultCard(MarketplaceProduit fish) {
    final fishService = Provider.of<FishService>(context);
    final averageRating = fishService.getAverageRating(fish.id.toString());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FishDetailScreen(fishId: fish.id.toString()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image du poisson
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: fish.images.isNotEmpty
                    ? Image.network(
                        fish.images.first.url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/fish_placeholder.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
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
                      fish.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    if (fish.categorie != null)
                      Text(
                        fish.categorie!.nom,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          averageRating > 0
                              ? averageRating.toStringAsFixed(1)
                              : 'Pas d\'avis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${fish.prix.toStringAsFixed(2)} €/kg',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${fish.stock} kg',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
