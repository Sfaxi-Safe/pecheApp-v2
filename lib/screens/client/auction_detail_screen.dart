import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/firestore_service.dart';
import 'package:intl/intl.dart';

class AuctionDetailScreen extends StatefulWidget {
  final String auctionId;

  const AuctionDetailScreen({Key? key, required this.auctionId})
      : super(key: key);

  @override
  _AuctionDetailScreenState createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  Stream<DocumentSnapshot>? _auctionStream;
  Map<String, dynamic>? _pecheur;
  Map<String, dynamic>? _veterinaire;
  Map<String, dynamic>? _maryeur;
  Map<String, dynamic>? _prise;
  String? _errorMessage;
  final _bidController = TextEditingController();
  bool _isPlacingBid = false;

  @override
  void initState() {
    super.initState();
    _initAuctionStream();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _initAuctionStream() async {
    try {
      // Créer un stream pour l'enchère
      _auctionStream = _firestore
          .collection('lots')
          .doc(widget.auctionId)
          .snapshots();

      // Charger les données associées (pêcheur, vétérinaire, etc.)
      await _loadRelatedData();

      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
      });
    }
  }

  Future<void> _loadRelatedData() async {
    try {
      // Charger les détails de l'enchère une fois pour obtenir les IDs
      final auctionDoc = await _firestore
          .collection('lots')
          .doc(widget.auctionId)
          .get();
      
      if (!auctionDoc.exists) {
        throw Exception('Enchère non trouvée');
      }

      final auction = auctionDoc.data() as Map<String, dynamic>;
      
      // Charger les détails de la prise
      if (auction['prise_id'] != null) {
        final priseDoc = await _firestore
            .collection('prises')
            .doc(auction['prise_id'])
            .get();
        
        if (priseDoc.exists) {
          final priseData = priseDoc.data() as Map<String, dynamic>;
          
          // Ajouter l'ID au document
          priseData['id'] = priseDoc.id;
          
          setState(() {
            _prise = priseData;
          });
          
          // Charger les détails du pêcheur
          if (priseData['pecheur_id'] != null) {
            final pecheurDoc = await _firestore
                .collection('pecheurs')
                .doc(priseData['pecheur_id'])
                .get();
            
            if (pecheurDoc.exists) {
              final pecheurData = pecheurDoc.data() as Map<String, dynamic>;
              
              // Ajouter l'ID au document
              pecheurData['id'] = pecheurDoc.id;
              
              setState(() {
                _pecheur = pecheurData;
              });
            }
          }
        }
      }
      
      // Charger les détails du vétérinaire
      if (auction['vitirinaire_id'] != null) {
        final veterinaireDoc = await _firestore
            .collection('vitirinaires')
            .doc(auction['vitirinaire_id'])
            .get();
        
        if (veterinaireDoc.exists) {
          final veterinaireData = veterinaireDoc.data() as Map<String, dynamic>;
          
          // Ajouter l'ID au document
          veterinaireData['id'] = veterinaireDoc.id;
          
          setState(() {
            _veterinaire = veterinaireData;
          });
        }
      }
      
      // Charger les détails du maryeur
      if (auction['maryeur_id'] != null) {
        final maryeurDoc = await _firestore
            .collection('maryeurs')
            .doc(auction['maryeur_id'])
            .get();
        
        if (maryeurDoc.exists) {
          final maryeurData = maryeurDoc.data() as Map<String, dynamic>;
          
          // Ajouter l'ID au document
          maryeurData['id'] = maryeurDoc.id;
          
          setState(() {
            _maryeur = maryeurData;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des données associées: ${e.toString()}');
    }
  }

  Future<void> _placeBid(Map<String, dynamic> auction) async {
    final bidAmount = double.tryParse(_bidController.text);
    if (bidAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentPrice =
        double.tryParse(
          auction['current'] ?? auction['prixinitial'] ?? '0',
        ) ??
        0;
    if (bidAmount <= currentPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre enchère doit être supérieure au prix actuel'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingBid = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Placer l'enchère avec Firestore
      await _firestoreService.placeBid(
        widget.auctionId,
        user.id!,
        bidAmount.toString(),
      );

      // Clear bid input
      _bidController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enchère placée avec succès'),
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
    } finally {
      setState(() {
        _isPlacingBid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'enchère'),
      ),
      body: SafeArea(
        child: _errorMessage != null
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
                      onPressed: _initAuctionStream,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            : _auctionStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<DocumentSnapshot>(
                    stream: _auctionStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erreur: ${snapshot.error}',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text('Aucune information disponible'));
                      }

                      final auction = snapshot.data!.data() as Map<String, dynamic>;
                      
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            if (auction['photo'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  auction['photo'],
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 80,
                                        color: Colors.grey[500],
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey[500],
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Title and current price
                            Text(
                              auction['espece'] ?? 'Inconnu',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.price_change, size: 20, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'Prix actuel: ${auction['current'] ?? auction['prixinitial'] ?? 'N/A'} ${auction['devise'] ?? 'TND'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Details
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Détails du lot',
                                      style: Theme.of(context).textTheme.titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailItem(
                                      'Identifiant',
                                      auction['identifiant'] ?? 'N/A',
                                    ),
                                    _buildDetailItem(
                                      'Espèce',
                                      auction['espece'] ?? 'N/A',
                                    ),
                                    _buildDetailItem(
                                      'Quantité',
                                      auction['quantite'] ?? 'N/A',
                                    ),
                                    _buildDetailItem(
                                      'Poids',
                                      '${auction['poid'] ?? 'N/A'} kg',
                                    ),
                                    _buildDetailItem(
                                      'Prix minimal',
                                      '${auction['prixinitial'] ?? 'N/A'} ${auction['devise'] ?? 'TND'}',
                                    ),
                                    if (auction['datesoumettre'] != null)
                                      _buildDetailItem(
                                        'Date de soumission',
                                        DateFormat('dd/MM/yyyy').format(
                                          DateTime.parse(auction['datesoumettre']),
                                        ),
                                      ),
                                    if (auction['temperature'] != null)
                                      _buildDetailItem(
                                        'Température', 
                                        '${auction['temperature']} °C'
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Ajouter les informations sur le pêcheur
                            if (_pecheur != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informations sur le pêcheur',
                                        style: Theme.of(context).textTheme.titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        'Nom', 
                                        '${_pecheur!['prenom'] ?? ''} ${_pecheur!['nom'] ?? ''}'
                                      ),
                                      if (_pecheur!['bateau'] != null)
                                        _buildDetailItem('Bateau', _pecheur!['bateau']),
                                      if (_pecheur!['port'] != null)
                                        _buildDetailItem('Port', _pecheur!['port']),
                                      if (_pecheur!['matricule'] != null)
                                        _buildDetailItem('Matricule', _pecheur!['matricule']),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Ajouter les informations sur la prise
                            if (_prise != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informations sur la prise',
                                        style: Theme.of(context).textTheme.titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      if (_prise!['nom'] != null)
                                        _buildDetailItem('Nom de la prise', _prise!['nom']),
                                      if (_prise!['debut'] != null && _prise!['fin'] != null)
                                        _buildDetailItem(
                                          'Période de pêche', 
                                          '${DateFormat('dd/MM/yyyy').format(DateTime.parse(_prise!['debut']))} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(_prise!['fin']))}'
                                        ),
                                      if (_prise!['engin'] != null)
                                        _buildDetailItem('Méthode de pêche', _prise!['engin']),
                                      if (_prise!['zone'] != null)
                                        _buildDetailItem('Zone de pêche', _prise!['zone']),
                                      if (_prise!['latitude'] != null && _prise!['longitude'] != null)
                                        _buildDetailItem(
                                          'Coordonnées', 
                                          '${_prise!['latitude']}, ${_prise!['longitude']}'
                                        ),
                                      if (_prise!['datedebarquement'] != null)
                                        _buildDetailItem(
                                          'Date de débarquement', 
                                          DateFormat('dd/MM/yyyy').format(DateTime.parse(_prise!['datedebarquement']))
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Ajouter les informations sur le vétérinaire
                            if (_veterinaire != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vétérinaire ayant validé le lot',
                                        style: Theme.of(context).textTheme.titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        'Nom', 
                                        '${_veterinaire!['prenom'] ?? ''} ${_veterinaire!['nom'] ?? ''}'
                                      ),
                                      if (_veterinaire!['matricule'] != null)
                                        _buildDetailItem('Matricule', _veterinaire!['matricule']),
                                      if (auction['datetest'] != null)
                                        _buildDetailItem(
                                          'Date de validation', 
                                          DateFormat('dd/MM/yyyy').format(DateTime.parse(auction['datetest']))
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Ajouter les informations sur le maryeur
                            if (_maryeur != null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Maryeur responsable de l\'enchère',
                                        style: Theme.of(context).textTheme.titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDetailItem(
                                        'Nom', 
                                        '${_maryeur!['prenom'] ?? ''} ${_maryeur!['nom'] ?? ''}'
                                      ),
                                      if (_maryeur!['matricule'] != null)
                                        _buildDetailItem('Matricule', _maryeur!['matricule']),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Place bid
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Placer une enchère',
                                      style: Theme.of(context).textTheme.titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _bidController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Votre enchère (${auction['devise'] ?? 'TND'})',
                                        border: const OutlineInputBorder(),
                                        hintText: 'Entrez un montant supérieur à ${auction['current'] ?? auction['prixinitial'] ?? '0'}',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isPlacingBid
                                            ? null
                                            : () => _placeBid(auction),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: _isPlacingBid
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text(
                                                'Placer l\'enchère',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
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
