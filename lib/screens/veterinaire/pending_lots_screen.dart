import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/utils/error_handler.dart';
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
      // Vérifier l'utilisateur
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Ajouter un log pour le débogage
      ErrorHandler.instance.logInfo(
        'Chargement des lots en attente pour l\'utilisateur: ${user.id}',
        context: 'PendingLotsScreen',
      );

      // Vérifier si le token est présent
      ErrorHandler.instance.logInfo(
        'Token d\'authentification présent: ${ApiService.instance.hasToken()}',
        context: 'PendingLotsScreen',
      );

      try {
        // Utiliser un timeout plus long pour éviter les erreurs de timeout
        final response = await ApiService.instance.get('lots/pending');

        // Vérifier si la réponse contient des données
        if (response.containsKey('data')) {
          _pendingLots = List<Map<String, dynamic>>.from(response['data']);
          ErrorHandler.instance.logInfo(
            'Lots en attente chargés: ${_pendingLots.length}',
            context: 'PendingLotsScreen',
          );
        } else {
          ErrorHandler.instance.logWarning(
            'Réponse reçue sans données: $response',
            context: 'PendingLotsScreen',
          );
          _pendingLots = [];
        }
      } catch (e) {
        ErrorHandler.instance.logError(
          'Erreur API lors de la récupération des lots: $e',
          context: 'PendingLotsScreen',
        );

        // Si c'est une erreur 404, on considère qu'il n'y a pas de lots en attente
        if (e.toString().contains('notFound') || e.toString().contains('404')) {
          _pendingLots = [];
          setState(() {
            _isLoading = false;
          });
          return;
        }
        throw Exception('Erreur lors de la récupération des lots: $e');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ErrorHandler.instance.logError(
        'Erreur générale: $e',
        context: 'PendingLotsScreen',
      );
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveLot(String lotId) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Log l'action pour le débogage
      ErrorHandler.instance.logInfo(
        'Approbation du lot $lotId par l\'utilisateur ${user.id}',
        context: 'PendingLotsScreen',
      );

      // Utiliser la nouvelle route d'approbation
      await ApiService.instance.put('lots/$lotId/approve', {
        'temperature': 4.0, // Température par défaut
        'veterinaire': user.id,
      });

      // Actualiser la liste
      _loadPendingLots();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot approuvé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Log l'erreur pour le débogage
      ErrorHandler.instance.logError(
        'Erreur lors de l\'approbation du lot: $e',
        context: 'PendingLotsScreen',
      );

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
      if (user == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Log l'action pour le débogage
      ErrorHandler.instance.logInfo(
        'Rejet du lot $lotId par l\'utilisateur ${user.id}',
        context: 'PendingLotsScreen',
      );

      // Utiliser la nouvelle route de rejet
      await ApiService.instance.put('lots/$lotId/reject', {
        'temperature': 4.0, // Température par défaut
        'veterinaire': user.id,
      });

      // Actualiser la liste
      _loadPendingLots();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot refusé'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      // Log l'erreur pour le débogage
      ErrorHandler.instance.logError(
        'Erreur lors du rejet du lot: $e',
        context: 'PendingLotsScreen',
      );

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
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tous les lots ont été traités',
                        style: TextStyle(color: Colors.grey[500]),
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
    final date =
        lot['dateTest'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(lot['dateTest']))
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
                child:
                    photoPath != null && photoPath.isNotEmpty
                        ? Image.network(
                          ApiService.instance.getImageUrl(photoPath),
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
                        'Quantité: ${lot['quantite'] ?? 'N/A'} | Poids: ${lot['poids'] ?? 'N/A'} kg',
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
                    onPressed: () => _approveLot(lot['_id'] ?? lot['id']),
                    icon: const Icon(Icons.check),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectLot(lot['_id'] ?? lot['id']),
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
                  if (lot['photo'] != null && lot['photo'].isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ApiService.instance.getImageUrl(lot['photo']),
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
                  _buildDetailItem(
                    'Quantité',
                    lot['quantite']?.toString() ?? 'N/A',
                  ),
                  _buildDetailItem('Poids', '${lot['poids'] ?? 'N/A'} kg'),
                  _buildDetailItem(
                    'Température',
                    '${lot['temperature'] ?? 'N/A'} °C',
                  ),
                  _buildDetailItem(
                    'Date de soumission',
                    lot['dateSoumission'] ?? 'N/A',
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
                            _approveLot(lot['_id'] ?? lot['id']);
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
                            _rejectLot(lot['_id'] ?? lot['id']);
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
