import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/firestore_service.dart';
import 'package:intl/intl.dart';

class PendingLotsScreen extends StatefulWidget {
  const PendingLotsScreen({Key? key}) : super(key: key);

  @override
  _PendingLotsScreenState createState() => _PendingLotsScreenState();
}

class _PendingLotsScreenState extends State<PendingLotsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  Stream<QuerySnapshot>? _lotsStream;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLotsStream();
  }

  Future<void> _initLotsStream() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isVeterinaire()) {
        throw Exception('Utilisateur non autorisé');
      }

      // Créer un stream pour les lots en attente de validation
      _lotsStream =
          _firestore
              .collection('lots')
              .where('test', isEqualTo: false)
              .snapshots();

      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
  }

  Future<void> _approveLot(String lotId) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isVeterinaire() || user.id == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Mettre à jour le lot dans Firestore
      await _firestore.collection('lots').doc(lotId).update({
        'test': true,
        'status': true,
        'vitirinaire_id': user.id,
        'dateValidation': DateTime.now().toIso8601String(),
      });

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

  Future<void> _rejectLot(String lotId) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isVeterinaire() || user.id == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Mettre à jour le lot dans Firestore
      await _firestore.collection('lots').doc(lotId).update({
        'test': true,
        'status': false,
        'vitirinaire_id': user.id,
        'dateValidation': DateTime.now().toIso8601String(),
      });

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
            onPressed: _initLotsStream,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SafeArea(
        child:
            _errorMessage != null
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
                        onPressed: _initLotsStream,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : _lotsStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                  stream: _lotsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erreur: ${snapshot.error}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lots = snapshot.data?.docs ?? [];

                    if (lots.isEmpty) {
                      return Center(
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
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lots.length,
                      itemBuilder: (context, index) {
                        final lot = lots[index].data() as Map<String, dynamic>;
                        // Ajouter l'ID du document au lot
                        lot['id'] = lots[index].id;
                        return _buildLotCard(context, lot);
                      },
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, Map<String, dynamic> lot) {
    final espece = lot['espece'] ?? 'Inconnu';
    final date =
        lot['datetest'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(lot['datetest']))
            : 'Date inconnue';
    final photoUrl = lot['photo'];

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
                child:
                    photoUrl != null
                        ? Image.network(
                          photoUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey[500],
                              ),
                            );
                          },
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
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantité: ${lot['quantite'] ?? 'N/A'} | Poids: ${lot['poid'] ?? 'N/A'} kg',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Température: ${lot['temperature'] ?? 'N/A'} °C',
                        style: TextStyle(color: Colors.grey[600]),
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
                    label: const Text(
                      'Refuser',
                      style: TextStyle(color: Colors.red),
                    ),
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
      builder:
          (context) => AlertDialog(
            title: Text('Détails - ${lot['espece'] ?? 'Inconnu'}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lot['photo'] != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        lot['photo'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailItem('Identifiant', lot['identifiant'] ?? 'N/A'),
                  _buildDetailItem('Espèce', lot['espece'] ?? 'N/A'),
                  _buildDetailItem('Quantité', lot['quantite'] ?? 'N/A'),
                  _buildDetailItem('Poids', '${lot['poid'] ?? 'N/A'} kg'),
                  _buildDetailItem(
                    'Température',
                    '${lot['temperature'] ?? 'N/A'} °C',
                  ),
                  _buildDetailItem(
                    'Date de soumission',
                    lot['datesoumettre'] ?? 'N/A',
                  ),

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
                          label: const Text(
                            'Refuser',
                            style: TextStyle(color: Colors.red),
                          ),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
