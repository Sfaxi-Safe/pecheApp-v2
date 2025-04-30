import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/image_service.dart';

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

      if (user.id != null) {
        try {
          final response = await ApiService.instance.get(
            'auctions/maryeur/${user.id}',
          );
          final lots = List<Map<String, dynamic>>.from(response['data']);

          setState(() {
            _activeAuctions =
                lots
                    .where(
                      (lot) =>
                          lot['prixInitial'] != null && lot['vendu'] == false,
                    )
                    .toList();
            _isLoading = false;
          });
        } catch (e) {
          throw Exception('Erreur lors de la récupération des enchères: $e');
        }
      } else {
        setState(() {
          _activeAuctions = [];
          _isLoading = false;
        });
      }
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
                      Icon(Icons.gavel, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune enchère active',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les enchères que vous avez initiées apparaîtront ici',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activeAuctions.length,
                  itemBuilder: (context, index) {
                    final auction = _activeAuctions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            height: 150,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child:
                                auction['photo'] != null &&
                                        auction['photo'].toString().isNotEmpty
                                    ? Image.network(
                                      ImageService.instance.getImageUrl(
                                        auction['photo'],
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[500],
                                          ),
                                        );
                                      },
                                    )
                                    : Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 50,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and price
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      auction['espece'] ?? 'Poisson',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${auction['prixinitial'] ?? '0'} TND',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Details
                                Row(
                                  children: [
                                    _buildDetailItem(
                                      Icons.scale,
                                      'Poids',
                                      '${auction['poid'] ?? '0'} kg',
                                    ),
                                    const SizedBox(width: 16),
                                    _buildDetailItem(
                                      Icons.inventory_2,
                                      'Quantité',
                                      auction['quantite'] ?? '0',
                                    ),
                                    const SizedBox(width: 16),
                                    _buildDetailItem(
                                      Icons.thermostat,
                                      'Temp.',
                                      '${auction['temperature'] ?? '0'}°C',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Current bid
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Enchère actuelle',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${auction['current'] ?? auction['prixinitial'] ?? '0'} TND',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Navigate to auction detail screen
                                        },
                                        child: const Text('Voir détails'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
