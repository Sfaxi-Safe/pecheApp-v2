import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/statistics_service.dart';
import '../../utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

/// Écran d'affichage des statistiques
class StatisticsScreen extends StatefulWidget {
  final int pecheurId; // Reçu depuis le parent
  const StatisticsScreen({Key? key, required this.pecheurId}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGeneratingReport = false;
  Map<String, dynamic>? _salesReport;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final statisticsService = Provider.of<StatisticsService>(context, listen: false);
      statisticsService.loadAllStatistics(widget.pecheurId); // Utilisation du pecheurId passé en paramètre
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Sélectionner une date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fr', 'FR'),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  // Générer un rapport de ventes
  Future<void> _generateSalesReport() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une période'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isGeneratingReport = true;
    });
    
    try {
      final statisticsService = Provider.of<StatisticsService>(context, listen: false);
      final report = await statisticsService.generateSalesReport(
        pecheurId: widget.pecheurId,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() {
        _salesReport = report;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du rapport: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Ventes'),
            Tab(text: 'Produits'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSalesTab(),
          _buildProductsTab(),
        ],
      ),
    );
  }
  
  // Onglet d'aperçu général
  Widget _buildOverviewTab() {
    return Consumer<StatisticsService>(
      builder: (context, statisticsService, child) {
        if (statisticsService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cartes de statistiques
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Commandes',
                      value: '${statisticsService.totalOrders}',
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Revenus',
                      value: formatter.format(statisticsService.totalRevenue),
                      icon: Icons.euro,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Produits vendus',
                      value: '${statisticsService.totalProducts}',
                      icon: Icons.inventory,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Valeur moyenne',
                      value: statisticsService.totalOrders > 0
                          ? formatter.format(
                              statisticsService.totalRevenue / statisticsService.totalOrders,
                            )
                          : '0 €',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Graphique des revenus par mois
              if (statisticsService.revenueByMonth.isNotEmpty) ...[
                const Text(
                  'Revenus par mois',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 200,
                  child: _buildRevenueChart(statisticsService.revenueByMonth),
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Commandes par statut
              const Text(
                'Commandes par statut',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (statisticsService.ordersByStatus.isEmpty)
                const Center(
                  child: Text('Aucune donnée disponible'),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: statisticsService.ordersByStatus.entries.map((entry) {
                        final status = entry.key;
                        final count = entry.value;
                        
                        Color statusColor;
                        IconData statusIcon;
                        
                        switch (status.toLowerCase()) {
                          case 'en attente':
                            statusColor = Colors.orange;
                            statusIcon = Icons.hourglass_empty;
                            break;
                          case 'confirmée':
                            statusColor = Colors.green;
                            statusIcon = Icons.check_circle;
                            break;
                          case 'en cours':
                            statusColor = Colors.blue;
                            statusIcon = Icons.local_shipping;
                            break;
                          case 'livrée':
                            statusColor = Colors.green.shade700;
                            statusIcon = Icons.done_all;
                            break;
                          case 'annulée':
                            statusColor = Colors.red;
                            statusIcon = Icons.cancel;
                            break;
                          default:
                            statusColor = Colors.grey;
                            statusIcon = Icons.help_outline;
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: statusColor),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: TextStyle(color: statusColor),
                              ),
                              const Spacer(),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Revenus par mois (tableau)
              const Text(
                'Revenus par mois',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (statisticsService.revenueByMonth.isEmpty)
                const Center(
                  child: Text('Aucune donnée disponible'),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: statisticsService.revenueByMonth.entries
                          .toList()
                          .map((entry) {
                        final monthYear = entry.key;
                        final revenue = entry.value;
                        
                        // Convertir "MM-yyyy" en objet DateTime
                        final date = DateFormat('MM-yyyy').parse(monthYear);
                        final formattedMonth = DateFormat('MMMM yyyy', 'fr_FR').format(date);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(formattedMonth),
                              const Spacer(),
                              Text(
                                formatter.format(revenue),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  // Onglet des ventes
  Widget _buildSalesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection de la période
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Période',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de début',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _startDate == null
                                  ? 'Sélectionner'
                                  : DateFormat('dd/MM/yyyy').format(_startDate!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Date de fin',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _endDate == null
                                  ? 'Sélectionner'
                                  : DateFormat('dd/MM/yyyy').format(_endDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isGeneratingReport ? null : _generateSalesReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isGeneratingReport
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Générer le rapport'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Affichage du rapport
          if (_salesReport != null) ...[
            if (_salesReport!.containsKey('error'))
              Text(
                'Erreur: ${_salesReport!['error']}',
                style: const TextStyle(color: Colors.red),
              )
            else
              _buildSalesReport(_salesReport!),
          ],
        ],
      ),
    );
  }
  
  // Onglet des produits
  Widget _buildProductsTab() {
    return Consumer<StatisticsService>(
      builder: (context, statisticsService, child) {
        if (statisticsService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
        
        // Trier les produits par quantité
        final sortedProducts = statisticsService.quantityByProduct.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Produits les plus vendus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (sortedProducts.isEmpty)
                const Center(
                  child: Text('Aucun produit vendu'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedProducts.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    final product = sortedProducts[index];
                    final name = product.key;
                    final quantity = product.value;
                    final revenue = statisticsService.revenueByProduct[name] ?? 0.0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('Quantité: $quantity'),
                        trailing: Text(
                          formatter.format(revenue),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Graphique de répartition des produits
              if (sortedProducts.isNotEmpty) ...[
                const Text(
                  'Répartition des ventes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 200,
                  child: _buildProductsChart(sortedProducts, statisticsService),
                ),
                
                const SizedBox(height: 24),
              ],
              
              // Tableau de répartition des ventes
              const Text(
                'Répartition des ventes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (sortedProducts.isEmpty)
                const Center(
                  child: Text('Aucune donnée disponible'),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: sortedProducts.take(5).map((entry) {
                        final name = entry.key;
                        final quantity = entry.value;
                        final revenue = statisticsService.revenueByProduct[name] ?? 0.0;
                        final percentage = statisticsService.totalRevenue > 0
                            ? (revenue / statisticsService.totalRevenue * 100).toStringAsFixed(1)
                            : '0';
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      formatter.format(revenue),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '$percentage%',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: statisticsService.totalRevenue > 0
                                    ? revenue / statisticsService.totalRevenue
                                    : 0,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  // Construire une carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construire le rapport de ventes
  Widget _buildSalesReport(Map<String, dynamic> report) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final summary = report['summary'] as Map<String, dynamic>;
    final period = report['period'] as Map<String, dynamic>;
    final ordersByStatus = report['ordersByStatus'] as Map<String, dynamic>;
    final topProducts = report['topProducts'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Période du rapport
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Période: ${period['start']} - ${period['end']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Résumé
        const Text(
          'Résumé',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Commandes',
                  '${summary['totalOrders']}',
                  Icons.shopping_cart,
                  Colors.blue,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Revenus',
                  formatter.format(summary['totalRevenue']),
                  Icons.euro,
                  Colors.green,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Valeur moyenne',
                  formatter.format(summary['averageOrderValue']),
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Commandes par statut
        const Text(
          'Commandes par statut',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: ordersByStatus.entries.map((entry) {
                final status = entry.key;
                final count = entry.value;
                
                Color statusColor;
                IconData statusIcon;
                
                switch (status.toLowerCase()) {
                  case 'en attente':
                    statusColor = Colors.orange;
                    statusIcon = Icons.hourglass_empty;
                    break;
                  case 'confirmée':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'en cours':
                    statusColor = Colors.blue;
                    statusIcon = Icons.local_shipping;
                    break;
                  case 'livrée':
                    statusColor = Colors.green.shade700;
                    statusIcon = Icons.done_all;
                    break;
                  case 'annulée':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.help_outline;
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: TextStyle(color: statusColor),
                      ),
                      const Spacer(),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Produits les plus vendus
        const Text(
          'Produits les plus vendus',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (topProducts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Aucun produit vendu'),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = topProducts[index] as Map<String, dynamic>;
                final name = product['name'] as String;
                final quantity = product['quantity'] as int;
                final revenue = product['revenue'] as double;
                
                return ListTile(
                  title: Text(name),
                  subtitle: Text('Quantité: $quantity'),
                  trailing: Text(
                    formatter.format(revenue),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
  
  // Construire une ligne de résumé
  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  // Construire un graphique de revenus
  Widget _buildRevenueChart(Map<String, double> revenueByMonth) {
    // Convertir les données pour le graphique
    final entries = revenueByMonth.entries.toList();
    entries.sort((a, b) {
      final dateA = DateFormat('MM-yyyy').parse(a.key);
      final dateB = DateFormat('MM-yyyy').parse(b.key);
      return dateA.compareTo(dateB);
    });
    
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value.toDouble()));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  final date = DateFormat('MM-yyyy').parse(entries[value.toInt()].key);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM', 'fr_FR').format(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  // Construire un graphique de produits
  Widget _buildProductsChart(
    List<MapEntry<String, int>> products,
    StatisticsService statisticsService,
  ) {
    // Limiter à 5 produits maximum
    final topProducts = products.take(5).toList();
    
    return PieChart(
      PieChartData(
        sections: topProducts.map((product) {
          final name = product.key;
          final revenue = statisticsService.revenueByProduct[name] ?? 0.0;
          final percentage = statisticsService.totalRevenue > 0
              ? revenue / statisticsService.totalRevenue
              : 0.0;
          
          // Générer une couleur basée sur l'index
          final index = topProducts.indexOf(product);
          final colors = [
            AppTheme.primaryColor,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.red,
          ];
          final color = index < colors.length ? colors[index] : Colors.grey;
          
          return PieChartSectionData(
            color: color,
            value: percentage,
            title: '${(percentage * 100).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}
