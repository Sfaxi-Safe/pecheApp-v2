import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/lazy_loading_service.dart';
import '../../models/fish.dart';
import '../../services/database_helper.dart';
import '../../utils/image_cache_manager.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_list_item.dart';

class FishListScreen extends StatefulWidget {
  const FishListScreen({Key? key}) : super(key: key);

  @override
  _FishListScreenState createState() => _FishListScreenState();
}

class _FishListScreenState extends State<FishListScreen> {
  late LazyLoadingService<Fish> _lazyLoadingService;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initialiser le service de chargement paresseux
    _lazyLoadingService = LazyLoadingService<Fish>(
      loadItemsFunction: _loadFishes,
      pageSize: 10,
    );
    
    // Charger la première page
    _lazyLoadingService.loadFirstPage();
    
    // Ajouter un écouteur de défilement pour charger plus de données
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Fonction de chargement des poissons avec pagination
  Future<List<Fish>> _loadFishes(int page, int pageSize) async {
    final dbHelper = DatabaseHelper();
    final fishes = await dbHelper.getFishesPaginated(page, pageSize);
    
    // Précharger les images pour une meilleure expérience utilisateur
    final imageUrls = fishes.map((fish) => fish.imageUrl).toList();
    CustomCacheManager.preloadImages(imageUrls);
    
    return fishes;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _lazyLoadingService.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poissons disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _lazyLoadingService.refresh();
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: _lazyLoadingService,
        child: Consumer<LazyLoadingService<Fish>>(
          builder: (context, service, child) {
            if (service.items.isEmpty && service.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (service.items.isEmpty && service.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      service.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        service.refresh();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (service.items.isEmpty) {
              return const Center(
                child: Text('Aucun poisson disponible'),
              );
            }

            return RefreshIndicator(
              onRefresh: () => service.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                padding: context.responsivePadding(const EdgeInsets.all(16)),
                itemCount: service.items.length + (service.hasMoreItems ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == service.items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final fish = service.items[index];
                  return AnimatedListItem(
                    index: index,
                    child: _buildFishCard(context, fish),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFishCard(BuildContext context, Fish fish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Naviguer vers l'écran de détails du poisson
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Image du poisson avec mise en cache
            CachedImage(
              imageUrl: fish.imageUrl,
              width: context.responsiveWidth(120),
              height: context.responsiveWidth(120),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              placeholder: const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
            
            // Informations du poisson
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fish.species,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Poids: ${fish.weight} kg',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                    Text(
                      'Taille: ${fish.length} cm',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                    Text(
                      'Lieu: ${fish.location}',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                    Text(
                      'Méthode: ${fish.fishingMethod}',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
