import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peche_app/services/database_helper.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/models/lot.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _lots = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLots();
  }

  Future<void> _loadLots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isPecheur()) {
        throw Exception('Utilisateur non autorisé');
      }

      if (user.id != null) {
        _lots = await DatabaseHelper.instance.getLotsByPecheurId(user.id!);
      } else {
        _lots = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des captures'),
      ),
      body: SafeArea(
        child: _isLoading
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
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadLots,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _lots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sailing_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune capture enregistrée',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scannez votre premier poisson pour commencer',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _lots.length,
                        itemBuilder: (context, index) {
                          final lot = _lots[index];
                          return _buildLotCard(context, lot);
                        },
                      ),
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, Map<String, dynamic> lot) {
    final espece = lot['espece'] ?? 'Inconnu';
    final date = lot['datetest'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(lot['datetest']))
        : 'Date inconnue';
    final status = lot['test'] == 1
        ? (lot['status'] == 1 ? 'Validé' : 'Refusé')
        : 'En attente';
    final statusColor = lot['test'] == 1
        ? (lot['status'] == 1 ? Colors.green : Colors.red)
        : Colors.orange;
    final photoPath = lot['photo'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: photoPath != null && File(photoPath).existsSync()
                    ? Image.file(
                        File(photoPath),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      ),
              ),
              
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              espece,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Chip(
                            label: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: statusColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: $date',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantité: ${lot['quantite'] ?? 'N/A'} | Poids: ${lot['poid'] ?? 'N/A'} kg',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // View details action
                    _showLotDetails(context, lot);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Détails'),
                ),
                if (lot['test'] == 0) ...[
                  TextButton.icon(
                    onPressed: () {
                      // Edit action
                      // In a real app, navigate to edit screen
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Delete action
                      _confirmDelete(context, lot);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLotDetails(BuildContext context, Map<String, dynamic> lot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - ${lot['espece'] ?? 'Inconnu'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lot['photo'] != null && File(lot['photo']).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(lot['photo']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailItem('Identifiant', lot['identifiant'] ?? 'N/A'),
              _buildDetailItem('Espèce', lot['espece'] ?? 'N/A'),
              _buildDetailItem('Quantité', lot['quantite'] ?? 'N/A'),
              _buildDetailItem('Poids', '${lot['poid'] ?? 'N/A'} kg'),
              _buildDetailItem('Température', '${lot['temperature'] ?? 'N/A'} °C'),
              _buildDetailItem('Date de soumission', lot['datesoumettre'] ?? 'N/A'),
              _buildDetailItem('Statut', lot['test'] == 1
                  ? (lot['status'] == 1 ? 'Validé' : 'Refusé')
                  : 'En attente'),
              if (lot['test'] == 1 && lot['status'] == 0) ...[
                const SizedBox(height: 16),
                const Text(
                  'Motif de refus:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Le poisson ne répond pas aux critères de qualité requis.',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> lot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette capture ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Delete the lot
              try {
                await DatabaseHelper.instance.delete(
                  'marketplace_lots',
                  'id = ?',
                  [lot['id']],
                );
                
                // Refresh the list
                _loadLots();
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Capture supprimée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la suppression: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
