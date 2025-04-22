import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fish_marketplace/services/database_helper.dart';
import 'package:fish_marketplace/services/auth_service.dart';
import 'package:intl/intl.dart';

class PendingLotsMaryeurScreen extends StatefulWidget {
  const PendingLotsMaryeurScreen({Key? key}) : super(key: key);

  @override
  _PendingLotsMaryeurScreenState createState() => _PendingLotsMaryeurScreenState();
}

class _PendingLotsMaryeurScreenState extends State<PendingLotsMaryeurScreen> {
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
      if (user == null || !user.isMaryeur()) {
        throw Exception('Utilisateur non autorisé');
      }

      if (user.id != null) {
        // Get lots that have been approved by veterinarian but don't have initial price
        _pendingLots = await DatabaseHelper.instance.queryWhere(
          'marketplace_lots',
          'test = 1 AND status = 1 AND prixinitial IS NULL',
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

  Future<void> _setPrices(int lotId, String initialPrice, String minPrice) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isMaryeur() || user.id == null) {
        throw Exception('Utilisateur non autorisé');
      }

      await DatabaseHelper.instance.update(
        'marketplace_lots',
        {
          'prixinitial': initialPrice,
          'prixminimal': minPrice,
          'typeenchere': 'standard',
          'current': initialPrice,
          'online': '1',
        },
        'id = ?',
        [lotId],
      );

      // Refresh the list
      _loadPendingLots();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prix définis avec succès'),
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

  void _showSetPriceDialog(BuildContext context, Map<String, dynamic> lot) {
    final initialPriceController = TextEditingController();
    final minPriceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Définir les prix - ${lot['espece'] ?? 'Inconnu'}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: initialPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix initial (€)',
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix initial';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: minPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix minimal (€)',
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix minimal';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (double.parse(value) > double.parse(initialPriceController.text)) {
                    return 'Le prix minimal doit être inférieur au prix initial';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                _setPrices(
                  lot['id'],
                  initialPriceController.text,
                  minPriceController.text,
                );
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lots en attente de prix'),
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
                              'Tous les lots ont des prix définis',
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
                    onPressed: () => _showSetPriceDialog(context, lot),
                    icon: const Icon(Icons.price_change),
                    label: const Text('Définir prix'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
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
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSetPriceDialog(context, lot);
                },
                icon: const Icon(Icons.price_change),
                label: const Text('Définir les prix'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
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
          
dart file="lib/screens/maryeur/active_auctions_screen.dart"
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fish_marketplace/services/database_helper.dart';
import 'package:fish_marketplace/services/auth_service.dart';
import 'package:intl/intl.dart';

class ActiveAuctionsScreen extends StatefulWidget {
  const ActiveAuctionsScreen({Key? key}) : super(key: key);

  @override
  _ActiveAuctionsScreenState createState() => _ActiveAuctionsScreenState();
}

class _ActiveAuctionsScreenState extends State<ActiveAuctionsScreen> {
  List<Map<String, dynamic>> _activeAuctions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActiveAuctions();
  }

  Future<void> _loadActiveAuctions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isMaryeur()) {
        throw Exception('Utilisateur non autorisé');
      }

      // Get lots that have initial price set and are not sold yet
      _activeAuctions = await DatabaseHelper.instance.queryWhere(
        'marketplace_lots',
        'prixinitial IS NOT NULL AND vendre = 0',
        [],
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
        title: const Text('Enchères actives'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveAuctions,
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
                          onPressed: _loadActiveAuctions,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _activeAuctions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.gavel_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune enchère active',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Définissez des prix pour les lots en attente',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _activeAuctions.length,
                        itemBuilder: (context, index) {
                          final auction = _activeAuctions[index];
                          return _buildAuctionCard(context, auction);
                        },
                      ),
      ),
    );
  }

  Widget _buildAuctionCard(BuildContext context, Map<String, dynamic> auction) {
    final espece = auction['espece'] ?? 'Inconnu';
    final currentPrice = auction['current'] ?? auction['prixinitial'] ?? 'N/A';
    final initialPrice = auction['prixinitial'] ?? 'N/A';
    final minPrice = auction['prixminimal'] ?? 'N/A';
    final photoPath = auction['photo'];

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
                      Row(
                        children: [
                          const Icon(Icons.euro, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Prix actuel: $currentPrice €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prix initial: $initialPrice € | Prix minimal: $minPrice €',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantité: ${auction['quantite'] ?? 'N/A'} | Poids: ${auction['poid'] ?? 'N/A'} kg',
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
                      _showAuctionDetails(context, auction);
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Détails'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // View bids action
                      _showBidsHistory(context, auction);
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Historique'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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

  void _showAuctionDetails(BuildContext context, Map<String, dynamic> auction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - ${auction['espece'] ?? 'Inconnu'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (auction['photo'] != null && File(auction['photo']).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(auction['photo']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailItem('Identifiant', auction['identifiant'] ?? 'N/A'),
              _buildDetailItem('Espèce', auction['espece'] ?? 'N/A'),
              _buildDetailItem('Quantité', auction['quantite'] ?? 'N/A'),
              _buildDetailItem('Poids', '${auction['poid'] ?? 'N/A'} kg'),
              _buildDetailItem('Prix actuel', '${auction['current'] ?? auction['prixinitial'] ?? 'N/A'} €'),
              _buildDetailItem('Prix initial', '${auction['prixinitial'] ?? 'N/A'} €'),
              _buildDetailItem('Prix minimal', '${auction['prixminimal'] ?? 'N/A'} €'),
              _buildDetailItem('Type d\'enchère', auction['typeenchere'] ?? 'standard'),
              _buildDetailItem('Date de soumission', auction['datesoumettre'] ?? 'N/A'),
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

  void _showBidsHistory(BuildContext context, Map<String, dynamic> auction) {
    // In a real app, you would fetch the bid history from the database
    // For this example, we'll use sample data
    final bids = [
      {
        'user': 'Jean Dupont',
        'amount': '${double.parse(auction['current'] ?? auction['prixinitial']) - 5}',
        'time': '10:30',
      },
      {
        'user': 'Marie Martin',
        'amount': '${double.parse(auction['current'] ?? auction['prixinitial']) - 10}',
        'time': '10:15',
      },
      {
        'user': 'Pierre Durand',
        'amount': '${double.parse(auction['current'] ?? auction['prixinitial']) - 15}',
        'time': '10:00',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Historique des enchères - ${auction['espece'] ?? 'Inconnu'}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: bids.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final bid = bids[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(bid['user'] as String),
                subtitle: Text('à ${bid['time']}'),
                trailing: Text(
                  '${bid['amount']} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              );
            },
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
