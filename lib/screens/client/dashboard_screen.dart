import 'package:flutter/material.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/screens/client/available_auctions_screen.dart';
import 'package:seatrace/screens/client/search_screen.dart';
import 'package:seatrace/screens/client/my_purchases_screen.dart';
import 'package:seatrace/screens/profile_screen.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/utils/color_extensions.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/sea_widgets.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  String _userName = '';
  String _userPhoto = '';
  String _userTelephone = '';
  String _userEmail = '';
  String _userAdresse = '';
  int _availableAuctions = 0;
  int _myPurchases = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _featuredAuctions = [];

  final _animationService = AnimationService();
  final _responsiveService = ResponsiveService();
  final _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Charger les détails du client
      final userData = await ApiService.instance.getClientDetails(user.id);

      setState(() {
        _userName = '${userData['prenom']} ${userData['nom']}';
        _userPhoto = userData['photo'] ?? '';
        _userTelephone = userData['telephone'] ?? '';
        _userEmail = userData['email'] ?? '';
        _userAdresse = userData['adresse'] ?? '';
      });

      // Charger les statistiques
      final stats = await ApiService.instance.getDashboardStats();

      setState(() {
        _availableAuctions = stats['availableAuctions'] ?? 0;
        _myPurchases = stats['myPurchases'] ?? 0;
        _isLoading = false;
      });

      // Charger les enchères en vedette (données réelles depuis l'API)
      await _loadFeaturedAuctions();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFeaturedAuctions() async {
    try {
      // Récupérer les lots réels depuis l'API
      final response = await ApiService.instance.get('lots/featured');
      final lots = List<Map<String, dynamic>>.from(response['data'] ?? []);

      // Transformer les données pour correspondre au format attendu
      _featuredAuctions =
          lots.map((lot) {
            // Calculer le temps restant (exemple: différence entre maintenant et la date de fin)
            String timeLeft = '1h';
            if (lot['dateSoumission'] != null) {
              final dateSoumission = DateTime.tryParse(lot['dateSoumission']);
              if (dateSoumission != null) {
                final now = DateTime.now();
                final difference = dateSoumission.difference(now);
                if (difference.inHours > 0) {
                  timeLeft =
                      '${difference.inHours}h ${difference.inMinutes % 60}m';
                } else if (difference.inMinutes > 0) {
                  timeLeft = '${difference.inMinutes}m';
                } else {
                  timeLeft = 'Bientôt terminé';
                }
              }
            }

            // Récupérer le nom de l'espèce
            String title = 'Lot de poisson';
            if (lot['espece'] != null && lot['espece']['nom'] != null) {
              title = lot['espece']['nom'];
            }

            // Récupérer le prix
            String price = 'Prix non défini';
            if (lot['prixInitial'] != null) {
              price = '${lot['prixInitial']} TND';
            }

            // Récupérer le poids
            String weight = 'Poids non défini';
            if (lot['poids'] != null) {
              weight = '${lot['poids']} kg';
            }

            // Récupérer la localisation
            String location = 'Lieu non défini';
            if (lot['prise'] != null && lot['prise']['lieu'] != null) {
              location = lot['prise']['lieu'];
            }

            return {
              'id': lot['_id'] ?? '',
              'title': title,
              'price': price,
              'image': lot['imageUrl'] ?? '',
              'time_left': timeLeft,
              'weight': weight,
              'location': location,
            };
          }).toList();

      // Si aucun lot n'est disponible, afficher un message
      if (_featuredAuctions.isEmpty) {
        setState(() {
          _featuredAuctions = [];
        });
      }
    } catch (e) {
      // En cas d'erreur, ne pas afficher d'enchères
      ErrorHandler.instance.logError(
        e,
        context: 'ClientDashboardScreen._loadFeaturedAuctions',
      );
      setState(() {
        _featuredAuctions = [];
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    _navigationService.replaceAllWithFade(context, const LoginScreen());
  }

  String _getInitials() {
    if (_userName.isEmpty) return '?';

    final nameParts = _userName.split(' ');
    String initials = '';

    if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      initials += nameParts[0][0];
    }

    if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
      initials += nameParts[1][0];
    }

    return initials;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isPhone = _responsiveService.isPhone(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Client'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _navigationService.navigateToWithFade(
                context,
                const ProfileScreen(),
              );
            },
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorView()
                : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    padding: _responsiveService.adaptivePadding(context),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _animationService.staggeredList([
                        // En-tête avec informations utilisateur
                        _buildWelcomeCard(),

                        // Barre de recherche
                        const SizedBox(height: 24),
                        _buildSearchBar(),

                        // Actions principales
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Actions',
                          icon: Icons.touch_app,
                        ),
                        _buildActionCards(isPhone),

                        // Enchères en vedette
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Enchères en vedette',
                          icon: Icons.star,
                          actionText: 'Voir tout',
                          onActionPressed: () {
                            _navigationService.navigateToWithSlideLeft(
                              context,
                              const AvailableAuctionsScreen(),
                            );
                          },
                        ),
                        _buildFeaturedAuctionsCarousel(),

                        // Statistiques
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Statistiques',
                          icon: Icons.bar_chart,
                        ),
                        _buildStatisticsRow(),
                      ]),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildErrorView() {
    return _animationService.fadeIn(
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SeaButton.primary(
                text: 'Réessayer',
                icon: Icons.refresh,
                onPressed: _loadUserData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return SeaCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar de l'utilisateur
              SeaAvatar(
                imageUrl:
                    _userPhoto.isNotEmpty
                        ? ApiService.instance.getImageUrl(_userPhoto)
                        : null,
                initials: _getInitials(),
                size: 60,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                foregroundColor: primaryColor,
                bordered: true,
                borderColor: primaryColor,
              ),
              const SizedBox(width: 16),

              // Informations utilisateur principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, $_userName',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_userEmail.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userEmail,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Informations supplémentaires
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Informations de contact et adresse
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userAdresse.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Adresse: $_userAdresse',
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Téléphone
              if (_userTelephone.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        _userTelephone,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Enchères disponibles
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.gavel, size: 16, color: theme.colorScheme.secondary),
              const SizedBox(width: 4),
              Text(
                'Il y a $_availableAuctions enchères disponibles',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);

    return SeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Rechercher un poisson',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              _navigationService.navigateToWithSlideUp(
                context,
                const SearchScreen(),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      theme.dividerTheme.color ??
                      Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: theme.hintColor),
                  const SizedBox(width: 12),
                  Text(
                    'Rechercher par espèce, poids, prix...',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(bool isPhone) {
    if (isPhone) {
      return Column(
        children: [
          _buildActionCard(
            icon: Icons.gavel,
            title: 'Enchères disponibles',
            description: 'Parcourir et participer aux enchères',
            color: Colors.blue,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const AvailableAuctionsScreen(),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.shopping_bag,
            title: 'Mes achats',
            description: 'Voir l\'historique de vos achats',
            color: Colors.green,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const MyPurchasesScreen(),
              );
            },
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _buildActionCard(
              icon: Icons.gavel,
              title: 'Enchères disponibles',
              description: 'Parcourir et participer aux enchères',
              color: Colors.blue,
              onTap: () {
                _navigationService.navigateToWithSlideLeft(
                  context,
                  const AvailableAuctionsScreen(),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              icon: Icons.shopping_bag,
              title: 'Mes achats',
              description: 'Voir l\'historique de vos achats',
              color: Colors.green,
              onTap: () {
                _navigationService.navigateToWithSlideLeft(
                  context,
                  const MyPurchasesScreen(),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SeaCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Voir',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedAuctionsCarousel() {
    final theme = Theme.of(context);

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredAuctions.length,
        itemBuilder: (context, index) {
          final auction = _featuredAuctions[index];
          return _animationService.fadeIn(
            Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              child: SeaCard(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        color: theme.colorScheme.surface,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: theme.dividerTheme.color,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  auction['time_left'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Info
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auction['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.scale,
                                size: 14,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                auction['weight'] as String,
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: theme.hintColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                auction['location'] as String,
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                auction['price'] as String,
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: theme.colorScheme.secondary,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsRow() {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: SeaStatCard(
            label: 'Enchères disponibles',
            value: _availableAuctions.toString(),
            icon: Icons.gavel,
            color: Colors.blue,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const AvailableAuctionsScreen(),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SeaStatCard(
            label: 'Mes achats',
            value: _myPurchases.toString(),
            icon: Icons.shopping_bag,
            color: theme.colorScheme.secondary,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const MyPurchasesScreen(),
              );
            },
          ),
        ),
      ],
    );
  }
}
