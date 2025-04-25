import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'auction_detail_screen.dart';
import 'package:intl/intl.dart';

class AvailableAuctionsScreen extends StatefulWidget {
  const AvailableAuctionsScreen({Key? key}) : super(key: key);

  @override
  _AvailableAuctionsScreenState createState() =>
      _AvailableAuctionsScreenState();
}

class _AvailableAuctionsScreenState extends State<AvailableAuctionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _auctionsStream;
  String? _errorMessage;
  String _sortBy = 'price_asc'; // Default sorting

  @override
  void initState() {
    super.initState();
    _initAuctionsStream();
  }

  Future<void> _initAuctionsStream() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Créer un stream pour les enchères disponibles
      _auctionsStream =
          _firestore
              .collection('lots')
              .where('prixinitial', isNull: false)
              .where('vendre', isEqualTo: false)
              .snapshots();

      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
  }

  List<QueryDocumentSnapshot> _sortAuctions(
    List<QueryDocumentSnapshot> auctions,
  ) {
    final sortedAuctions = List<QueryDocumentSnapshot>.from(auctions);

    switch (_sortBy) {
      case 'price_asc':
        sortedAuctions.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final priceA =
              double.tryParse(
                aData['current'] ?? aData['prixinitial'] ?? '0',
              ) ??
              0;
          final priceB =
              double.tryParse(
                bData['current'] ?? bData['prixinitial'] ?? '0',
              ) ??
              0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_desc':
        sortedAuctions.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final priceA =
              double.tryParse(
                aData['current'] ?? aData['prixinitial'] ?? '0',
              ) ??
              0;
          final priceB =
              double.tryParse(
                bData['current'] ?? bData['prixinitial'] ?? '0',
              ) ??
              0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'date_desc':
        sortedAuctions.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final dateA =
              aData['datesoumettre'] != null
                  ? DateTime.parse(aData['datesoumettre'])
                  : DateTime(1970);
          final dateB =
              bData['datesoumettre'] != null
                  ? DateTime.parse(bData['datesoumettre'])
                  : DateTime(1970);
          return dateB.compareTo(dateA);
        });
        break;
      case 'date_asc':
        sortedAuctions.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final dateA =
              aData['datesoumettre'] != null
                  ? DateTime.parse(aData['datesoumettre'])
                  : DateTime(1970);
          final dateB =
              bData['datesoumettre'] != null
                  ? DateTime.parse(bData['datesoumettre'])
                  : DateTime(1970);
          return dateA.compareTo(dateB);
        });
        break;
    }

    return sortedAuctions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enchères disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initAuctionsStream,
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Trier',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder:
                (context) => [
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
                        onPressed: _initAuctionsStream,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : _auctionsStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                  stream: _auctionsStream,
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

                    final auctions = snapshot.data?.docs ?? [];

                    if (auctions.isEmpty) {
                      return Center(
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
                              style: TextStyle(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Trier les enchères
                    final sortedAuctions = _sortAuctions(auctions);

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedAuctions.length,
                      itemBuilder: (context, index) {
                        final auction =
                            sortedAuctions[index].data()
                                as Map<String, dynamic>;
                        // Ajouter l'ID du document à l'enchère
                        auction['id'] = sortedAuctions[index].id;
                        return _buildAuctionCard(context, auction);
                      },
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildAuctionCard(BuildContext context, Map<String, dynamic> auction) {
    final espece = auction['espece'] ?? 'Inconnu';
    final currentPrice = auction['current'] ?? auction['prixinitial'] ?? 'N/A';
    final devise = auction['devise'] ?? 'TND'; // Utiliser TND par défaut
    final photoUrl = auction['photo'];

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
                        Row(
                          children: [
                            const Icon(
                              Icons.price_change,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Prix actuel: $currentPrice $devise',
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
                          style: TextStyle(color: Colors.grey[600]),
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
