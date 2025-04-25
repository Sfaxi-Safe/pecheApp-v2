import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seatrace/services/database_helper.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:intl/intl.dart';

class PendingLotsScreen extends StatefulWidget {
  const PendingLotsScreen({Key? key}) : super(key: key);

  @override
  _PendingLotsScreenState createState() => _PendingLotsScreenState();
}

class _PendingLotsScreenState extends State<PendingLotsScreen> {
  List<Map<String, dynamic>> _pendingLots = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPendingLots();
  }

  Future<void> _loadPendingLots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isVeterinaire()) {
        throw Exception('Utilisateur non autorisé');
      }

      if (user.id != null) {
        _pendingLots = await DatabaseHelper.instance.queryWhere(
          'marketplace_lots',
          'test = 0',
          [],
        );
      } else {
        _pendingLots = [];
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

  Future<void> _approveLot(int lotId) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isVeterinaire() || user.id == null) {
        throw Exception('Utilisateur non autorisé');
      }

      await DatabaseHelper.instance.update(
        'marketplace_lots',
        {
          'test': 1,
          'status': 1,
          'vitirinaire_id': user.id,
        },
        'id = ?',
        [lotId],
      );

      // Refresh the list
      _loadPendingLots();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot approuvé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectLot(int lotId) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isVeterinaire() || user.id == null) {
        throw Exception('Utilisateur non autorisé');
      }

      await DatabaseHelper.instance.update(
        'marketplace_lots',
        {
          'test': 1,
          'status': 0,
          'vitirinaire_id': user.id,
        },
        'id = ?',
        [lotId],
      );

      // Refresh the list
      _loadPendingLots();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot refusé'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lots en attente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingLots,
            tooltip: 'Actualiser',
          ),
        ],
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
                          onPressed: _loadPendingLots,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _pendingLots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun lot en attente',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tous les lots ont été traités',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingLots.length,
                        itemBuilder: (context, index) {
                          final lot = _pendingLots[index];
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
                      Text(
                        espece,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 4),
                      Text(
                        'Température: ${lot['temperature'] ?? 'N/A'} °C',
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
          
          // Divider
          const Divider(),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      // View details action
                      _showLotDetails(context, lot);
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Détails'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveLot(lot['id']),
                    icon: const Icon(Icons.check),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectLot(lot['id']),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Refuser', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
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
              
              const SizedBox(height: 16),
              const Text(
                'Décision:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _approveLot(lot['id']);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approuver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _rejectLot(lot['id']);
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Refuser', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
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
}
