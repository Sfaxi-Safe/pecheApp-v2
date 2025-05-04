import 'package:seatrace/utils/error_handler.dart';

class User {
  final String id;
  final String email;
  final String roles;
  final String password;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? service;
  final String? fonction;
  final String? photo;
  final bool isValidated;
  final bool isBlocked;

  User({
    required this.id,
    required this.email,
    required this.roles,
    required this.password,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.service,
    this.fonction,
    this.photo,
    this.isValidated = false,
    this.isBlocked = false,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    // Journaliser les données reçues pour le débogage
    ErrorHandler.instance.logInfo(
      'Création d\'un utilisateur à partir des données: ${map.toString()}',
      context: 'User.fromMap',
    );

    final user = User(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      email: map['email'] ?? '',
      roles: map['roles'] ?? '',
      password: map['password'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      telephone: map['telephone']?.toString(),
      service: map['service'],
      fonction: map['fonction'],
      photo: map['photo'],
      isValidated: map['isValidated'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
    );

    // Vérifier si les informations essentielles sont présentes
    if (user.nom.isEmpty || user.prenom.isEmpty) {
      ErrorHandler.instance.logWarning(
        'Utilisateur créé avec des informations incomplètes: nom=${user.nom}, prenom=${user.prenom}',
        context: 'User.fromMap',
      );
    }

    return user;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'roles': roles,
      'password': password,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'service': service,
      'fonction': fonction,
      'photo': photo,
      'isValidated': isValidated,
      'isBlocked': isBlocked,
    }..removeWhere((key, value) => value == null);
  }

  // Helper methods to check user role
  bool isPecheur() {
    return roles.contains('ROLE_PECHEUR');
  }

  bool isVeterinaire() {
    return roles.contains('ROLE_VETERINAIRE');
  }

  bool isMaryeur() {
    return roles.contains('ROLE_MARYEUR');
  }

  bool isClient() {
    return roles.contains('ROLE_CLIENT');
  }

  bool isAdmin() {
    return roles.contains('ROLE_ADMIN');
  }
}
