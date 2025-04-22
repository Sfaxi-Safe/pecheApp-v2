class Espece {
  final int? id;
  final String nom;
  final String? imageUrl;

  Espece({
    this.id,
    required this.nom,
    this.imageUrl,
  });

  factory Espece.fromMap(Map<String, dynamic> map) {
    return Espece(
      id: map['id'],
      nom: map['nom'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'image_url': imageUrl,
    };
  }
}
