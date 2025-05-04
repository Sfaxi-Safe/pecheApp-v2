/// Modèle représentant une notification dans l'application
class Notification {
  /// Identifiant unique de la notification
  final String id;
  
  /// Identifiant du destinataire
  final String destinataire;
  
  /// Modèle du destinataire (Pecheur, Veterinaire, Maryeur, Client, Admin)
  final String destinataireModel;
  
  /// Titre de la notification
  final String titre;
  
  /// Contenu de la notification
  final String contenu;
  
  /// Type de notification (info, success, warning, error)
  final String type;
  
  /// Indique si la notification a été lue
  final bool lue;
  
  /// Référence à l'objet concerné (optionnel)
  final String? reference;
  
  /// Modèle de la référence (Prise, Lot, Espece)
  final String? referenceModel;
  
  /// URL d'action (optionnel)
  final String? urlAction;
  
  /// Date de création
  final DateTime createdAt;
  
  /// Date de mise à jour
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.destinataire,
    required this.destinataireModel,
    required this.titre,
    required this.contenu,
    required this.type,
    required this.lue,
    this.reference,
    this.referenceModel,
    this.urlAction,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une instance à partir d'une map
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['_id'] ?? map['id'] ?? '',
      destinataire: map['destinataire'] ?? '',
      destinataireModel: map['destinataireModel'] ?? '',
      titre: map['titre'] ?? '',
      contenu: map['contenu'] ?? '',
      type: map['type'] ?? 'info',
      lue: map['lue'] ?? false,
      reference: map['reference'],
      referenceModel: map['referenceModel'],
      urlAction: map['urlAction'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convertit l'instance en map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destinataire': destinataire,
      'destinataireModel': destinataireModel,
      'titre': titre,
      'contenu': contenu,
      'type': type,
      'lue': lue,
      'reference': reference,
      'referenceModel': referenceModel,
      'urlAction': urlAction,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée une copie de l'instance avec les propriétés spécifiées
  Notification copyWith({
    String? id,
    String? destinataire,
    String? destinataireModel,
    String? titre,
    String? contenu,
    String? type,
    bool? lue,
    String? reference,
    String? referenceModel,
    String? urlAction,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      destinataire: destinataire ?? this.destinataire,
      destinataireModel: destinataireModel ?? this.destinataireModel,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      type: type ?? this.type,
      lue: lue ?? this.lue,
      reference: reference ?? this.reference,
      referenceModel: referenceModel ?? this.referenceModel,
      urlAction: urlAction ?? this.urlAction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, titre: $titre, lue: $lue)';
  }
}
