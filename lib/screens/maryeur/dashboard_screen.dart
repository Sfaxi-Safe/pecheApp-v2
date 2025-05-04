import 'package:flutter/material.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/screens/maryeur/pending_lots_screen.dart';
import 'package:seatrace/screens/maryeur/active_auctions_screen.dart';
import 'package:seatrace/screens/profile_screen.dart';
import 'package:seatrace/screens/lot_details_screen.dart';
import 'package:seatrace/screens/notifications_screen.dart';
import 'package:seatrace/services/notification_service.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/sea_widgets.dart';
import 'package:seatrace/widgets/sea_filter_bar.dart';
import 'package:seatrace/widgets/notification_badge.dart';
import 'package:intl/intl.dart';

class MaryeurDashboardScreen extends StatefulWidget {
  const MaryeurDashboardScreen({super.key});

  @override
  State<MaryeurDashboardScreen> createState() => _MaryeurDashboardScreenState();
}

class _MaryeurDashboardScreenState extends State<MaryeurDashboardScreen> {
  String _userName = '';
  String _userPhoto = '';
  String _userTelephone = '';
  String _userSociete = '';
  String _userRegistre = '';
  String _userAdresse = '';
  int _pendingLots = 0;
  int _activeAuctions = 0;
  int _completedAuctions = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _filteredActivities = [];

  // Filtres
  String? _selectedStatusFilter;
  DateFilter _dateFilter = DateFilter.all();
  bool _showFilters = false;

  final _animationService = AnimationService();
  final _responsiveService = ResponsiveService();
  final _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Initialiser le service de notifications
    NotificationService.instance.initialize();
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Préparer les paramètres de filtrage
      bool? venduFilter;
      bool? hasPrixInitialFilter;
      DateTime? dateDebut;
      DateTime? dateFin;

      // Convertir le filtre de statut en paramètres appropriés
      if (_selectedStatusFilter != null) {
        if (_selectedStatusFilter == 'Vendu') {
          venduFilter = true;
        } else if (_selectedStatusFilter == 'En enchère') {
          venduFilter = false;
          hasPrixInitialFilter = true;
        } else if (_selectedStatusFilter == 'Prix défini') {
          venduFilter = false;
          hasPrixInitialFilter = false;
        }
      }

      // Préparer les dates de début et de fin selon le filtre de date
      if (_dateFilter.type != DateFilterType.all) {
        dateDebut = _dateFilter.startDate;
        dateFin = _dateFilter.endDate;
      }

      // Appeler l'API avec les filtres
      final lots = await ApiService.instance.getLotsByMaryeurId(
        user.id,
        vendu: venduFilter,
        hasPrixInitial: hasPrixInitialFilter,
        dateDebut: dateDebut,
        dateFin: dateFin,
      );

