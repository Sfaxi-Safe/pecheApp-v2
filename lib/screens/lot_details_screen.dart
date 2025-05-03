import 'package:flutter/material.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/widgets/sea_widgets.dart';
import 'package:intl/intl.dart';

class LotDetailsScreen extends StatefulWidget {
  final String lotId;

  const LotDetailsScreen({Key? key, required this.lotId}) : super(key: key);

  @override
  State<LotDetailsScreen> createState() => _LotDetailsScreenState();
}

class _LotDetailsScreenState extends State<LotDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _lotDetails = {};

  @override
  void initState() {
    super.initState();
    _loadLotDetails();
  }

  Future<void> _loadLotDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.instance.getAuctionDetails(widget.lotId);
      setState(() {
        _lotDetails = response;
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du lot'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildLotDetails(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SeaButton.primary(
              text: 'Réessayer',
              icon: Icons.refresh,
              onPressed: _loadLotDetails,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotDetails() {
    final theme = Theme.of(context);
    final espece = _lotDetails['espece'] is Map
        ? _lotDetails['espece']['nom']
        : _lotDetails['espece']?.toString() ?? 'Inconnu';
    final dateTest = _lotDetails['dateTest'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(_lotDetails['dateTest']))
        : 'Date inconnue';
    final status = _lotDetails['status'] == true ? 'Approuvé' : 'Refusé';
    final statusColor = _lotDetails['status'] == true
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;
    final photoUrl = _lotDetails['photo'] != null && _lotDetails['photo'].isNotEmpty
        ? ApiService.instance.getImageUrl(_lotDetails['photo'])
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo du lot
          if (photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                photoUrl,
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

          // Informations principales
          SeaCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        espece,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Identifiant', _lotDetails['identifiant'] ?? 'N/A'),
                  _buildDetailRow('Date de test', dateTest),
                  _buildDetailRow('Quantité', '${_lotDetails['quantite'] ?? 'N/A'}'),
                  _buildDetailRow('Poids', '${_lotDetails['poids'] ?? 'N/A'} kg'),
                  _buildDetailRow('Température', '${_lotDetails['temperature'] ?? 'N/A'} °C'),
                  if (_lotDetails['prixInitial'] != null)
                    _buildDetailRow('Prix initial', '${_lotDetails['prixInitial']} TND'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Informations sur le vétérinaire
          if (_lotDetails['veterinaire'] != null) ...[
            Text(
              'Vétérinaire',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SeaCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: const Icon(Icons.medical_services),
                ),
                title: Text(
                  _lotDetails['veterinaire'] is Map
                      ? '${_lotDetails['veterinaire']['prenom']} ${_lotDetails['veterinaire']['nom']}'
                      : 'Vétérinaire',
                ),
                subtitle: Text(dateTest),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Informations sur la prise
          if (_lotDetails['prise'] != null) ...[
            Text(
              'Prise',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SeaCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      'Nom',
                      _lotDetails['prise'] is Map
                          ? _lotDetails['prise']['nom'] ?? 'N/A'
                          : 'N/A',
                    ),
                    _buildDetailRow(
                      'Lieu',
                      _lotDetails['prise'] is Map
                          ? _lotDetails['prise']['lieu'] ?? 'N/A'
                          : 'N/A',
                    ),
                    _buildDetailRow(
                      'Date de début',
                      _lotDetails['prise'] is Map && _lotDetails['prise']['debut'] != null
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(_lotDetails['prise']['debut']),
                            )
                          : 'N/A',
                    ),
                    _buildDetailRow(
                      'Date de fin',
                      _lotDetails['prise'] is Map && _lotDetails['prise']['fin'] != null
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(_lotDetails['prise']['fin']),
                            )
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
