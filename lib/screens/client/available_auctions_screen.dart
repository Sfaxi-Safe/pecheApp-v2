import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import 'auction_detail_screen.dart';

class AvailableAuctionsScreen extends StatefulWidget {
  const AvailableAuctionsScreen({Key? key}) : super(key: key);

  @override
  _AvailableAuctionsScreenState createState() => _AvailableAuctionsScreenState();
}

class _AvailableAuctionsScreenState extends State<AvailableAuctionsScreen> {
  List<Map<String, dynamic>> _availableAuctions = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _sortBy = 'price_asc'; // Default sorting

  @override
  void initState() {
    super.initState();
    _loadAvailableAuctions();
  }

  Future<void> _loadAvailableAuctions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get lots that have initial price set and are not sold yet
      _availableAuctions = await DatabaseHelper.instance.queryWhere(
        'marketplace_lots',
        'prixinitial IS NOT NULL AND vendre = ?',
        [0], // 0 means not sold yet
      );

      // Apply sorting
      _sortAuctions();

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

  void _sortAuctions() {
    switch (_sortBy) {
      case 'price_asc':
        _availableAuctions.sort((a, b) {
          final priceA = double.tryParse(a['current'] ?? a['prixinitial'] ?? '0') ?? 0;
          final priceB = double.tryParse(b['current'] ?? b['prixinitial'] ?? '0') ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        _availableAuctions.sort((a, b) {
          final priceA = double.tryParse(a['current'] ?? a['prixinitial'] ?? '0') ?? 0;
          final priceB = double.tryParse(b['current'] ?? b['prixinitial'] ?? '0') ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'date_desc':
        _availableAuctions.sort((a, b) {
          final dateA = a['datesoumettre'] != null ? DateTime.parse(a['datesoumettre']) : DateTime(1970);
          final dateB = b['datesoumettre'] != null ? DateTime.parse(b['datesoumettre']) : DateTime(1970);
          return dateB.compareTo(dateA);
        });
        break;
      case 'date_asc':
        _availableAuctions.sort((a, b) {
          final dateA = a['datesoumettre'] != null ? DateTime.parse(a['datesoumettre']) : DateTime(1970);
          final dateB = b['datesoumettre'] != null ? DateTime.parse(b['datesoumettre']) : DateTime(1970);
          return dateA.compareTo(dateB);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enchères disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAvailableAuctions,
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Trier',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _sortAuctions();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'price_asc',
                child: Text('Prix croissant'),
              ),
              const PopupMenuItem(
                value: 'price_desc',
                child: Text('Prix décroissant'),
              ),
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Plus récent'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Plus ancien'),
              ),
            ],
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
                          onPressed: _loadAvailableAuctions,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _availableAuctions.isEmpty
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
                              'Aucune enchère disponible',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Revenez plus tard pour voir les nouvelles enchères',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _availableAuctions.length,
                        itemBuilder: (context, index) {
                          final auction = _availableAuctions[index];
                          return _buildAuctionCard(context, auction);
                        },
                      ),
      ),
    );
  }

  Widget _buildAuctionCard(BuildContext context, Map<String, dynamic> auction) {
    final espece = auction['espece'] ?? 'Inconnu';
    final currentPrice = auction['current'] ?? auction['prixinitial'] ?? 'N/A';
    final photoPath = auction['photo'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuctionDetailScreen(auctionId: auction['id']),
            ),
          );
        },
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
          ],
        ),
      ),
    );
  }
}
