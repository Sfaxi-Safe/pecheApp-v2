import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/services/image_service.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/widgets/sea_widgets.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _lots = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'Tous';
  String _sortBy = 'Date (récent)';
  final _animationService = AnimationService();
  final _responsiveService = ResponsiveService();

  final List<String> _statusFilters = ['Tous', 'En attente', 'Validé', 'Refusé'];
  final List<String> _sortOptions = ['Date (récent)', 'Date (ancien)', 'Espèce (A-Z)', 'Espèce (Z-A)', 'Poids (élevé)', 'Poids (faible)'];

  @override
  void initState() {
    super.initState();
    _loadLots();
  }

  Future<void> _loadLots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || !user.isPecheur()) {
        throw Exception('Utilisateur non autorisé');
      }

      final response = await ApiService.instance.getLotsByPecheurId(user.id);
      
      // Appliquer le tri et le filtrage
      List<Map<String, dynamic>> filteredLots = [...response];
      
      // Filtrer par statut
      if (_filterStatus != 'Tous') {
        filteredLots = filteredLots.where((lot) {
          final status = lot['test'] == 1
              ? (lot['status'] == 1 ? 'Validé' : 'Refusé')
              : 'En attente';
          return status == _filterStatus;
        }).toList();
      }
      
      // Trier les lots
      filteredLots.sort((a, b) {
        switch (_sortBy) {
          case 'Date (récent)':
            final dateA = a['datetest'] != null ? DateTime.parse(a['datetest']) : DateTime(1900);
            final dateB = b['datetest'] != null ? DateTime.parse(b['datetest']) : DateTime(1900);
            return dateB.compareTo(dateA);
          case 'Date (ancien)':
            final dateA = a['datetest'] != null ? DateTime.parse(a['datetest']) : DateTime(1900);
            final dateB = b['datetest'] != null ? DateTime.parse(b['datetest']) : DateTime(1900);
            return dateA.compareTo(dateB);
          case 'Espèce (A-Z)':
            final especeA = (a['espece'] ?? '').toString().toLowerCase();
            final especeB = (b['espece'] ?? '').toString().toLowerCase();
            return especeA.compareTo(especeB);
          case 'Espèce (Z-A)':
            final especeA = (a['espece'] ?? '').toString().toLowerCase();
            final especeB = (b['espece'] ?? '').toString().toLowerCase();
            return especeB.compareTo(especeA);
          case 'Poids (élevé)':
            final poidsA = a['poid'] != null ? double.tryParse(a['poid'].toString()) ?? 0.0 : 0.0;
            final poidsB = b['poid'] != null ? double.tryParse(b['poid'].toString()) ?? 0.0 : 0.0;
            return poidsB.compareTo(poidsA);
          case 'Poids (faible)':
            final poidsA = a['poid'] != null ? double.tryParse(a['poid'].toString()) ?? 0.0 : 0.0;
            final poidsB = b['poid'] != null ? double.tryParse(b['poid'].toString()) ?? 0.0 : 0.0;
            return poidsA.compareTo(poidsB);
          default:
            return 0;
        }
      });
      
      setState(() {
        _lots = filteredLots;
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
    final primaryColor = theme.primaryColor;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des captures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filtrer',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Trier',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _animationService.fadeIn(
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SeaButton.primary(
                            text: 'Réessayer',
                            icon: Icons.refresh,
                            onPressed: _loadLots,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Filtres actifs
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: theme.colorScheme.surface,
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Filtre: $_filterStatus',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.sort,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tri: $_sortBy',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Liste des captures
                      Expanded(
                        child: _lots.isEmpty
                            ? _animationService.fadeIn(
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.sailing_outlined,
                                          size: 64,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Aucune capture trouvée',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _filterStatus != 'Tous'
                                            ? 'Essayez de modifier vos filtres'
                                            : 'Scannez votre premier poisson pour commencer',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      if (_filterStatus != 'Tous')
                                        SeaButton.outline(
                                          text: 'Réinitialiser les filtres',
                                          icon: Icons.filter_list_off,
                                          onPressed: () {
                                            setState(() {
                                              _filterStatus = 'Tous';
                                            });
                                            _loadLots();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadLots,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _lots.length,
                                  itemBuilder: (context, index) {
                                    final lot = _lots[index];
                                    return _animationService.fadeIn(
                                      _animationService.slideUp(
                                        _buildLotCard(context, lot),
                                        duration: Duration(milliseconds: 300 + (index * 50)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, Map<String, dynamic> lot) {
    final theme = Theme.of(context);
    final espece = lot['espece'] ?? 'Inconnu';
    final date = lot['datetest'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(lot['datetest']))
        : 'Date inconnue';
    final status = lot['test'] == 1
        ? (lot['status'] == 1 ? 'Validé' : 'Refusé')
        : 'En attente';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'Validé':
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.check_circle;
        break;
      case 'Refusé':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
    final photoPath = lot['photo'];
    final imageUrl = photoPath != null ? ImageService.instance.getImageUrl(photoPath) : null;

    return SeaCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statut
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    espece,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Informations principales
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.scale,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${lot['poid'] ?? 'N/A'} kg',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.numbers,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  '${lot['quantite'] ?? 'N/A'} unités',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Image
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: theme.dividerTheme.color,
                    ),
                  ),
                ),
              ),
            ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SeaButton.text(
                  text: 'Détails',
                  icon: Icons.visibility,
                  onPressed: () => _showLotDetails(context, lot),
                ),
                if (lot['test'] == 0) ...[
                  SeaButton.text(
                    text: 'Modifier',
                    icon: Icons.edit,
                    onPressed: () {
                      // In a real app, navigate to edit screen
                    },
                  ),
                  SeaButton.text(
                    text: 'Supprimer',
                    icon: Icons.delete,
                    color: theme.colorScheme.error,
                    onPressed: () => _confirmDelete(context, lot),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLotDetails(BuildContext context, Map<String, dynamic> lot) {
    final theme = Theme.of(context);
    final espece = lot['espece'] ?? 'Inconnu';
    final photoPath = lot['photo'];
    final imageUrl = photoPath != null ? ImageService.instance.getImageUrl(photoPath) : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails - $espece'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: theme.colorScheme.surface,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: theme.dividerTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailItem(context, 'Identifiant', lot['identifiant'] ?? 'N/A'),
              _buildDetailItem(context, 'Espèce', lot['espece'] ?? 'N/A'),
              _buildDetailItem(context, 'Quantité', lot['quantite'] ?? 'N/A'),
              _buildDetailItem(context, 'Poids', '${lot['poid'] ?? 'N/A'} kg'),
              _buildDetailItem(context, 'Température', '${lot['temperature'] ?? 'N/A'} °C'),
              _buildDetailItem(context, 'Date de soumission', lot['datesoumettre'] ?? 'N/A'),
              _buildDetailItem(
                context,
                'Statut',
                lot['test'] == 1
                    ? (lot['status'] == 1 ? 'Validé' : 'Refusé')
                    : 'En attente',
              ),
              if (lot['test'] == 1 && lot['status'] == 0) ...[
                const SizedBox(height: 16),
                const Text(
                  'Motif de refus:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Le poisson ne répond pas aux critères de qualité requis.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          SeaButton.text(
            text: 'Fermer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> lot) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette capture ? Cette action est irréversible.',
        ),
        actions: [
          SeaButton.text(
            text: 'Annuler',
            onPressed: () => Navigator.of(context).pop(),
          ),
          SeaButton.primary(
            text: 'Supprimer',
            icon: Icons.delete,
            color: theme.colorScheme.error,
            onPressed: () async {
              Navigator.of(context).pop();

              // Delete the lot
              try {
                await ApiService.instance.delete('lots/${lot['id']}');

                // Refresh the list
                _loadLots();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text('Capture supprimée avec succès'),
                      ],
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Erreur lors de la suppression: ${e.toString()}',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtrer par statut',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _statusFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _statusFilters[index];
                    final isSelected = filter == _filterStatus;
                    
                    return ListTile(
                      title: Text(filter),
                      leading: Icon(
                        _getFilterIcon(filter),
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _filterStatus = filter;
                        });
                        Navigator.pop(context);
                        _loadLots();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trier par',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _sortOptions.length,
                  itemBuilder: (context, index) {
                    final option = _sortOptions[index];
                    final isSelected = option == _sortBy;
                    
                    return ListTile(
                      title: Text(option),
                      leading: Icon(
                        _getSortIcon(option),
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          _sortBy = option;
                        });
                        Navigator.pop(context);
                        _loadLots();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Tous':
        return Icons.all_inclusive;
      case 'En attente':
        return Icons.pending;
      case 'Validé':
        return Icons.check_circle;
      case 'Refusé':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }

  IconData _getSortIcon(String option) {
    switch (option) {
      case 'Date (récent)':
        return Icons.calendar_today;
      case 'Date (ancien)':
        return Icons.calendar_today;
      case 'Espèce (A-Z)':
        return Icons.sort_by_alpha;
      case 'Espèce (Z-A)':
        return Icons.sort_by_alpha;
      case 'Poids (élevé)':
        return Icons.scale;
      case 'Poids (faible)':
        return Icons.scale;
      default:
        return Icons.sort;
    }
  }
}
