import 'package:flutter/material.dart';
import 'package:seatrace/services/api_service.dart';
import 'package:seatrace/services/auth_service.dart';
import 'package:seatrace/utils/animation_service.dart';
import 'package:seatrace/utils/responsive_service.dart';
import 'package:seatrace/utils/navigation_service.dart';
import 'package:seatrace/utils/error_handler.dart';
import 'package:seatrace/widgets/sea_widgets.dart';

class SelectMaryeurScreen extends StatefulWidget {
  final String lotId;
  final Map<String, dynamic> lotData;

  const SelectMaryeurScreen({
    Key? key,
    required this.lotId,
    required this.lotData,
  }) : super(key: key);

  @override
  State<SelectMaryeurScreen> createState() => _SelectMaryeurScreenState();
}

class _SelectMaryeurScreenState extends State<SelectMaryeurScreen> {
  final _animationService = AnimationService();
  final _responsiveService = ResponsiveService();
  final _navigationService = NavigationService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _maryeurs = [];
  Map<String, dynamic>? _selectedMaryeur;

  @override
  void initState() {
    super.initState();
    _loadMaryeurs();
  }

  // Charger la liste des mareyeurs disponibles
  Future<void> _loadMaryeurs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Chargement des mareyeurs...');

      // Vérifier si l'utilisateur est connecté
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      debugPrint('Utilisateur connecté: ${user.prenom} ${user.nom}');

      // Récupérer les mareyeurs
      final maryeurs = await ApiService.instance.getAllMaryeurs();

      debugPrint('Nombre de mareyeurs récupérés: ${maryeurs.length}');

      // Afficher les détails de chaque mareyeur pour le débogage
      for (var i = 0; i < maryeurs.length; i++) {
        final maryeur = maryeurs[i];
        debugPrint(
          'Mareyeur $i: ${maryeur['prenom']} ${maryeur['nom']} (ID: ${maryeur['_id'] ?? maryeur['id']})',
        );
      }

      if (mounted) {
        setState(() {
          _maryeurs = maryeurs;
          _isLoading = false;

          // Sélectionner le premier mareyeur par défaut s'il y en a
          if (maryeurs.isNotEmpty) {
            _selectedMaryeur = maryeurs[0];
            debugPrint(
              'Mareyeur sélectionné par défaut: ${_selectedMaryeur!['prenom']} ${_selectedMaryeur!['nom']}',
            );
          } else {
            debugPrint('Aucun mareyeur disponible dans la base de données');
            _selectedMaryeur = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _maryeurs = [];
          _selectedMaryeur = null;

          // Message d'erreur plus convivial
          if (e.toString().contains('network') ||
              e.toString().contains('connexion')) {
            _errorMessage =
                'Problème de connexion au serveur. Vérifiez votre connexion internet et réessayez.';
          } else {
            _errorMessage =
                'Aucun mareyeur disponible. Veuillez demander à des mareyeurs de créer un compte dans l\'application.';
          }
        });
      }
      debugPrint('Erreur lors du chargement des mareyeurs: $e');
    }
  }

  Future<void> _assignMaryeur() async {
    if (_selectedMaryeur == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un mareyeur';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non autorisé');
      }

      // Récupérer l'ID du mareyeur sélectionné
      final maryeurId = _selectedMaryeur!['_id'] ?? _selectedMaryeur!['id'];

      if (maryeurId == null) {
        throw Exception(
          'ID du mareyeur invalide. Veuillez sélectionner un autre mareyeur.',
        );
      }

      // Récupérer les détails de la prise associée au lot
      final priseId = widget.lotData['prise'];
      if (priseId == null) {
        throw Exception('Prise non trouvée pour ce lot');
      }

      // Utiliser la nouvelle route pour assigner un mareyeur à une prise
      await ApiService.instance.assignMaryeurToPrise(
        user.id,
        priseId,
        maryeurId,
      );

      // Notifier le mareyeur qu'un lot lui a été assigné
      await ApiService.instance.post('notifications', {
        'destinataire': maryeurId,
        'destinataireModel': 'Maryeur',
        'titre': 'Nouveau lot assigné',
        'contenu':
            'Un lot de ${widget.lotData['espece']} vous a été assigné par le vétérinaire ${user.prenom} ${user.nom}',
        'type': 'info',
        'reference': widget.lotId,
        'referenceModel': 'Lot',
        'urlAction': '/maryeur/lots/${widget.lotId}',
      });

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mareyeur assigné avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Retourner à l'écran précédent
      Navigator.of(context).pop(true);
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'SelectMaryeurScreen._assignMaryeur',
      );

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Erreur lors de l\'assignation du mareyeur: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un mareyeur'),
        elevation: 0,
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: _responsiveService.adaptivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _animationService.staggeredList([
                      // En-tête avec informations sur le lot
                      SeaCard(
                        elevated: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Lot approuvé avec succès',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Veuillez sélectionner un mareyeur pour ce lot',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Espèce: ${widget.lotData['espece'] ?? 'Non spécifiée'}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (widget.lotData['quantite'] != null)
                              Text(
                                'Quantité: ${widget.lotData['quantite']}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            if (widget.lotData['poids'] != null)
                              Text(
                                'Poids: ${widget.lotData['poids']} kg',
                                style: theme.textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),

                      // Sélection du mareyeur
                      SeaSectionHeader(
                        title: 'Mareyeurs disponibles',
                        icon: Icons.business,
                        subtitle: 'Sélectionnez un mareyeur pour ce lot',
                      ),

                      if (_maryeurs.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Aucun mareyeur disponible dans la base de données',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Veuillez demander à des mareyeurs de créer un compte dans l\'application pour pouvoir leur assigner des lots.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              CustomButton.outline(
                                text: 'Actualiser la liste',
                                icon: Icons.refresh,
                                onPressed: _loadMaryeurs,
                                color: theme.primaryColor,
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            // Liste des mareyeurs
                            ...List.generate(_maryeurs.length, (index) {
                              final maryeur = _maryeurs[index];
                              final isSelected = _selectedMaryeur == maryeur;

                              return SeaCard(
                                margin: const EdgeInsets.only(bottom: 8),
                                backgroundColor:
                                    isSelected
                                        ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                        : null,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedMaryeur = maryeur;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.person,
                                              color: theme.colorScheme.primary,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${maryeur['prenom'] ?? ''} ${maryeur['nom'] ?? ''}',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              if (maryeur['matricule'] != null)
                                                Text(
                                                  'Matricule: ${maryeur['matricule']}',
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                              if (maryeur['telephone'] != null)
                                                Text(
                                                  'Tél: ${maryeur['telephone']}',
                                                  style:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium,
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: theme.colorScheme.primary,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                      // Message d'erreur
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Bouton d'action
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton.filled(
                          text:
                              _isLoading
                                  ? 'Assignation...'
                                  : 'Assigner ce mareyeur',
                          icon: _isLoading ? null : Icons.check,
                          onPressed:
                              _isLoading || _selectedMaryeur == null
                                  ? null
                                  : _assignMaryeur,
                          isLoading: _isLoading,
                          color: theme.primaryColor,
                          size: CustomButtonSize.large,
                        ),
                      ),
                    ]),
                  ),
                ),
      ),
    );
  }
}
