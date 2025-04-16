import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/fish_service.dart';
import '../../services/auth_service.dart';
import '../../models/fish.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/theme_switch.dart';
import '../messaging/conversations_screen.dart';
import '../../utils/page_transitions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Charger les poissons au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FishService>(context, listen: false).loadFishes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final fishService = Provider.of<FishService>(context);
    final user = authService.currentUser;
    
    // Filtrer les poissons en fonction de la recherche
    List<Fish> filteredFishes = _searchQuery.isEmpty
        ? fishService.fishes
        : fishService.fishes.where((fish) {
            return fish.species.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un poisson...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: _updateSearchQuery,
              )
            : const Text('Pêche App'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _stopSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.of(context).pushWithSlide(
                const ConversationsScreen(),
                direction: SlideDirection.left,
              );
            },
          ),
          const ThemeSwitch(),
        ],
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tous'),
                  Tab(text: 'Populaires'),
                  Tab(text: 'Récents'),
                ],
              ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet "Tous"
          _buildFishGrid(context, filteredFishes),
          
          // Onglet "Populaires"
          _buildFishGrid(
            context,
            filteredFishes
                .where((fish) => fishService.getAverageRating(fish.id) >= 4.0)
                .toList(),
          ),
          
          // Onglet "Récents"
          _buildFishGrid(
            context,
            filteredFishes
                .where((fish) {
                  final now = DateTime.now();
                  final difference = now.difference(fish.captureDate);
                  return difference.inDays <= 7; // Poissons capturés dans les 7 derniers jours
                })
                .toList(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Utilisateur'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.profileImageUrl != null
                    ? NetworkImage(user!.profileImageUrl!)
                    : null,
                child: user?.profileImageUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Mes commandes'),
              onTap: () {
                Navigator.pop(context);
                // Naviguer vers l'écran des commandes
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushWithSlide(
                  const ConversationsScreen(),
                  direction: SlideDirection.left,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // Naviguer vers l'écran des paramètres
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Déconnexion'),
              onTap: () async {
                await authService.logout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFishGrid(BuildContext context, List<Fish> fishes) {
    if (fishes.isEmpty) {
      return const Center(
        child: Text('Aucun poisson trouvé'),
      );
    }

    return GridView.builder(
      padding: context.responsivePadding(const EdgeInsets.all(16)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.responsive(
          mobile: 2,
          tablet: 3,
          desktop: 4,
        ),
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: fishes.length,
      itemBuilder: (context, index) {
        final fish = fishes[index];
        return AnimatedListItem(
          index: index,
          animationType: AnimationType.fade,
          child: _buildFishCard(context, fish),
        );
      },
    );
  }

  Widget _buildFishCard(BuildContext context, Fish fish) {
    final fishService = Provider.of<FishService>(context);
    final averageRating = fishService.getAverageRating(fish.id);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du poisson
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Image.network(
                fish.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Informations du poisson
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fish.species,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: context.responsiveFontSize(16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      averageRating > 0
                          ? averageRating.toStringAsFixed(1)
                          : 'Pas d\'avis',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(12),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${fish.weight} kg - ${fish.length} cm',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(12),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton Voir détails
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedButton(
              onPressed: () {
                // Naviguer vers l'écran de détails du poisson
              },
              color: Theme.of(context).primaryColor,
              child: const Text('Voir détails'),
            ),
          ),
        ],
      ),
    );
  }
}
