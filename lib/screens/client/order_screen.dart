import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_produitvendus.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/services/order_service.dart';
import 'package:peche_app/services/payment_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  final String fishId;

  const OrderScreen({super.key, required this.fishId});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final fishService = Provider.of<FishService>(context, listen: false);
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final fish = fishService.getFishById(widget.fishId);
      final user = authService.currentUser;

      if (fish == null || user == null || user.id == null) {
        setState(() {
          _isSubmitting = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la commande'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final quantity = int.tryParse(_quantityController.text) ?? 0;

      try {
        // Ajouter au panier
        final success = await paymentService.addToCart(
          userId: user.id!,
          produitId: fish.id!,
          quantite: quantity,
        );

        if (success) {
          // Créer la commande à partir du panier
          final orderSuccess = await paymentService.createOrderFromCart(
            userId: user.id!,
            methodeDePaiement: 'Carte bancaire',
            commentaire: _notesController.text.trim(),
            fournisseurId: fish.pecheurId ?? 0,
          );

          setState(() {
            _isSubmitting = false;
          });

          if (!mounted) return;

          if (orderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Commande passée avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la création de la commande'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          setState(() {
            _isSubmitting = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ajout au panier'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  double get _totalPrice {
    final fishService = Provider.of<FishService>(context, listen: false);
    final fish = fishService.getFishById(widget.fishId);
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    return quantity * (fish?.prix ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final fishService = Provider.of<FishService>(context);
    final fish = fishService.getFishById(widget.fishId);

    if (fish == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Commander'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Poisson non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Commander'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations sur le poisson
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: fish.images.isNotEmpty
                            ? Image.network(
                                fish.images.first.url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/fish_placeholder.jpg',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/fish_placeholder.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fish.nom,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stock disponible: ${fish.stock} kg',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Prix: ${fish.prix.toStringAsFixed(2)} €/kg',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quantité
              const Text(
                'Quantité (kg)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  hintText: 'Entrez la quantité en kg',
                  border: OutlineInputBorder(),
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (quantity <= 0) {
                    return 'La quantité doit être supérieure à 0';
                  }
                  if (quantity > fish.stock) {
                    return 'La quantité ne peut pas dépasser ${fish.stock} kg';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    // Mettre à jour le prix total
                  });
                },
              ),
              const SizedBox(height: 24),

              // Adresse de livraison
              const Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Entrez votre adresse de livraison',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer  {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse de livraison';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Notes
              const Text(
                'Notes (facultatif)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Instructions spéciales, préférences, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Récapitulatif de la commande
              const Text(
                'Récapitulatif',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppTheme.primaryColor.withAlpha(25),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Produit',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Text(
                            fish.nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prix unitaire',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Text(
                            '${fish.prix.toStringAsFixed(2)} €/kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quantité',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Text(
                            '${_quantityController.text} kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '${_totalPrice.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de commande
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmer la commande',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
