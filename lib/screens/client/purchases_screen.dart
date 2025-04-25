import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'auction_detail_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({Key? key}) : super(key: key);

  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot>? _purchasesStream;
  String? _errorMessage;
  String _sortBy = 'date_desc'; // Default sorting

  @override
  void initState() {
    super.initState();
    _initPurchasesStream();
  }

  Future<void> _initPurchasesStream() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Créer un stream pour les achats de l'utilisateur
      _purchasesStream =
          _firestore
              .collection('lots')
              .where('user_id', isEqualTo: user.id)
              .where('vendre', isEqualTo: true)
              .snapshots();

      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
  }

  List<QueryDocumentSnapshot> _sortPurchases(
    List<QueryDocumentSnapshot> purchases,
  ) {
    final sortedPurchases = List<QueryDocumentSnapshot>.from(purchases);

    switch (_sortBy) {
      case 'price_asc':
        sortedPurchases.sort((a, b) {
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
        sortedPurchases.sort((a, b) {
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
        sortedPurchases.sort((a, b) {
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
        sortedPurchases.sort((a, b) {
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

    return sortedPurchases;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes achats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initPurchasesStream,
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
                        onPressed: _initPurchasesStream,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : _purchasesStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                  stream: _purchasesStream,
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

                    final purchases = snapshot.data?.docs ?? [];

                    if (purchases.isEmpty) {
                      return Center(
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
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vous n\'avez pas encore effectué d\'achat',
                              style: TextStyle(color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Trier les achats
                    final sortedPurchases = _sortPurchases(purchases);

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase =
                            sortedPurchases[index].data()
                                as Map<String, dynamic>;
                        // Ajouter l'ID du document à l'achat
                        purchase['id'] = sortedPurchases[index].id;
                        return _buildPurchaseCard(context, purchase);
                      },
                    );
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
    final price = purchase['current'] ?? purchase['prixinitial'] ?? 'N/A';
    final devise = purchase['devise'] ?? 'TND'; // Utiliser TND par défaut
    final photoUrl = purchase['photo'];
    final date =
        purchase['datesoumettre'] != null
            ? DateFormat(
              'dd/MM/yyyy',
            ).format(DateTime.parse(purchase['datesoumettre']))
            : 'Date inconnue';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuctionDetailScreen(auctionId: purchase['id']),
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
                              Icons.price_check,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Prix d\'achat: $price $devise',
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
          ],
        ),
      ),
    );
  }
}
