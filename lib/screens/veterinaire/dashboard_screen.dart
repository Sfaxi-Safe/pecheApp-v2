import 'package:flutter/material.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/screens/veterinaire/pending_lots_screen.dart';
import 'package:seatrace/screens/profile_screen.dart';
import 'package:seatrace/screens/lot_details_screen.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/sea_widgets.dart';
import 'package:seatrace/widgets/sea_filter_bar.dart';
import 'package:intl/intl.dart';

class VeterinaireDashboardScreen extends StatefulWidget {
  const VeterinaireDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VeterinaireDashboardScreen> createState() =>
      _VeterinaireDashboardScreenState();
}

class _VeterinaireDashboardScreenState
    extends State<VeterinaireDashboardScreen> {
  String _userName = '';
  String _userPhoto = '';
  String _userTelephone = '';
  String _userSpecialite = '';
  String _userLicence = '';
  String _userEtablissement = '';
  int _pendingLots = 0;
  int _approvedLots = 0;
  int _rejectedLots = 0;
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
      bool? statusFilter;
      DateTime? dateDebut;
      DateTime? dateFin;

      // Convertir le filtre de statut en booléen
      if (_selectedStatusFilter != null) {
        statusFilter = _selectedStatusFilter == 'Approuvé';
      }

      // Préparer les dates de début et de fin selon le filtre de date
      if (_dateFilter.type != DateFilterType.all) {
        dateDebut = _dateFilter.startDate;
        dateFin = _dateFilter.endDate;
      }

      // Appeler l'API avec les filtres
      final lots = await ApiService.instance.getLotsByVeterinaireId(
        user.id,
        status: statusFilter,
        dateDebut: dateDebut,
        dateFin: dateFin,
      );

      // Filtrer les lots qui ont été testés
      final testedLots = lots.where((lot) => lot['test'] == true).toList();

      // Trier par date (plus récent en premier)
      testedLots.sort((a, b) {
        final dateA =
            a['dateTest'] != null
                ? DateTime.parse(a['dateTest'])
                : DateTime(1900);
        final dateB =
            b['dateTest'] != null
                ? DateTime.parse(b['dateTest'])
                : DateTime(1900);
        return dateB.compareTo(dateA);
      });

      setState(() {
        _filteredActivities = testedLots;
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
        context: 'VeterinaireDashboardScreen._loadUserData',
      );

      // Charger les détails du vétérinaire
      final userData = await ApiService.instance.getVeterinaireDetails(user.id);

      // Log pour déboguer
      ErrorHandler.instance.logInfo(
        'Détails vétérinaire: ${userData.toString()}',
        context: 'VeterinaireDashboardScreen._loadUserData',
      );

      // Créer un objet utilisateur complet en combinant les données de base et les détails
      String userName = '${user.prenom} ${user.nom}';
      String userPhoto = user.photo ?? '';
      String userTelephone = user.telephone ?? '';
      String userSpecialite = '';
      String userLicence = '';
      String userEtablissement = '';

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

      // Récupérer les informations spécifiques au vétérinaire
      if (userData['specialite'] != null) {
        userSpecialite = userData['specialite'].toString();
      }

      if (userData['licence'] != null) {
        userLicence = userData['licence'].toString();
      }

      if (userData['etablissement'] != null) {
        userEtablissement = userData['etablissement'].toString();
      }

      // Mettre à jour l'état avec les informations complètes
      setState(() {
        _userName = userName;
        _userPhoto = userPhoto;
        _userTelephone = userTelephone;
        _userSpecialite = userSpecialite;
        _userLicence = userLicence;
        _userEtablissement = userEtablissement;
      });

      // Charger les statistiques et les activités récentes
      final lots = await ApiService.instance.getLotsByVeterinaireId(user.id);

      // Filtrer les lots pour les statistiques
      final pendingLots = lots.where((lot) => lot['test'] == false).toList();
      final approvedLots =
          lots
              .where((lot) => lot['test'] == true && lot['status'] == true)
              .toList();
      final rejectedLots =
          lots
              .where((lot) => lot['test'] == true && lot['status'] == false)
              .toList();

      // Préparer les activités récentes (lots validés ou refusés)
      final recentLots = [...approvedLots, ...rejectedLots];

      // Trier par date (plus récent en premier) et prendre les 5 premiers
      recentLots.sort((a, b) {
        final dateA =
            a['dateTest'] != null
                ? DateTime.parse(a['dateTest'])
                : DateTime(1900);
        final dateB =
            b['dateTest'] != null
                ? DateTime.parse(b['dateTest'])
                : DateTime(1900);
        return dateB.compareTo(dateA);
      });

      final recentActivities = recentLots.take(5).toList();

      setState(() {
        _pendingLots = pendingLots.length;
        _approvedLots = approvedLots.length;
        _rejectedLots = rejectedLots.length;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Vétérinaire'),
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

                        // Carte d'action principale
                        const SizedBox(height: 24),
                        _buildMainActionCard(),

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
                          subtitle: 'Historique des validations récentes',
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
                    if (_userSpecialite.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Spécialité: $_userSpecialite',
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
                    if (_userLicence.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.card_membership,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Licence: $_userLicence',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (_userEtablissement.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Établissement: $_userEtablissement',
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
                'Vous avez $_pendingLots lots en attente de validation',
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

  Widget _buildMainActionCard() {
    final theme = Theme.of(context);

    return SeaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pending_actions,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lots en attente',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Examiner et valider les lots de poissons',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (_pendingLots > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _pendingLots.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SeaButton.primary(
            text: 'Voir les lots en attente',
            icon: Icons.arrow_forward,
            onPressed: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const PendingLotsScreen(),
              );
            },
            width: double.infinity,
          ),
        ],
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
                const PendingLotsScreen(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SeaStatCard(
            label: 'Approuvés',
            value: _approvedLots.toString(),
            icon: Icons.check_circle,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SeaStatCard(
            label: 'Refusés',
            value: _rejectedLots.toString(),
            icon: Icons.cancel,
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SeaFilterBar(
      statusFilters: const ['Approuvé', 'Refusé'],
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
                  'Les lots que vous validez apparaîtront ici',
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
                      const PendingLotsScreen(),
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
          _filteredActivities.map((activity) {
            final bool isApproved = activity['status'] == true;
            final IconData icon =
                isApproved ? Icons.check_circle : Icons.cancel;
            final Color color =
                isApproved
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.error;
            final String status = isApproved ? 'Approuvé' : 'Refusé';
            final String date =
                activity['dateTest'] != null
                    ? DateFormat(
                      'dd/MM/yyyy',
                    ).format(DateTime.parse(activity['dateTest']))
                    : 'Date inconnue';
            final String title =
                activity['espece'] != null
                    ? (activity['espece'] is Map
                        ? activity['espece']['nom']
                        : activity['espece'].toString())
                    : 'Lot inconnu';

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
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Naviguer vers les détails du lot si un ID est disponible
                    if (activity['_id'] != null || activity['id'] != null) {
                      final lotId = activity['_id'] ?? activity['id'];
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
