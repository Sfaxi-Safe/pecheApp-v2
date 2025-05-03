import 'package:flutter/material.dart';
import 'package:seatrace/utils/color_extensions.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/screens/login_screen.dart';
import 'package:seatrace/screens/pecheur/scan_fish_screen.dart';
import 'package:seatrace/screens/pecheur/history_screen.dart';
import 'package:seatrace/screens/profile_screen.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/sea_widgets.dart';

class PecheurDashboardScreen extends StatefulWidget {
  const PecheurDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PecheurDashboardScreen> createState() => _PecheurDashboardScreenState();
}

class _PecheurDashboardScreenState extends State<PecheurDashboardScreen> {
  String _userName = '';
  String _userPhoto = '';
  String _userTelephone = '';
  String _userBateau = '';
  String _userPort = '';
  String _userMatricule = '';
  int _totalCaptures = 0;
  int _pendingValidation = 0;
  int _validated = 0;
  int _rejected = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _recentCaptures = [];

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

      // Charger les détails du pêcheur
      final userData = await ApiService.instance.getPecheurDetails(user.id);

      setState(() {
        _userName = '${userData['prenom']} ${userData['nom']}';
        _userPhoto = userData['photo'] ?? '';
        _userTelephone = userData['telephone'] ?? '';
        _userBateau = userData['bateau'] ?? '';
        _userPort = userData['port'] ?? '';
        _userMatricule = userData['matricule'] ?? '';
      });

      // Charger les statistiques
      final stats = await ApiService.instance.getPecheurStats(user.id);

      setState(() {
        _totalCaptures = stats['totalCaptures'] ?? 0;
        _pendingValidation = stats['pendingValidation'] ?? 0;
        _validated = stats['validated'] ?? 0;
        _rejected = stats['rejected'] ?? 0;
        _isLoading = false;
      });

      // Charger les captures récentes
      _loadRecentCaptures(user.id);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentCaptures(String userId) async {
    try {
      final response = await ApiService.instance.getLotsByPecheurId(userId);

      // Trier par date (plus récent en premier) et prendre les 3 premiers
      final sortedLots = List<Map<String, dynamic>>.from(response)
        ..sort((a, b) {
          final dateA =
              a['datetest'] != null
                  ? DateTime.parse(a['datetest'])
                  : DateTime(1900);
          final dateB =
              b['datetest'] != null
                  ? DateTime.parse(b['datetest'])
                  : DateTime(1900);
          return dateB.compareTo(dateA);
        });

      setState(() {
        _recentCaptures = sortedLots.take(3).toList();
      });
    } catch (e) {
      // Gérer l'erreur silencieusement
      ErrorHandler.instance.logError(
        e,
        context: 'PecheurDashboardScreen._loadRecentCaptures',
      );
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
      initials += nameParts[0][0].toUpperCase();
    }

    if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
      initials += nameParts[1][0].toUpperCase();
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
        title: const Text('Tableau de bord Pêcheur'),
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

                        // Actions rapides
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Actions rapides',
                          icon: Icons.bolt,
                        ),
                        _buildQuickActions(isPhone),

                        // Statistiques
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Statistiques',
                          icon: Icons.bar_chart,
                        ),
                        _buildStatisticsRow(),

                        // Captures récentes
                        const SizedBox(height: 24),
                        SeaSectionHeader(
                          title: 'Captures récentes',
                          icon: Icons.history,
                          actionText: 'Voir tout',
                          onActionPressed: () {
                            _navigationService.navigateToWithSlideLeft(
                              context,
                              const HistoryScreen(),
                            );
                          },
                        ),
                        _buildRecentCapturesList(),
                      ]),
                    ),
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _navigationService.navigateToWithSlideUp(
            context,
            const ScanFishScreen(),
          );
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scanner'),
        backgroundColor: primaryColor,
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
                    if (_userMatricule.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.badge,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Matricule: $_userMatricule',
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

          // Informations du bateau et port
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_userBateau.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.directions_boat,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Bateau: $_userBateau',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    if (_userPort.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.anchor, size: 16, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            'Port: $_userPort',
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
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isPhone) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    if (isPhone) {
      return Column(
        children: [
          _buildActionCard(
            icon: Icons.camera_alt,
            title: 'Scanner un poisson',
            description: 'Identifier et enregistrer une nouvelle capture',
            color: primaryColor,
            onTap: () {
              _navigationService.navigateToWithSlideUp(
                context,
                const ScanFishScreen(),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            icon: Icons.history,
            title: 'Historique',
            description: 'Consulter vos captures précédentes',
            color: theme.colorScheme.secondary,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const HistoryScreen(),
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
              icon: Icons.camera_alt,
              title: 'Scanner un poisson',
              description: 'Identifier et enregistrer une nouvelle capture',
              color: primaryColor,
              onTap: () {
                _navigationService.navigateToWithSlideUp(
                  context,
                  const ScanFishScreen(),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              icon: Icons.history,
              title: 'Historique',
              description: 'Consulter vos captures précédentes',
              color: theme.colorScheme.secondary,
              onTap: () {
                _navigationService.navigateToWithSlideLeft(
                  context,
                  const HistoryScreen(),
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

  Widget _buildStatisticsRow() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SeaStatCard(
            label: 'Captures totales',
            value: _totalCaptures.toString(),
            icon: Icons.catching_pokemon,
            color: theme.primaryColor,
            onTap: () {
              _navigationService.navigateToWithSlideLeft(
                context,
                const HistoryScreen(),
              );
            },
          ),
          const SizedBox(width: 12),
          SeaStatCard(
            label: 'En attente',
            value: _pendingValidation.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          SeaStatCard(
            label: 'Validées',
            value: _validated.toString(),
            icon: Icons.check_circle,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          SeaStatCard(
            label: 'Refusées',
            value: _rejected.toString(),
            icon: Icons.cancel,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCapturesList() {
    final theme = Theme.of(context);

    if (_recentCaptures.isEmpty) {
      return _animationService.fadeIn(
        SeaCard(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.sailing_outlined,
                    size: 48,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune capture récente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scannez votre premier poisson pour commencer',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SeaButton.primary(
                    text: 'Scanner un poisson',
                    icon: Icons.camera_alt,
                    onPressed: () {
                      _navigationService.navigateToWithSlideUp(
                        context,
                        const ScanFishScreen(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children:
          _recentCaptures.map((capture) {
            final espece = capture['espece'] ?? 'Inconnu';
            final date =
                capture['datetest'] != null
                    ? DateTime.parse(
                      capture['datetest'],
                    ).toString().substring(0, 10)
                    : 'Date inconnue';
            final status =
                capture['test'] == 1
                    ? (capture['status'] == 1 ? 'Validé' : 'Refusé')
                    : 'En attente';

            IconData statusIcon;
            Color statusColor;

            switch (status) {
              case 'Validé':
                statusIcon = Icons.check_circle;
                statusColor = theme.colorScheme.secondary;
                break;
              case 'Refusé':
                statusIcon = Icons.cancel;
                statusColor = theme.colorScheme.error;
                break;
              default:
                statusIcon = Icons.pending_actions;
                statusColor = Colors.orange;
            }

            return _animationService.fadeIn(
              SeaCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  title: Text(
                    espece,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(date),
                      const SizedBox(width: 8),
                      Icon(Icons.scale, size: 12, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text('${capture['poid'] ?? 'N/A'} kg'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Naviguer vers les détails de la capture
                  },
                ),
              ),
            );
          }).toList(),
    );
  }
}
