import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';
import 'pending_lots_screen.dart';
import 'active_auctions_screen.dart';

class MaryeurDashboardScreen extends StatefulWidget {
  const MaryeurDashboardScreen({Key? key}) : super(key: key);

  @override
  _MaryeurDashboardScreenState createState() => _MaryeurDashboardScreenState();
}

class _MaryeurDashboardScreenState extends State<MaryeurDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = '';
  int _pendingLots = 0;
  int _activeAuctions = 0;
  int _completedAuctions = 0;
  bool _isLoading = true;
  String? _errorMessage;

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
      if (user != null) {
        setState(() {
          _userName = '${user.prenom} ${user.nom}';
        });

        // Load statistics
        if (user.id != null) {
          // Lots en attente de prix initial
          final pendingLotsQuery =
              await _firestore
                  .collection('lots')
                  .where('test', isEqualTo: true)
                  .where('status', isEqualTo: true)
                  .where('prixinitial', isNull: true)
                  .get();

          // Enchères actives
          final activeAuctionsQuery =
              await _firestore
                  .collection('lots')
                  .where('maryeur_id', isEqualTo: user.id)
                  .where('prixinitial', isNull: false)
                  .where('vendre', isEqualTo: false)
                  .get();

          // Enchères complétées
          final completedAuctionsQuery =
              await _firestore
                  .collection('lots')
                  .where('maryeur_id', isEqualTo: user.id)
                  .where('vendre', isEqualTo: true)
                  .get();

          setState(() {
            _pendingLots = pendingLotsQuery.docs.length;
            _activeAuctions = activeAuctionsQuery.docs.length;
            _completedAuctions = completedAuctionsQuery.docs.length;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Maryeur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Actualiser',
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
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenue, $_userName',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vous avez $_pendingLots lots en attente de prix initial',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Main actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.pending_actions,
                              title: 'Lots en attente',
                              description: 'Définir les prix initiaux',
                              count: _pendingLots,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const PendingLotsMaryeurScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              context,
                              icon: Icons.gavel,
                              title: 'Enchères actives',
                              description: 'Suivre les enchères en cours',
                              count: _activeAuctions,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const ActiveAuctionsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Statistics
                      Text(
                        'Statistiques',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              icon: Icons.pending_actions,
                              value: _pendingLots.toString(),
                              label: 'En attente',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              icon: Icons.gavel,
                              value: _activeAuctions.toString(),
                              label: 'Enchères actives',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              icon: Icons.check_circle,
                              value: _completedAuctions.toString(),
                              label: 'Complétées',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent activity
                      Text(
                        'Activité récente',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivityList(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (count > 0)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('lots')
              .where('maryeur_id', isNull: false)
              .orderBy('dateEnchere', descending: true)
              .limit(3)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erreur lors du chargement des activités récentes',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final activities = snapshot.data?.docs ?? [];

        if (activities.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Aucune activité récente',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          );
        }

        return Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final activity = activities[index].data() as Map<String, dynamic>;

              IconData icon;
              Color color;
              String status;

              if (activity['vendre'] == true) {
                icon = Icons.check_circle;
                color = Colors.green;
                status = 'Vendu';
              } else if (activity['prixinitial'] != null) {
                icon = Icons.gavel;
                color = Colors.blue;
                status = 'En enchère';
              } else {
                icon = Icons.price_check;
                color = Colors.orange;
                status = 'Prix défini';
              }

              return ListTile(
                leading: Icon(icon, color: color),
                title: Text(activity['espece'] ?? 'Inconnu'),
                subtitle: Text(activity['dateEnchere'] ?? 'Date inconnue'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${activity['prixinitial'] ?? 'N/A'} ${activity['devise'] ?? 'TND'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(status, style: TextStyle(color: color, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
