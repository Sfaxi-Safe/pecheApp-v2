import 'package:flutter/material.dart';
import 'package:peche_app/models/marketplace_avis.dart';
import 'package:peche_app/services/auth_service.dart';
import 'package:peche_app/services/fish_service.dart';
import 'package:peche_app/utils/app_theme.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  final String fishId;

  const ReviewScreen({super.key, required this.fishId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final fishService = Provider.of<FishService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) {
        setState(() {
          _isSubmitting = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour laisser un avis'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final review = MarketplaceAvis(
        produitId: int.tryParse(widget.fishId),
        userId: int.tryParse(user.id.toString()),
        etoileNb: _rating.toInt(),
        commentaire: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await fishService.addReview(review);

      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avis ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fishService = Provider.of<FishService>(context);
    final fish = fishService.getFishById(widget.fishId);

    if (fish == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ajouter un avis'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Poisson non trouvé')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un avis'),
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
                        child: Image.asset(
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
                              'Prix: ${fish.prix} €/kg',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Stock: ${fish.stock} kg',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
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

              // Note
              const Text(
                'Votre note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < _rating.floor()
                            ? Icons.star
                            : index < _rating
                            ? Icons.star_half
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _rating.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Commentaire
              const Text(
                'Votre commentaire',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un commentaire';
                  }
                  if (value.length < 10) {
                    return 'Le commentaire doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Soumettre l\'avis',
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