      // Trier par date (plus récent en premier)
      lots.sort((a, b) {
        final dateA =
            a['dateSoumission'] != null
                ? DateTime.parse(a['dateSoumission'])
                : DateTime(1900);
        final dateB =
            b['dateSoumission'] != null
                ? DateTime.parse(b['dateSoumission'])
                : DateTime(1900);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _filteredActivities = lots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du filtrage: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer l'utilisateur connecté
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Log pour déboguer
      ErrorHandler.instance.logInfo(
        'Utilisateur récupéré: id=${user.id}, nom=${user.nom}, prenom=${user.prenom}',
        context: 'MaryeurDashboardScreen._loadUserData',
      );

      // Charger les détails du maryeur
      final userData = await ApiService.instance.getMaryeurDetails(user.id);

      // Log pour déboguer
      ErrorHandler.instance.logInfo(
        'Détails maryeur: ${userData.toString()}',
        context: 'MaryeurDashboardScreen._loadUserData',
      );

      // Créer un objet utilisateur complet en combinant les données de base et les détails
      String userName = '${user.prenom} ${user.nom}';
      String userPhoto = user.photo ?? '';
      String userTelephone = user.telephone ?? '';
      String userSociete = '';
      String userRegistre = '';
      String userAdresse = '';

      // Mettre à jour les informations de base si elles sont disponibles dans les détails
      if (userData['prenom'] != null &&
          userData['prenom'].toString().isNotEmpty &&
          userData['nom'] != null &&
          userData['nom'].toString().isNotEmpty) {
        userName = '${userData['prenom']} ${userData['nom']}';
      }

      if (userData['photo'] != null &&
          userData['photo'].toString().isNotEmpty) {
        userPhoto = userData['photo'];
      }

      if (userData['telephone'] != null &&
          userData['telephone'].toString().isNotEmpty) {
        userTelephone = userData['telephone'];
      }

      // Récupérer les informations spécifiques au mareyeur
      if (userData['societe'] != null) {
        userSociete = userData['societe'].toString();
      }

      if (userData['registre'] != null) {
        userRegistre = userData['registre'].toString();
      }

      if (userData['adresse'] != null) {
        userAdresse = userData['adresse'].toString();
      }

      // Mettre à jour l'état avec les informations complètes
      setState(() {
        _userName = userName;
        _userPhoto = userPhoto;
        _userTelephone = userTelephone;
        _userSociete = userSociete;
        _userRegistre = userRegistre;
        _userAdresse = userAdresse;
      });

      // Charger les statistiques
      final stats = await ApiService.instance.getMaryeurStats(user.id);

      // Charger les activités récentes (lots récemment traités)
      final lots = await ApiService.instance.getLotsByMaryeurId(user.id);

      // Trier par date (plus récent en premier) et prendre les 5 premiers
      lots.sort((a, b) {
        final dateA =
            a['dateSoumission'] != null
                ? DateTime.parse(a['dateSoumission'])
                : DateTime(1900);
        final dateB =
            b['dateSoumission'] != null
                ? DateTime.parse(b['dateSoumission'])
                : DateTime(1900);
        return dateB.compareTo(dateA);
      });

      final recentActivities = lots.take(5).toList();

      setState(() {
        _pendingLots = stats['pendingLots'] ?? 0;
        _activeAuctions = stats['activeAuctions'] ?? 0;
        _completedAuctions = stats['completedAuctions'] ?? 0;
        _filteredActivities = recentActivities;
        _isLoading = false;
      });
    } catch (e) {
      // En cas d'erreur, essayer de récupérer au moins les informations de base de l'utilisateur
      try {
        final user = await AuthService().getCurrentUser();
        if (user != null) {
          setState(() {
            _userName = '${user.prenom} ${user.nom}';
            _userPhoto = user.photo ?? '';
            _userTelephone = user.telephone ?? '';
            _isLoading = false;
          });
        }
      } catch (secondError) {
        debugPrint('Erreur secondaire: $secondError');
      }

      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
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
    final isPhone = _responsiveService.isPhone(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Maryeur'),
        elevation: 0,
        actions: [
          // Badge de notification
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: NotificationBadge(
              icon: Icons.notifications,
              iconSize: 24,
              badgeColor: Theme.of(context).colorScheme.error,
              onTap: () {
                _navigationService.navigateToWithSlideLeft(
                  context,
                  const NotificationsScreen(),
                );
              },
            ),
          ),
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

                        // Cartes d'action principales
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Actions',
                          icon: Icons.touch_app,
                        ),
                        _buildActionCards(isPhone),

                        // Statistiques
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Statistiques',
                          icon: Icons.bar_chart,
                        ),
                        _buildStatisticsRow(),

                        // Activité récente
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Activité récente',
                          icon: Icons.history,
                          actionText:
                              _showFilters ? 'Masquer filtres' : 'Filtrer',
                          onActionPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),
                        if (_showFilters) _buildFilterBar(),
                        _buildRecentActivityList(),
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
                    if (_userSociete.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Société: $_userSociete',
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

          // Informations professionnelles
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userRegistre.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Registre: $_userRegistre',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (_userAdresse.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Adresse: $_userAdresse',
                            style: theme.textTheme.bodyMedium,
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

          // Lots en attente
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.pending_actions,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Vous avez $_pendingLots lots en attente de prix initial',
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

  Widget _buildActionCards(bool isPhone) {
    if (isPhone) {
      return Column(
        children: [
          _buildActionCard(
            icon: Icons.pending_actions,
            title: 'Lots en attente',
            description: 'Définir les prix initiaux',
            count: _pendingLots,
            color: Colors.orange,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const PendingLotsMaryeurScreen(),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.gavel,
            title: 'Enchères actives',
            description: 'Suivre les enchères en cours',
            count: _activeAuctions,
            color: Colors.blue,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const ActiveAuctionsScreen(),
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
              icon: Icons.pending_actions,
              title: 'Lots en attente',
              description: 'Définir les prix initiaux',
              count: _pendingLots,
              color: Colors.orange,
              onTap: () {
                _navigationService.navigateToWithSlideLeft(
                  context,
                  const PendingLotsMaryeurScreen(),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              icon: Icons.gavel,
              title: 'Enchères actives',
              description: 'Suivre les enchères en cours',
              count: _activeAuctions,
              color: Colors.blue,
              onTap: () {
                _navigationService.navigateToWithSlideLeft(
                  context,
                  const ActiveAuctionsScreen(),
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
    required int count,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  if (count > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
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

  Widget _buildStatisticsRow() {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: SeaStatCard(
            label: 'En attente',
            value: _pendingLots.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const PendingLotsMaryeurScreen(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SeaStatCard(
            label: 'Enchères actives',
            value: _activeAuctions.toString(),
            icon: Icons.gavel,
            color: Colors.blue,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const ActiveAuctionsScreen(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SeaStatCard(
            label: 'Complétées',
            value: _completedAuctions.toString(),
            icon: Icons.check_circle,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SeaFilterBar(
      statusFilters: const ['Vendu', 'En enchère', 'Prix défini'],
      selectedStatusFilter: _selectedStatusFilter,
      dateFilter: _dateFilter,
      onStatusFilterChanged: (value) {
        setState(() {
          _selectedStatusFilter = value;
        });
        _applyFilters();
      },
      onDateFilterChanged: (value) {
        setState(() {
          _dateFilter = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildRecentActivityList() {
    final theme = Theme.of(context);

    // Si aucune donnée n'est disponible, afficher un message
    if (_filteredActivities.isEmpty) {
      return _animationService.fadeIn(
        SeaCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(Icons.history_outlined, size: 48, color: theme.hintColor),
                const SizedBox(height: 16),
                Text(
                  'Aucune activité récente',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Les lots que vous traitez apparaîtront ici',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SeaButton.primary(
                  text: 'Voir les lots en attente',
                  icon: Icons.pending_actions,
                  onPressed: () {
                    _navigationService.navigateToWithSlideLeft(
                      context,
                      const PendingLotsMaryeurScreen(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children:
          _filteredActivities.map((lot) {
            // Déterminer le statut et l'icône
            IconData icon;
            Color color;
            String status;

            if (lot['vendu'] == true) {
              icon = Icons.check_circle;
              color = theme.colorScheme.secondary;
              status = 'Vendu';
            } else if (lot['prixInitial'] != null) {
              icon = Icons.gavel;
              color = Colors.blue;
              status = 'En enchère';
            } else {
              icon = Icons.price_check;
              color = Colors.orange;
              status = 'Prix défini';
            }

            // Formater la date
            final date =
                lot['dateSoumission'] != null
                    ? DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(lot['dateSoumission']))
                    : 'Date inconnue';

            // Obtenir le titre (nom de l'espèce)
            final title =
                lot['espece'] != null
                    ? (lot['espece'] is Map
                        ? lot['espece']['nom']
                        : lot['espece'].toString())
                    : 'Lot inconnu';

            // Formater le prix
            final price =
                lot['prixInitial'] != null
                    ? '${lot['prixInitial']} TND'
                    : (lot['prixFinal'] != null
                        ? '${lot['prixFinal']} TND'
                        : 'N/A');

            return _animationService.fadeIn(
              SeaCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(date),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Naviguer vers les détails du lot si un ID est disponible
                    if (lot['_id'] != null || lot['id'] != null) {
                      final lotId = lot['_id'] ?? lot['id'];
                      _navigationService.navigateToWithSlideLeft(
                        context,
                        LotDetailsScreen(lotId: lotId.toString()),
                      );
                    }
                  },
                ),
              ),
            );
          }).toList(),
    );
  }
}
