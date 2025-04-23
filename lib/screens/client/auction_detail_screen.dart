import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peche_app/services/database_helper.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:intl/intl.dart';

class AuctionDetailScreen extends StatefulWidget {
  final int auctionId;

  const AuctionDetailScreen({Key? key, required this.auctionId})
    : super(key: key);

  @override
  _AuctionDetailScreenState createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  Map<String, dynamic>? _auction;
  Map<String, dynamic>? _pecheur;    // Ajout de cette variable
  Map<String, dynamic>? _veterinaire; // Ajout de cette variable
  Map<String, dynamic>? _maryeur;     // Ajout de cette variable
  Map<String, dynamic>? _prise;       // Ajout de cette variable
  bool _isLoading = true;
  String? _errorMessage;
  final _bidController = TextEditingController();
  bool _isPlacingBid = false;

  @override
  void initState() {
    super.initState();
    _loadAuctionDetails();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _loadAuctionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les détails de l'enchère
      final results = await DatabaseHelper.instance.queryWhere(
        'marketplace_lots',
        'id = ?',
        [widget.auctionId],
      );

      if (results.isEmpty) {
        throw Exception('Enchère non trouvée');
      }

      final auction = results.first;
      
      // Charger les détails de la prise
      Map<String, dynamic>? prise;
      if (auction['prise_id'] != null) {
        final priseResults = await DatabaseHelper.instance.queryWhere(
          'marketplace_prise',
          'id = ?',
          [auction['prise_id']],
        );
        if (priseResults.isNotEmpty) {
          prise = priseResults.first;
        }
      }
      
      // Charger les détails du pêcheur
      Map<String, dynamic>? pecheur;
      if (prise != null && prise['pecheur_id'] != null) {
        final pecheurResults = await DatabaseHelper.instance.queryWhere(
          'marketplace_pecheur',
          'id = ?',
          [prise['pecheur_id']],
        );
        if (pecheurResults.isNotEmpty) {
          pecheur = pecheurResults.first;
        }
      }
      
      // Charger les détails du vétérinaire
      Map<String, dynamic>? veterinaire;
      if (auction['vitirinaire_id'] != null) {
        final veterinaireResults = await DatabaseHelper.instance.queryWhere(
          'marketplace_vitirinaire',
          'id = ?',
          [auction['vitirinaire_id']],
        );
        if (veterinaireResults.isNotEmpty) {
          veterinaire = veterinaireResults.first;
        }
      }
      
      // Charger les détails du maryeur
      Map<String, dynamic>? maryeur;
      if (prise != null && prise['maryeur_id'] != null) {
        final maryeurResults = await DatabaseHelper.instance.queryWhere(
          'marketplace_maryeur',
          'id = ?',
          [prise['maryeur_id']],
        );
        if (maryeurResults.isNotEmpty) {
          maryeur = maryeurResults.first;
        }
      }

      setState(() {
        _auction = auction;
        _prise = prise;
        _pecheur = pecheur;
        _veterinaire = veterinaire;
        _maryeur = maryeur;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _placeBid() async {
    if (_auction == null) return;

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
          _auction!['current'] ?? _auction!['prixinitial'] ?? '0',
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

      // Update the current price
      await DatabaseHelper.instance.update(
        'marketplace_lots',
        {'current': bidAmount.toString(), 'user_id': user.id},
        'id = ?',
        [widget.auctionId],
      );

      // Reload auction details
      await _loadAuctionDetails();

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
        title: Text(
          _auction != null
              ? 'Enchère - ${_auction!['espece'] ?? 'Inconnu'}'
              : 'Détails de l\'enchère',
        ),
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
                        onPressed: _loadAuctionDetails,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
                : _auction == null
                ? const Center(child: Text('Aucune information disponible'))
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (_auction!['photo'] != null &&
                          File(_auction!['photo']).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_auction!['photo']),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
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
                        _auction!['espece'] ?? 'Inconnu',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Remplacer l'icône Euro par une icône plus générique
                          const Icon(Icons.price_change, size: 20, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            // Afficher le prix en TND
                            'Prix actuel: ${_auction!['current'] ?? _auction!['prixinitial'] ?? 'N/A'} ${_auction!['devise'] ?? 'TND'}',
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
                                _auction!['identifiant'] ?? 'N/A',
                              ),
                              _buildDetailItem(
                                'Espèce',
                                _auction!['espece'] ?? 'N/A',
                              ),
                              _buildDetailItem(
                                'Quantité',
                                _auction!['quantite'] ?? 'N/A',
                              ),
                              _buildDetailItem(
                                'Poids',
                                '${_auction!['poid'] ?? 'N/A'} kg',
                              ),
                              // Remplacer "Prix initial" par "Prix minimal" et afficher en TND
                              _buildDetailItem(
                                'Prix minimal',
                                '${_auction!['prixminimal'] ?? 'N/A'} ${_auction!['devise'] ?? 'TND'}',
                              ),
                              _buildDetailItem(
                                'Type d\'enchère',
                                _auction!['typeenchere'] ?? 'standard',
                              ),
                              if (_auction!['datesoumettre'] != null)
                                _buildDetailItem(
                                  'Date de soumission',
                                  DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(_auction!['datesoumettre']),
                                  ),
                                ),
                              if (_auction!['temperature'] != null)
                                _buildDetailItem(
                                  'Température', 
                                  '${_auction!['temperature']} °C'
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
                                if (_prise!['latitude'] != null && _prise!['langitude'] != null)
                                  _buildDetailItem(
                                    'Coordonnées', 
                                    '${_prise!['latitude']}, ${_prise!['langitude']}'
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
                                if (_auction!['datetest'] != null)
                                  _buildDetailItem(
                                    'Date de validation', 
                                    DateFormat('dd/MM/yyyy').format(DateTime.parse(_auction!['datetest']))
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

                      // Place bid - Mettre à jour pour afficher TND
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
                                  // Mettre à jour pour afficher TND
                                  labelText: 'Votre enchère (TND)',
                                  hintText:
                                      'Entrez un montant supérieur à ${_auction!['current'] ?? _auction!['prixinitial'] ?? '0'} ${_auction!['devise'] ?? 'TND'}',
                                  // Remplacer l'icône Euro
                                  prefixIcon: const Icon(Icons.price_change),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isPlacingBid ? null : _placeBid,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child:
                                      _isPlacingBid
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text('Placer l\'enchère'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}