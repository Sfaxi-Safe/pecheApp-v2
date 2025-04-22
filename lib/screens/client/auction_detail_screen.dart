import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peche_app/services/database_helper.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:intl/intl.dart';



class AuctionDetailScreen extends StatefulWidget {
  final int auctionId;

  const AuctionDetailScreen({
    Key? key,
    required this.auctionId,
  }) : super(key: key);

  @override
  _AuctionDetailScreenState createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  Map<String, dynamic>? _auction;
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
      final results = await DatabaseHelper.instance.queryWhere(
        'marketplace_lots',
        'id = ?',
        [widget.auctionId],
      );

      if (results.isNotEmpty) {
        setState(() {
          _auction = results.first;
          _isLoading = false;
        });
      } else {
        throw Exception('Enchère non trouvée');
      }
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

    final currentPrice = double.tryParse(_auction!['current'] ?? _auction!['prixinitial'] ?? '0') ?? 0;
    if (bidAmount &lt;= currentPrice) {
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
        {
          'current': bidAmount.toString(),
          'user_id': user.id,
        },
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
        title: Text(_auction != null ? 'Enchère - ${_auction!['espece'] ?? 'Inconnu'}' : 'Détails de l\'enchère'),
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
                            if (_auction!['photo'] != null && File(_auction!['photo']).existsSync())
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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.euro, size: 20, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  'Prix actuel: ${_auction!['current'] ?? _auction!['prixinitial'] ?? 'N/A'} €',
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
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDetailItem('Identifiant', _auction!['identifiant'] ?? 'N/A'),
                                    _buildDetailItem('Espèce', _auction!['espece'] ?? 'N/A'),
                                    _buildDetailItem('Quantité', _auction!['quantite'] ?? 'N/A'),
                                    _buildDetailItem('Poids', '${_auction!['poid'] ?? 'N/A'} kg'),
                                    _buildDetailItem('Prix initial', '${_auction!['prixinitial'] ?? 'N/A'} €'),
                                    _buildDetailItem('Prix minimal', '${_auction!['prixminimal'] ?? 'N/A'} €'),
                                    _buildDetailItem('Type d\'enchère', _auction!['typeenchere'] ?? 'standard'),
                                    if (_auction!['datesoumettre'] != null)
                                      _buildDetailItem(
                                        'Date de soumission',
                                        DateFormat('dd/MM/yyyy').format(DateTime.parse(_auction!['datesoumettre'])),
                                      ),
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
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _bidController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Votre enchère (€)',
                                        hintText: 'Entrez un montant supérieur à ${_auction!['current'] ?? _auction!['prixinitial'] ?? '0'} €',
                                        prefixIcon: const Icon(Icons.euro),
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
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: _isPlacingBid
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
