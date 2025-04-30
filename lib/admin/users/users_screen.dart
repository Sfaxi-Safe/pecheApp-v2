import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _pecheurs = [];
  List<Map<String, dynamic>> _maryeurs = [];
  List<Map<String, dynamic>> _vitirinaires = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final api = ApiService.instance;
      final clients = await api.getUsers('ROLE_CLIENT');
      final pecheurs = await api.getUsers('ROLE_PECHEUR');
      final maryeurs = await api.getUsers('ROLE_MARYEUR');
      final vitirinaires = await api.getUsers('ROLE_VITIRINAIRE');

      setState(() {
        _clients = clients;
        _pecheurs = pecheurs;
        _maryeurs = maryeurs;
        _vitirinaires = vitirinaires;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des utilisateurs: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, String type) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user['prenom']?.substring(0, 1).toUpperCase() ?? '?'),
            ),
            title: Text('${user['prenom'] ?? ''} ${user['nom'] ?? ''}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? ''),
                Text('Téléphone: ${user['telephone'] ?? 'Non renseigné'}'),
                if (type == 'Pêcheur')
                  Text('Matricule: ${user['matricule'] ?? 'Non renseigné'}'),
                if (type == 'Pêcheur')
                  Text('Port: ${user['port'] ?? 'Non renseigné'}'),
              ],
            ),
            trailing: Icon(
              user['is_valid'] == 1 ? Icons.check_circle : Icons.warning,
              color: user['is_valid'] == 1 ? Colors.green : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clients'),
            Tab(text: 'Pêcheurs'),
            Tab(text: 'Mareyeurs'),
            Tab(text: 'Vétérinaires'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildUserList(_clients, 'Client'),
                  _buildUserList(_pecheurs, 'Pêcheur'),
                  _buildUserList(_maryeurs, 'Mareyeur'),
                  _buildUserList(_vitirinaires, 'Vétérinaire'),
                ],
              ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
