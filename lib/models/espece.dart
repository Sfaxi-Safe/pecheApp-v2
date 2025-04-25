class Espece {
  final String? id; // Changé de int? à String? pour Firebase
  final String nom;
  final String? imageUrl;

  Espece({this.id, required this.nom, this.imageUrl});

  factory Espece.fromMap(Map<String, dynamic> map) {
    return Espece(
      id: map['id'],
      nom: map['nom'],
      imageUrl:
          map['image_url'] ??
          map['imageUrl'], // Gérer les deux formats de noms de champs
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'imageUrl': imageUrl, // Utiliser le format Firebase
    };
  }

  @override
  String toString() {
    return 'Espece{id: $id, nom: $nom, imageUrl: $imageUrl}';
  }
}
