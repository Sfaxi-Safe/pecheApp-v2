import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class MyPurchasesScreen extends StatefulWidget {
  const MyPurchasesScreen({Key? key}) : super(key: key);

  @override
  _MyPurchasesScreenState createState() => _MyPurchasesScreenState();
}

class _MyPurchasesScreenState extends State<MyPurchasesScreen> {
  List<Map<String, dynamic>> _myPurchases = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyPurchases();
  }

  Future<void> _loadMyPurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Get lots that have been purchased by the current user
      _myPurchases = await DatabaseHelper.instance.queryWhere(
        'marketplace_lots',
        'user_id = ? AND vendre = ?',
        [user.id, 1], // 1 means sold
      );

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
        title: const Text('Mes achats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMyPurchases,
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
                        onPressed: _loadMyPurchases,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : _myPurchases.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun achat',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Participez aux enchères pour acheter des poissons',
                        style: TextStyle(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myPurchases.length,
                  itemBuilder: (context, index) {
                    final purchase = _myPurchases[index];
                    return _buildPurchaseCard(context, purchase);
                  },
                ),
      ),
    );
  }

  Widget _buildPurchaseCard(
    BuildContext context,
    Map<String, dynamic> purchase,
  ) {
    final espece = purchase['espece'] ?? 'Inconnu';
    final finalPrice =
        purchase['prixfinale'] ??
        purchase['current'] ??
        purchase['prixinitial'] ??
        'N/A';
    final date =
        purchase['datesoumettre'] != null
            ? DateFormat(
              'dd/MM/yyyy',
            ).format(DateTime.parse(purchase['datesoumettre']))
            : 'Date inconnue';
    final photoPath = purchase['photo'];

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
                    photoPath != null && File(photoPath).existsSync()
                        ? Image.file(
                          File(photoPath),
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
                      Row(
                        children: [
                          const Icon(
                            Icons.price_change,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Prix payé: $finalPrice TND',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date d\'achat: $date',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantité: ${purchase['quantite'] ?? 'N/A'} | Poids: ${purchase['poid'] ?? 'N/A'} kg',
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // View details action
                    _showPurchaseDetails(context, purchase);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Détails'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDetails(
    BuildContext context,
    Map<String, dynamic> purchase,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Détails - ${purchase['espece'] ?? 'Inconnu'}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (purchase['photo'] != null &&
                      File(purchase['photo']).existsSync()) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(purchase['photo']),
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
                              size: 50,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailItem(
                    'Identifiant',
                    purchase['identifiant'] ?? 'N/A',
                  ),
                  _buildDetailItem('Espèce', purchase['espece'] ?? 'N/A'),
                  _buildDetailItem('Quantité', purchase['quantite'] ?? 'N/A'),
                  _buildDetailItem('Poids', '${purchase['poid'] ?? 'N/A'} kg'),
                  _buildDetailItem(
                    'Prix payé',
                    '${purchase['prixfinale'] ?? purchase['current'] ?? purchase['prixinitial'] ?? 'N/A'} TND',
                  ),
                  _buildDetailItem(
                    'Prix initial',
                    '${purchase['prixinitial'] ?? 'N/A'} TND',
                  ),
                  if (purchase['datesoumettre'] != null)
                    _buildDetailItem(
                      'Date d\'achat',
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(purchase['datesoumettre'])),
                    ),

                  const SizedBox(height: 16),
                  const Text(
                    'Statut de la livraison:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'En cours de préparation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Informations de livraison:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Votre commande sera livrée dans les 24 heures. Le paiement se fera en espèces à la livraison.',
                    style: TextStyle(color: Colors.grey),
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
