import 'package:seatrace/models/user.dart';

/// DTO (Data Transfer Object) pour l'utilisateur
/// Utilisé pour standardiser les échanges de données entre le frontend et le backend
class UserDto {
  final String id;
  final String email;
  final List<String> roles;
  final String nom;
  final String prenom;
  final String? telephone;
  final String? photo;
  final bool isValidated;
  final bool isBlocked;

  UserDto({
    required this.id,
    required this.email,
    required this.roles,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.photo,
    required this.isValidated,
    this.isBlocked = false,
  });

  /// Crée un UserDto à partir d'un Map (JSON)
  factory UserDto.fromJson(Map<String, dynamic> json) {
    // Gérer les différents formats de rôles (string ou liste)
    List<String> parseRoles(dynamic roles) {
      if (roles is List) {
        return List<String>.from(roles);
      } else if (roles is String) {
        return roles.split(',');
      }
      return [];
    }

    return UserDto(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      roles: parseRoles(json['roles'] ?? json['role'] ?? []),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone']?.toString(),
      photo: json['photo'],
      isValidated: json['isValidated'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  /// Convertit le DTO en modèle User
  User toUser() {
    return User(
      id: id,
      email: email,
      roles: roles.join(','),
      password: '', // Le mot de passe n'est pas inclus dans le DTO
      nom: nom,
      prenom: prenom,
      telephone: telephone,
      photo: photo,
      isValidated: isValidated,
      isBlocked: isBlocked,
    );
  }

  /// Convertit le DTO en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'roles': roles,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'photo': photo,
      'isValidated': isValidated,
      'isBlocked': isBlocked,
    };
  }

  /// Crée une copie du DTO avec des valeurs modifiées
  UserDto copyWith({
    String? id,
    String? email,
    List<String>? roles,
    String? nom,
    String? prenom,
    String? telephone,
    String? photo,
    bool? isValidated,
    bool? isBlocked,
  }) {
    return UserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      telephone: telephone ?? this.telephone,
      photo: photo ?? this.photo,
      isValidated: isValidated ?? this.isValidated,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
