import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/marketplace_aommande.dart';
import '../../models/marketplace_produitvendus.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import '../../utils/app_theme.dart';

// Énumération pour les statuts de commande (pour la compatibilité avec l'ancien code)
enum OrderStatus { pending, confirmed, inProgress, delivered, cancelled }

// Fonctions utilitaires pour convertir entre les statuts
String statusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'En Attente';
    case OrderStatus.confirmed:
      return 'Confirmée';
    case OrderStatus.inProgress:
      return 'En Cours';
    case OrderStatus.delivered:
      return 'Livrée';
    case OrderStatus.cancelled:
      return 'Annulée';
  }
}

OrderStatus stringToStatus(String status) {
  switch (status) {
    case 'En Attente':
      return OrderStatus.pending;
    case 'Confirmée':
      return OrderStatus.confirmed;
    case 'En Cours':
      return OrderStatus.inProgress;
    case 'Livrée':
      return OrderStatus.delivered;
    case 'Annulée':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

/// Écran d'affichage des commandes
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrderStatus? _selectedStatus;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Charger les commandes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrderService();
    });
  }

  Future<void> _initializeOrderService() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final orderService = Provider.of<OrderService>(context, listen: false);

      if (authService.currentUser != null) {
        await orderService.init(
          authService.currentUser!.id.toString(),
          authService.isFisherman ? 'fisherman' : 'client',
        );
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de commandes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: OrderSearchDelegate(
                  Provider.of<OrderService>(context, listen: false),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final orderService = Provider.of<OrderService>(context, listen: false);
              orderService.refreshOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Commandes actualisées'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filtrer par statut',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusFilterChip(null, 'Tous'),
                          _buildStatusFilterChip(
                            OrderStatus.pending,
                            'En Attente',
                          ),
                          _buildStatusFilterChip(
                            OrderStatus.confirmed,
                            'Confirmée',
                          ),
                          _buildStatusFilterChip(
                            OrderStatus.inProgress,
                            'En Cours',
                          ),
                          _buildStatusFilterChip(
                            OrderStatus.delivered,
                            'Livrée',
                          ),
                          _buildStatusFilterChip(
                            OrderStatus.cancelled,
                            'Annulée',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Liste des commandes
          Expanded(
            child: Consumer<OrderService>(
              builder: (context, orderService, child) {
                if (orderService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filtrer les commandes
                List<MarketplaceAommande> filteredOrders = orderService.orders;

                if (_selectedStatus != null) {
                  filteredOrders =
                      filteredOrders
                          .where(
                            (order) =>
                                stringToStatus(order.statutCommande) ==
                                _selectedStatus,
                          )
                          .toList();
                }

                if (_searchQuery.isNotEmpty) {
                  filteredOrders =
                      filteredOrders.where((order) {
                        return order.reference.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            (order.commentaire != null &&
                                order.commentaire!.toLowerCase().contains(
                                  _searchQuery.toLowerCase(),
                                ));
                      }).toList();
                }

                // Trier les commandes par date (plus récentes en premier)
                filteredOrders.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune commande trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => orderService.refreshOrders(),
                  child: ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Construire une puce de filtre par statut
  Widget _buildStatusFilterChip(OrderStatus? status, String label) {
    final isSelected = _selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppTheme.primaryColor.withAlpha(50),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  // Construire une carte de commande
  Widget _buildOrderCard(MarketplaceAommande order) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

    // Déterminer la couleur et l'icône en fonction du statut
    final orderStatus = stringToStatus(order.statutCommande);
    Color statusColor;
    IconData statusIcon;

    switch (orderStatus) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case OrderStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green.shade700;
        statusIcon = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec référence et statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Commande #${order.reference}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusToString(orderStatus),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date et montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Text(
                    formatter.format(order.totale),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Méthode de paiement
              Row(
                children: [
                  const Icon(Icons.payment, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Paiement: ${order.methodeDePaiement}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),

              // Commentaire
              if (order.commentaire != null &&
                  order.commentaire!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Commentaire:',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  order.commentaire!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Écran de détail d'une commande
class OrderDetailScreen extends StatelessWidget {
  final MarketplaceAommande order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final authService = Provider.of<AuthService>(context);
    final orderService = Provider.of<OrderService>(context);

    // Déterminer la couleur et l'icône en fonction du statut
    final orderStatus = stringToStatus(order.statutCommande);
    Color statusColor;
    IconData statusIcon;

    switch (orderStatus) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case OrderStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green.shade700;
        statusIcon = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${order.reference}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut de la commande
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 32, color: statusColor),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          statusToString(orderStatus),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations de la commande
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Référence', order.reference),
                    _buildInfoRow(
                      'Date',
                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                    ),
                    _buildInfoRow(
                      'Dernière modification',
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(order.dateModification),
                    ),
                    _buildInfoRow(
                      'Méthode de paiement',
                      order.methodeDePaiement,
                    ),
                    _buildInfoRow('Total', formatter.format(order.totale)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Produits
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Utiliser FutureBuilder pour récupérer les produits vendus
                    FutureBuilder<List<MarketplaceProduitVendus>>(
                      future: Provider.of<DatabaseHelper>(
                        context,
                        listen: false,
                      ).getProduitVendusByCommandeId(order.id ?? 0),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Erreur: ${snapshot.error}'),
                          );
                        }

                        final produits = snapshot.data ?? [];

                        if (produits.isEmpty) {
                          return const Center(child: Text('Aucun produit'));
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: produits.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final produit = produits[index];
                            return Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    produit.nom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '${produit.quantite}x',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    formatter.format(produit.prix),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    formatter.format(produit.totale),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Expanded(
                          flex: 3,
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            formatter.format(order.totale),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Commentaire
            if (order.commentaire != null && order.commentaire!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commentaire',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(order.commentaire!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            if (authService.isFisherman &&
                orderStatus != OrderStatus.delivered &&
                orderStatus != OrderStatus.cancelled)
              _buildActionButtons(context, orderService),
          ],
        ),
      ),
    );
  }

  // Construire une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Construire les boutons d'action pour les pêcheurs
  Widget _buildActionButtons(BuildContext context, OrderService orderService) {
    final orderStatus = stringToStatus(order.statutCommande);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (orderStatus == OrderStatus.pending)
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmer la commande'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed:
                () => _updateOrderStatus(
                  context,
                  orderService,
                  'confirmed',
                  'Confirmer cette commande ?',
                ),
          ),

        if (orderStatus == OrderStatus.confirmed)
          ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping),
            label: const Text('Marquer comme en cours'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed:
                () => _updateOrderStatus(
                  context,
                  orderService,
                  'in_progress',
                  'Marquer cette commande comme en cours ?',
                ),
          ),

        if (orderStatus == OrderStatus.inProgress)
          ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            label: const Text('Marquer comme livrée'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed:
                () => _updateOrderStatus(
                  context,
                  orderService,
                  'delivered',
                  'Marquer cette commande comme livrée ?',
                ),
          ),

        if (orderStatus != OrderStatus.cancelled &&
            orderStatus != OrderStatus.delivered)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Annuler la commande'),
              onPressed:
                  () => _updateOrderStatus(
                    context,
                    orderService,
                    'cancelled',
                    'Êtes-vous sûr de vouloir annuler cette commande ?',
                    'Cette action est irréversible.',
                  ),
            ),
          ),
      ],
    );
  }

  // Mettre à jour le statut d'une commande
  Future<void> _updateOrderStatus(
    BuildContext context,
    OrderService orderService,
    String newStatus,
    String title, [
    String? content,
  ]) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: content != null ? Text(content) : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await orderService.updateOrderStatus(
        order.id ?? 0,
        newStatus,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Statut mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour du statut'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Délégué de recherche pour les commandes
class OrderSearchDelegate extends SearchDelegate<String> {
  final OrderService _orderService;

  OrderSearchDelegate(this._orderService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Entrez une référence ou un commentaire'),
      );
    }

    final filteredOrders = _orderService.searchOrders(query);

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucune commande trouvée pour "$query"',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

        return ListTile(
          title: Text('Commande #${order.reference}'),
          subtitle: Text(
            '${DateFormat('dd/MM/yyyy').format(order.createdAt)} - ${formatter.format(order.totale)}',
          ),
          trailing: Icon(
            _getStatusIcon(order.statutCommande),
            color: _getStatusColor(order.statutCommande),
          ),
          onTap: () {
            close(context, order.reference);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    final orderStatus = stringToStatus(status);
    switch (orderStatus) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.inProgress:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(String status) {
    final orderStatus = stringToStatus(status);
    switch (orderStatus) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.green;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
