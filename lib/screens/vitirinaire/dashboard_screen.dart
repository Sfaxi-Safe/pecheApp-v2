import 'package:flutter/material.dart';
import 'package:fish_marketplace/services/auth_service.dart';
import 'package:fish_marketplace/screens/login_screen.dart';
import 'package:fish_marketplace/services/database_helper.dart';
import 'package:fish_marketplace/screens/vitirinaire/pending_lots_screen.dart';

class VitirinaireScreen extends StatefulWidget {
  const VitirinaireScreen({Key? key}) : super(key: key);

  @override
  _VitirinaireScreenState createState() => _VitirinaireScreenState();
}

class _VitirinaireScreenState extends State<VitirinaireScreen> {
  String _userName = '';
  int _pendingLots = 0;
  int _approvedLots = 0;
  int _rejectedLots = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = '${user.prenom} ${user.nom}';
      });

      // Load statistics
      if (user.id != null) {
        final lots = await DatabaseHelper.instance.queryWhere(
          'marketplace_lots',
          'vitirinaire_id = ?',
          [user.id],
        );
        
        setState(() {
          _pendingLots = lots.where((lot) => lot['test'] == 0).length;
          _approvedLots = lots.where((lot) => lot['test'] == 1 && lot['status'] == 1).length;
          _rejectedLots = lots.where((lot) => lot['test'] == 1 && lot['status'] == 0).length;
        });
      }
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Vétérinaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous avez $_pendingLots lots en attente de validation',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Main actions
              _buildActionCard(
                context,
                icon: Icons.pending_actions,
                title: 'Lots en attente',
                description: 'Examiner et valider les lots de poissons',
                count: _pendingLots,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PendingLotsScreen()),
                  );
                },
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
                      icon: Icons.check_circle,
                      value: _approvedLots.toString(),
                      label: 'Approuvés',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.cancel,
                      value: _rejectedLots.toString(),
                      label: 'Refusés',
                      color: Colors.red,
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
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.red : Colors.grey,
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
            Icon(
              icon,
              size: 32,
              color: color,
            ),
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
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          // Sample data - in a real app, this would come from the database
          final activities = [
            {
              'title': 'Thon rouge',
              'status': 'Approuvé',
              'date': '23/04/2023',
              'icon': Icons.check_circle,
              'color': Colors.green,
            },
            {
              'title': 'Dorade',
              'status': 'Refusé',
              'date': '22/04/2023',
              'icon': Icons.cancel,
              'color': Colors.red,
            },
            {
              'title': 'Sardine',
              'status': 'Approuvé',
              'date': '21/04/2023',
              'icon': Icons.check_circle,
              'color': Colors.green,
            },
          ];

          if (index >= activities.length) return const SizedBox();

          final activity = activities[index];
          return ListTile(
            leading: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
            ),
            title: Text(activity['title'] as String),
            subtitle: Text(activity['date'] as String),
            trailing: Chip(
              label: Text(
                activity['status'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: activity['color'] as Color,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
          );
        },
      ),
    );
  }
}
