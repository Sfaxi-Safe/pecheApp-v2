import 'package:flutter/material.dart';
import 'package:peche_app/services/data_migration_service.dart';
import 'package:peche_app/utils/sql_parser.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DataMigrationScreen extends StatefulWidget {
  const DataMigrationScreen({super.key});

  @override
  State<DataMigrationScreen> createState() => _DataMigrationScreenState();
}

class _DataMigrationScreenState extends State<DataMigrationScreen> {
  final DataMigrationService _migrationService = DataMigrationService();
  String? _sqlFilePath;
  bool _isFileLoaded = false;
  bool _isMigratingUsers = false;
  bool _isMigratingFishermen = false;
  bool _isMigratingCatches = false;
  bool _isMigratingLots = false;
  bool _isMigratingProducts = false;
  bool _isMigratingOrders = false;
  bool _isMigratingReviews = false;

  // Données SQL extraites
  List<Map<String, dynamic>> _sqlUsers = [];
  List<Map<String, dynamic>> _sqlFishermen = [];
  List<Map<String, dynamic>> _sqlCatches = [];
  List<Map<String, dynamic>> _sqlLots = [];
  List<Map<String, dynamic>> _sqlProducts = [];
  List<Map<String, dynamic>> _sqlOrders = [];
  List<Map<String, dynamic>> _sqlReviews = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration de Base de Données'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Migrer les Données SQL vers Firebase',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 24),

            // Sélection du fichier SQL
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fichier SQL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sqlFilePath ?? 'Aucun fichier sélectionné',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectSqlFile,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Sélectionner un fichier SQL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_sqlFilePath != null) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isFileLoaded ? null : _loadSqlData,
                              icon: const Icon(Icons.download),
                              label: const Text('Charger les données'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_isFileLoaded) ...[
              _buildMigrationCard(
                title: 'Utilisateurs',
                description:
                    'Migrer les comptes utilisateurs (${_sqlUsers.length} enregistrements)',
                isLoading: _isMigratingUsers,
                onMigrate: _migrateUsers,
              ),

              _buildMigrationCard(
                title: 'Pêcheurs',
                description:
                    'Migrer les données des pêcheurs (${_sqlFishermen.length} enregistrements)',
                isLoading: _isMigratingFishermen,
                onMigrate: _migrateFishermen,
              ),

              _buildMigrationCard(
                title: 'Prises',
                description:
                    'Migrer les données des prises (${_sqlCatches.length} enregistrements)',
                isLoading: _isMigratingCatches,
                onMigrate: _migrateCatches,
              ),

              _buildMigrationCard(
                title: 'Lots',
                description:
                    'Migrer les données des lots (${_sqlLots.length} enregistrements)',
                isLoading: _isMigratingLots,
                onMigrate: _migrateLots,
              ),

              _buildMigrationCard(
                title: 'Produits',
                description:
                    'Migrer les données des produits (${_sqlProducts.length} enregistrements)',
                isLoading: _isMigratingProducts,
                onMigrate: _migrateProducts,
              ),

              _buildMigrationCard(
                title: 'Commandes',
                description:
                    'Migrer les données des commandes (${_sqlOrders.length} enregistrements)',
                isLoading: _isMigratingOrders,
                onMigrate: _migrateOrders,
              ),

              _buildMigrationCard(
                title: 'Avis',
                description:
                    'Migrer les données des avis (${_sqlReviews.length} enregistrements)',
                isLoading: _isMigratingReviews,
                onMigrate: _migrateReviews,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMigrationCard({
    required String title,
    required String description,
    required bool isLoading,
    required VoidCallback onMigrate,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onMigrate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('Migrer les Données'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectSqlFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sql'],
    );

    if (result != null) {
      setState(() {
        _sqlFilePath = result.files.single.path;
        _isFileLoaded = false;
      });
    }
  }

  Future<void> _loadSqlData() async {
    if (_sqlFilePath == null) return;

    try {
      setState(() {
        _isFileLoaded = false;
      });

      // Charger les données des différentes tables
      _sqlUsers = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_user',
      );
      _sqlFishermen = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_pecheur',
      );
      _sqlCatches = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_prise',
      );
      _sqlLots = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_lots',
      );
      _sqlProducts = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_produit',
      );
      _sqlOrders = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_aommande',
      );
      _sqlReviews = await SqlParser.parseTableData(
        _sqlFilePath!,
        'marketplace_avis',
      );

      setState(() {
        _isFileLoaded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données SQL chargées avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des données: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _migrateUsers() async {
    setState(() {
      _isMigratingUsers = true;
    });

    try {
      await _migrationService.migrateUsers(_sqlUsers);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateurs migrés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des utilisateurs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingUsers = false;
      });
    }
  }

  Future<void> _migrateFishermen() async {
    setState(() {
      _isMigratingFishermen = true;
    });

    try {
      await _migrationService.migrateFishermen(_sqlFishermen);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pêcheurs migrés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des pêcheurs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingFishermen = false;
      });
    }
  }

  Future<void> _migrateCatches() async {
    setState(() {
      _isMigratingCatches = true;
    });

    try {
      await _migrationService.migrateCatches(_sqlCatches);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prises migrées avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des prises: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingCatches = false;
      });
    }
  }

  Future<void> _migrateLots() async {
    setState(() {
      _isMigratingLots = true;
    });

    try {
      await _migrationService.migrateLots(_sqlLots);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lots migrés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des lots: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingLots = false;
      });
    }
  }

  Future<void> _migrateProducts() async {
    setState(() {
      _isMigratingProducts = true;
    });

    try {
      await _migrationService.migrateProducts(_sqlProducts);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produits migrés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des produits: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingProducts = false;
      });
    }
  }

  Future<void> _migrateOrders() async {
    setState(() {
      _isMigratingOrders = true;
    });

    try {
      await _migrationService.migrateOrders(_sqlOrders);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commandes migrées avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des commandes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingOrders = false;
      });
    }
  }

  Future<void> _migrateReviews() async {
    setState(() {
      _isMigratingReviews = true;
    });

    try {
      await _migrationService.migrateReviews(_sqlReviews);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avis migrés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la migration des avis: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isMigratingReviews = false;
      });
    }
  }
}
