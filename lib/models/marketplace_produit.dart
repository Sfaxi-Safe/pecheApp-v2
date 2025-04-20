import 'marketplace_categorie.dart';
import 'marketplace_image.dart';

/// Représente un produit dans le système, correspondant à la table `marketplace_produit` dans la base de données.
class MarketplaceProduit {
  final int? id;
  final String nom;
  final String description;
  final double prix;
  final int stock;
  final int? categorieId;
  final int? pecheurId;
  final int? priseId;
  final List<MarketplaceImage> images;
  final MarketplaceCategorie? categorie;

  MarketplaceProduit({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.stock,
    this.categorieId,
    this.pecheurId,
    this.priseId,
    this.images = const [],
    this.categorie,
  });

  /// Crée un nouveau produit
  factory MarketplaceProduit.create({
    required String nom,
    required String description,
    required double prix,
    required int stock,
    int? categorieId,
    int? pecheurId,
    int? priseId,
    List<MarketplaceImage> images = const [],
    MarketplaceCategorie? categorie,
  }) {
    return MarketplaceProduit(
      nom: nom,
      description: description,
      prix: prix,
      stock: stock,
      categorieId: categorieId,
      pecheurId: pecheurId,
      priseId: priseId,
      images: images,
      categorie: categorie,
    );
  }

  /// Convertit un produit en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'stock': stock,
      if (categorieId != null) 'categorie_id': categorieId,
      if (pecheurId != null) 'pecheur_id': pecheurId,
      if (priseId != null) 'prise_id': priseId,
    };
  }

  /// Crée un produit à partir d'un Map de SQLite
  factory MarketplaceProduit.fromMap(
    Map<String, dynamic> map, {
    List<MarketplaceImage> images = const [],
    MarketplaceCategorie? categorie,
  }) {
    return MarketplaceProduit(
      id: map['id'],
      nom: map['nom'] ?? '',
      description: map['description'] ?? '',
      prix: map['prix'] ?? 0.0,
      stock: map['stock'] ?? 0,
      categorieId: map['categorie_id'],
      pecheurId: map['pecheur_id'],
      priseId: map['prise_id'],
      images: images,
      categorie: categorie,
    );
  }

  /// Crée une copie du produit avec des modifications
  MarketplaceProduit copyWith({
    int? id,
    String? nom,
    String? description,
    double? prix,
    int? stock,
    int? categorieId,
    int? pecheurId,
    int? priseId,
    List<MarketplaceImage>? images,
    MarketplaceCategorie? categorie,
  }) {
    return MarketplaceProduit(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      stock: stock ?? this.stock,
      categorieId: categorieId ?? this.categorieId,
      pecheurId: pecheurId ?? this.pecheurId,
      priseId: priseId ?? this.priseId,
      images: images ?? this.images,
      categorie: categorie ?? this.categorie,
    );
  }

  /// Ajoute une image au produit
  MarketplaceProduit addImage(MarketplaceImage image) {
    final newImages = List<MarketplaceImage>.from(images);
    newImages.add(image);
    return copyWith(images: newImages);
  }

  /// Vérifie si le produit est en stock
  bool get isInStock => stock > 0;

  /// Obtient l'URL de la première image ou une image par défaut
  String get imageUrl => images.isNotEmpty 
      ? images.first.url 
      : 'assets/images/default_product.png';
}
