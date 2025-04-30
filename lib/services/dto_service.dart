import 'package:flutter/foundation.dart';
import 'package:seatrace/dtos/user_dto.dart';
import 'package:seatrace/dtos/espece_dto.dart';
import 'package:seatrace/dtos/prise_dto.dart';
import 'package:seatrace/dtos/lot_dto.dart';
import 'package:seatrace/models/user.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/models/prise.dart';
import 'package:seatrace/models/lot.dart';

/// Service pour convertir les données entre les modèles et les DTOs
class DtoService {
  static final DtoService instance = DtoService._internal();
  
  DtoService._internal();
  
  /// Convertit un Map (JSON) en UserDto
  UserDto jsonToUserDto(Map<String, dynamic> json) {
    try {
      return UserDto.fromJson(json);
    } catch (e) {
      debugPrint('Erreur lors de la conversion JSON -> UserDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un User en UserDto
  UserDto userToDto(User user) {
    try {
      List<String> roles = [];
      if (user.roles.isNotEmpty) {
        roles = user.roles.split(',');
      }
      
      return UserDto(
        id: user.id,
        email: user.email,
        roles: roles,
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone,
        photo: user.photo,
        isValidated: user.isValidated,
        isBlocked: user.isBlocked,
      );
    } catch (e) {
      debugPrint('Erreur lors de la conversion User -> UserDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un Map (JSON) en EspeceDto
  EspeceDto jsonToEspeceDto(Map<String, dynamic> json) {
    try {
      return EspeceDto.fromJson(json);
    } catch (e) {
      debugPrint('Erreur lors de la conversion JSON -> EspeceDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un Espece en EspeceDto
  EspeceDto especeToDto(Espece espece) {
    try {
      return EspeceDto(
        id: espece.id,
        nom: espece.nom,
        description: espece.description,
        photo: espece.photo,
        prixMinimal: espece.prixMinimal,
        prixMoyen: espece.prixMoyen,
        isActive: espece.isActive,
      );
    } catch (e) {
      debugPrint('Erreur lors de la conversion Espece -> EspeceDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un Map (JSON) en PriseDto
  PriseDto jsonToPriseDto(Map<String, dynamic> json) {
    try {
      return PriseDto.fromJson(json);
    } catch (e) {
      debugPrint('Erreur lors de la conversion JSON -> PriseDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un Prise en PriseDto
  PriseDto priseToDto(Prise prise) {
    try {
      return PriseDto(
        id: prise.id,
        pecheurId: prise.pecheurId,
        date: prise.date,
        lieu: prise.lieu,
        latitude: prise.latitude,
        longitude: prise.longitude,
        description: prise.description,
        photo: prise.photo,
        isValid: prise.isValid,
      );
    } catch (e) {
      debugPrint('Erreur lors de la conversion Prise -> PriseDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un Map (JSON) en LotDto
  LotDto jsonToLotDto(Map<String, dynamic> json) {
    try {
      return LotDto.fromJson(json);
    } catch (e) {
      debugPrint('Erreur lors de la conversion JSON -> LotDto: $e');
      rethrow;
    }
  }
  
  /// Convertit un Lot en LotDto
  LotDto lotToDto(Lot lot) {
    try {
      return LotDto(
        id: lot.id,
        identifiant: lot.identifiant,
        photo: lot.photo,
        quantite: lot.quantite,
        poids: lot.poids,
        espece: lot.espece,
        temperature: lot.temperature,
        dateTest: lot.dateTest,
        test: lot.test,
        status: lot.status,
        vendu: lot.vendu,
        priseId: lot.priseId,
        userId: lot.userId,
        dateSoumission: lot.dateSoumission,
        isProduit: lot.isProduit,
        prixInitial: lot.prixInitial,
        prixMinimal: lot.prixMinimal,
        prixFinal: lot.prixFinal,
        acheteurId: lot.acheteurId,
      );
    } catch (e) {
      debugPrint('Erreur lors de la conversion Lot -> LotDto: $e');
      rethrow;
    }
  }
  
  /// Convertit une liste de Map (JSON) en liste de DTOs
  List<T> jsonListToDtoList<T>(List<dynamic> jsonList, T Function(Map<String, dynamic>) converter) {
    try {
      return jsonList.map((json) => converter(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la conversion JSON List -> DTO List: $e');
      rethrow;
    }
  }
}
