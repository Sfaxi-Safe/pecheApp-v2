/// Représente un salon de discussion dans le système, correspondant à la table `marketplace_salon` dans la base de données.
class MarketplaceSalon {
  final int? id;
  final String titre;
  final String description;
  final DateTime date;
  final DateTime tempsDebut;
  final DateTime tempsFin;
  final String lieu;
  final int maxInvitation;
  final String affiche;

  MarketplaceSalon({
    this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.tempsDebut,
    required this.tempsFin,
    required this.lieu,
    required this.maxInvitation,
    required this.affiche,
  });

  /// Crée un nouveau salon
  factory MarketplaceSalon.create({
    required String titre,
    required String description,
    required DateTime date,
    required DateTime tempsDebut,
    required DateTime tempsFin,
    required String lieu,
    required int maxInvitation,
    required String affiche,
  }) {
    return MarketplaceSalon(
      titre: titre,
      description: description,
      date: date,
      tempsDebut: tempsDebut,
      tempsFin: tempsFin,
      lieu: lieu,
      maxInvitation: maxInvitation,
      affiche: affiche,
    );
  }

  /// Convertit un salon en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'description': description,
      'date': date.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'temps_debut': '${tempsDebut.hour.toString().padLeft(2, '0')}:${tempsDebut.minute.toString().padLeft(2, '0')}:${tempsDebut.second.toString().padLeft(2, '0')}', // Format HH:MM:SS
      'temps_fin': '${tempsFin.hour.toString().padLeft(2, '0')}:${tempsFin.minute.toString().padLeft(2, '0')}:${tempsFin.second.toString().padLeft(2, '0')}', // Format HH:MM:SS
      'lieu': lieu,
      'max_invitation': maxInvitation,
      'affiche': affiche,
    };
  }

  /// Crée un salon à partir d'un Map de SQLite
  factory MarketplaceSalon.fromMap(Map<String, dynamic> map) {
    // Fonction pour parser une heure au format HH:MM:SS
    DateTime parseTime(String timeStr, DateTime date) {
      final parts = timeStr.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        parts.length > 2 ? int.parse(parts[2]) : 0,
      );
    }

    final date = DateTime.parse(map['date']);
    
    return MarketplaceSalon(
      id: map['id'],
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      date: date,
      tempsDebut: parseTime(map['temps_debut'], date),
      tempsFin: parseTime(map['temps_fin'], date),
      lieu: map['lieu'] ?? '',
      maxInvitation: map['max_invitation'] ?? 0,
      affiche: map['affiche'] ?? '',
    );
  }

  /// Crée une copie du salon avec des modifications
  MarketplaceSalon copyWith({
    int? id,
    String? titre,
    String? description,
    DateTime? date,
    DateTime? tempsDebut,
    DateTime? tempsFin,
    String? lieu,
    int? maxInvitation,
    String? affiche,
  }) {
    return MarketplaceSalon(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      date: date ?? this.date,
      tempsDebut: tempsDebut ?? this.tempsDebut,
      tempsFin: tempsFin ?? this.tempsFin,
      lieu: lieu ?? this.lieu,
      maxInvitation: maxInvitation ?? this.maxInvitation,
      affiche: affiche ?? this.affiche,
    );
  }
}
