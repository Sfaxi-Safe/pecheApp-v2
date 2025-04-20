import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/marketplace_aommande.dart';
import '../../models/marketplace_produit.dart';
import '../../models/marketplace_produitvendus.dart';
import '../../services/payment_service.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../services/database_helper.dart';
import '../../utils/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final MarketplaceAommande order;

  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  bool _isProcessing = false;
  String? _errorMessage;
  MarketplaceProduit? _produit;
  List<MarketplaceProduitVendus> _produitsVendus = [];

  // Contrôleurs pour les champs de carte de crédit
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  Future<void> _loadProductDetails() async {
    try {
      final dbHelper = DatabaseHelper();

      // Récupérer les produits vendus associés à la commande
      if (widget.order.id != null) {
        final produitsVendus = await dbHelper.getProduitVendusByCommandeId(
          widget.order.id!,
        );

        // Si nous avons des produits vendus, récupérer le premier produit pour l'afficher
        if (produitsVendus.isNotEmpty && produitsVendus[0].produitId != null) {
          final produit = await dbHelper.getProduitById(
            produitsVendus[0].produitId!,
          );

          setState(() {
            _produit = produit;
            _produitsVendus = produitsVendus;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors du chargement des détails du produit: $e';
        });
      }
    }
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == PaymentMethod.creditCard &&
        !_validateCardDetails()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final paymentService = Provider.of<PaymentService>(
        context,
        listen: false,
      );
      final authService = Provider.of<AuthService>(context, listen: false);
      final orderService = Provider.of<OrderService>(context, listen: false);

      bool success = false;

      if (_selectedMethod == PaymentMethod.creditCard) {
        // Créer un objet CreditCard avec les informations saisies
        final creditCard = CreditCard(
          number: _cardNumberController.text.replaceAll(' ', ''),
          holderName: _cardHolderController.text,
          expiryDate: _expiryDateController.text,
          cvv: _cvvController.text,
        );

        success = await paymentService.processCardPayment(
          orderId: widget.order.id,
          userId: authService.currentUser!.id.toString(),
          amount: widget.order.totale,
          creditCard: creditCard,
        );
      } else if (_selectedMethod == PaymentMethod.cash) {
        success = await paymentService.processCashPayment(
          orderId: widget.order.id,
          userId: authService.currentUser!.id.toString(),
          amount: widget.order.totale,
        );
      }

      if (success) {
        // Mettre à jour le statut de la commande
        await orderService.updateOrderStatus(
          widget.order.id.toString(),
          'confirmed',
        );

        // Afficher un message de succès et retourner à l'écran précédent
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paiement effectué avec succès !'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = 'Le paiement a échoué. Veuillez réessayer.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _validateCardDetails() {
    if (_cardNumberController.text.replaceAll(' ', '').length < 16) {
      setState(() {
        _errorMessage = 'Numéro de carte invalide';
      });
      return false;
    }

    if (_cardHolderController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Nom du titulaire requis';
      });
      return false;
    }

    if (_expiryDateController.text.isEmpty ||
        !_expiryDateController.text.contains('/')) {
      setState(() {
        _errorMessage = 'Date d\'expiration invalide (MM/AA)';
      });
      return false;
    }

    if (_cvvController.text.length < 3) {
      setState(() {
        _errorMessage = 'CVV invalide';
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final totalPrice = widget.order.totale;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Résumé de la commande
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Résumé de la commande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (_produit != null) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _produit!.images.isNotEmpty
                              ? Image.network(
                                  _produit!.images[0],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/fish_placeholder.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        title: Text(_produit!.nom),
                        subtitle: Text(
                          'Quantité: ${_produitsVendus.isNotEmpty ? _produitsVendus[0].quantite : 1}',
                        ),
                        trailing: Text(
                          formatter.format(_produitsVendus.isNotEmpty ? _produitsVendus[0].totale : 0),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_produitsVendus.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '+ ${_produitsVendus.length - 1} autres produits',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ] else ...[
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircularProgressIndicator(),
                        title: Text('Chargement...'),
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total à payer:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formatter.format(totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Méthodes de paiement
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Méthode de paiement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Options de paiement
                    RadioListTile<PaymentMethod>(
                      title: const Row(
                        children: [
                          Icon(Icons.credit_card),
                          SizedBox(width: 8),
                          Text('Carte de crédit'),
                        ],
                      ),
                      value: PaymentMethod.creditCard,
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),

                    RadioListTile<PaymentMethod>(
                      title: const Row(
                        children: [
                          Icon(Icons.money),
                          SizedBox(width: 8),
                          Text('Paiement en espèces à la livraison'),
                        ],
                      ),
                      value: PaymentMethod.cash,
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Formulaire de carte de crédit
            if (_selectedMethod == PaymentMethod.creditCard)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de carte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Numéro de carte
                      TextField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de carte',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                        onChanged: (value) {
                          // Formater le numéro de carte avec des espaces tous les 4 chiffres
                          if (value.isNotEmpty &&
                              value.length % 5 == 0 &&
                              !value.endsWith(' ')) {
                            _cardNumberController.text =
                                '${value.substring(0, value.length - 1)} ${value.substring(value.length - 1)}';
                            _cardNumberController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: _cardNumberController.text.length,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nom du titulaire
                      TextField(
                        controller: _cardHolderController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du titulaire',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Date d'expiration et CVV
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _expiryDateController,
                              decoration: const InputDecoration(
                                labelText: 'Date d\'expiration (MM/AA)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              onChanged: (value) {
                                // Formater la date d'expiration (MM/AA)
                                if (value.length == 2 && !value.contains('/')) {
                                  _expiryDateController.text = '$value/';
                                  _expiryDateController
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _expiryDateController.text.length,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.security),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Message d'erreur
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Bouton de paiement
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child:
                  _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                        _selectedMethod == PaymentMethod.creditCard
                            ? 'Payer ${formatter.format(totalPrice)}'
                            : 'Confirmer le paiement à la livraison',
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}
