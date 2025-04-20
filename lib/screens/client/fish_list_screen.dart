import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/lazy_loading_service.dart';
import '../../models/marketplace_produit.dart';
import '../../services/database_helper.dart';
import '../../utils/image_cache_manager.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_list_item.dart';
import 'fish_detail_screen.dart';

class FishListScreen extends StatefulWidget {
  const FishListScreen({super.key});

  @override
  FishListScreenState createState() => FishListScreenState();
}

class FishListScreenState extends State<FishListScreen> {
  late LazyLoadingService<MarketplaceProduit> _lazyLoadingService;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialiser le service de chargement paresseux
    _lazyLoadingService = LazyLoadingService<MarketplaceProduit>(
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
  Future<List<MarketplaceProduit>> _loadFishes(int page, int pageSize) async {
    final dbHelper = DatabaseHelper();
    final fishes = await dbHelper.getProduitsPaginated(page, pageSize);

    // Précharger les images pour une meilleure expérience utilisateur
    for (var fish in fishes) {
      if (fish.images.isNotEmpty) {
        CustomCacheManager.preloadImages([fish.images.first.url]);
      } else {
        CustomCacheManager.preloadImages(['assets/images/fish_placeholder.jpg']);
      }
    }

    return fishes;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
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
        child: Consumer<LazyLoadingService<MarketplaceProduit>>(
          builder: (context, service, child) {
            if (service.items.isEmpty && service.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (service.items.isEmpty && service.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(service.errorMessage!, textAlign: TextAlign.center),
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
              return const Center(child: Text('Aucun poisson disponible'));
            }

            return RefreshIndicator(
              onRefresh: () => service.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                padding: context.responsivePadding(const EdgeInsets.all(16)),
                itemCount:
                    service.items.length + (service.hasMoreItems ? 1 : 0),
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

  Widget _buildFishCard(BuildContext context, MarketplaceProduit fish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
        child: Row(
          children: [
            // Image du poisson avec mise en cache
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: fish.images.isNotEmpty
                  ? Image.network(
                      fish.images.first.url,
                      width: context.responsiveWidth(120),
                      height: context.responsiveWidth(120),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/fish_placeholder.jpg',
                          width: context.responsiveWidth(120),
                          height: context.responsiveWidth(120),
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/fish_placeholder.jpg',
                      width: context.responsiveWidth(120),
                      height: context.responsiveWidth(120),
                      fit: BoxFit.cover,
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
                      fish.nom,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Prix: ${fish.prix.toStringAsFixed(2)} €/kg',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                    Text(
                      'Stock: ${fish.stock} kg',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                    ),
                    if (fish.categorie != null)
                      Text(
                        'Catégorie: ${fish.categorie!.nom}',
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

// Widget pour la mise en cache des images
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Widget placeholder;
  final Widget errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.placeholder,
    required this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl.startsWith('assets/')
          ? Image.asset(
              imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
            )
          : Image.network(
              imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder;
              },
              errorBuilder: (context, error, stackTrace) {
                return errorWidget;
              },
            ),
    );
  }
}
