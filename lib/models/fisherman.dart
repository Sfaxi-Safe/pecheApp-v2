class Fisherman {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String? cin;
  final String? matricule;
  final String? capacite;
  final String? longeur;
  final String? largeur;
  final String? bateau;
  final String? pays;
  final String? proprietaire;
  final String? serie;
  final String? certification;
  final String? port;
  final String? engin;
  final String? telephone;
  final bool? isValid;

  Fisherman({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    this.cin,
    this.matricule,
    this.capacite,
    this.longeur,
    this.largeur,
    this.bateau,
    this.pays,
    this.proprietaire,
    this.serie,
    this.certification,
    this.port,
    this.engin,
    this.telephone,
    this.isValid,
  });

  // Convertir un objet Fisherman en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'cin': cin,
      'matricule': matricule,
      'capacite': capacite,
      'longeur': longeur,
      'largeur': largeur,
      'bateau': bateau,
      'pays': pays,
      'proprietaire': proprietaire,
      'serie': serie,
      'certification': certification,
      'port': port,
      'engin': engin,
      'telephone': telephone,
      'isValid': isValid,
    };
  }

  // Créer un objet Fisherman à partir d'un Map
  factory Fisherman.fromMap(Map<String, dynamic> map) {
    return Fisherman(
      id: map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      cin: map['cin'],
      matricule: map['matricule'],
      capacite: map['capacite'],
      longeur: map['longeur'],
      largeur: map['largeur'],
      bateau: map['bateau'],
      pays: map['pays'],
      proprietaire: map['proprietaire'],
      serie: map['serie'],
      certification: map['certification'],
      port: map['port'],
      engin: map['engin'],
      telephone: map['telephone']?.toString(),
      isValid: map['is_valid'] == 1,
    );
  }
}
