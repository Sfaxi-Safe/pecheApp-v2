import 'marketplace_image.dart';

/// Représente une prise de pêche dans le système, correspondant à la table `marketplace_prise` dans la base de données.
class MarketplacePrise {
  final int? id;
  final String espece;
  final double poids;
  final DateTime datePeche;
  final String? lieu;
  final String? description;
  final int? pecheurId;
  final List<MarketplaceImage> images;

  MarketplacePrise({
    this.id,
    required this.espece,
    required this.poids,
    required this.datePeche,
    this.lieu,
    this.description,
    this.pecheurId,
    this.images = const [],
  });

  /// Crée une nouvelle prise
  factory MarketplacePrise.create({
    required String espece,
    required double poids,
    required DateTime datePeche,
    String? lieu,
    String? description,
    int? pecheurId,
    List<MarketplaceImage> images = const [],
  }) {
    return MarketplacePrise(
      espece: espece,
      poids: poids,
      datePeche: datePeche,
      lieu: lieu,
      description: description,
      pecheurId: pecheurId,
      images: images,
    );
  }

  /// Convertit une prise en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'espece': espece,
      'poids': poids,
      'date_peche': datePeche.toIso8601String(),
      if (lieu != null) 'lieu': lieu,
      if (description != null) 'description': description,
      if (pecheurId != null) 'pecheur_id': pecheurId,
    };
  }

  /// Crée une prise à partir d'un Map de SQLite
  factory MarketplacePrise.fromMap(
    Map<String, dynamic> map, {
    List<MarketplaceImage> images = const [],
  }) {
    return MarketplacePrise(
      id: map['id'],
      espece: map['espece'] ?? '',
      poids: map['poids'] ?? 0.0,
      datePeche: map['date_peche'] != null 
          ? DateTime.parse(map['date_peche']) 
          : DateTime.now(),
      lieu: map['lieu'],
      description: map['description'],
      pecheurId: map['pecheur_id'],
      images: images,
    );
  }

  /// Crée une copie de la prise avec des modifications
  MarketplacePrise copyWith({
    int? id,
    String? espece,
    double? poids,
    DateTime? datePeche,
    String? lieu,
    String? description,
    int? pecheurId,
    List<MarketplaceImage>? images,
  }) {
    return MarketplacePrise(
      id: id ?? this.id,
      espece: espece ?? this.espece,
      poids: poids ?? this.poids,
      datePeche: datePeche ?? this.datePeche,
      lieu: lieu ?? this.lieu,
      description: description ?? this.description,
      pecheurId: pecheurId ?? this.pecheurId,
      images: images ?? this.images,
    );
  }

  /// Ajoute une image à la prise
  MarketplacePrise addImage(MarketplaceImage image) {
    final newImages = List<MarketplaceImage>.from(images);
    newImages.add(image);
    return copyWith(images: newImages);
  }

  /// Obtient l'URL de la première image ou une image par défaut
  String get imageUrl => images.isNotEmpty 
      ? images.first.url 
      : 'assets/images/default_catch.png';
}
