import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/error_handler.dart';
import '../dtos/user_dto.dart';
import '../dtos/espece_dto.dart';
import '../dtos/prise_dto.dart';
import '../dtos/lot_dto.dart';
import '../services/dto_service.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  final String baseUrl = 'http://localhost:3000/api';
  String? _authToken;

  ApiService._init();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Méthodes génériques CRUD
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      // Journaliser la requête
      ErrorHandler.instance.logInfo(
        'GET request: $endpoint',
        context: 'ApiService',
      );

      // Ajouter un timeout pour éviter les attentes infinies
      final response = await http
          .get(Uri.parse('$baseUrl/$endpoint'), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'La requête a pris trop de temps à s\'exécuter',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }

      throw _createAppError(response, 'GET', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      throw AppError(
        message:
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        type: ErrorType.network,
        originalError: e,
      );
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      throw AppError(
        message: 'La requête a pris trop de temps. Veuillez réessayer.',
        type: ErrorType.network,
        originalError: e,
      );
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      throw AppError(
        message: 'Erreur de format de données reçues du serveur.',
        type: ErrorType.server,
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Erreur lors de la requête GET: ${e.toString()}',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      // Journaliser la requête
      ErrorHandler.instance.logInfo(
        'POST request: $endpoint',
        context: 'ApiService',
      );

      // Ajouter un timeout pour éviter les attentes infinies
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'La requête a pris trop de temps à s\'exécuter',
              );
            },
          );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      }

      throw _createAppError(response, 'POST', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.post($endpoint)');
      throw AppError(
        message:
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        type: ErrorType.network,
        originalError: e,
      );
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.post($endpoint)');
      throw AppError(
        message: 'La requête a pris trop de temps. Veuillez réessayer.',
        type: ErrorType.network,
        originalError: e,
      );
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.post($endpoint)');
      throw AppError(
        message: 'Erreur de format de données reçues du serveur.',
        type: ErrorType.server,
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.post($endpoint)');
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Erreur lors de la requête POST: ${e.toString()}',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      // Journaliser la requête
      ErrorHandler.instance.logInfo(
        'PUT request: $endpoint',
        context: 'ApiService',
      );

      // Ajouter un timeout pour éviter les attentes infinies
      final response = await http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'La requête a pris trop de temps à s\'exécuter',
              );
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      }

      throw _createAppError(response, 'PUT', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      throw AppError(
        message:
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        type: ErrorType.network,
        originalError: e,
      );
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      throw AppError(
        message: 'La requête a pris trop de temps. Veuillez réessayer.',
        type: ErrorType.network,
        originalError: e,
      );
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      throw AppError(
        message: 'Erreur de format de données reçues du serveur.',
        type: ErrorType.server,
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Erreur lors de la requête PUT: ${e.toString()}',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      // Journaliser la requête
      ErrorHandler.instance.logInfo(
        'DELETE request: $endpoint',
        context: 'ApiService',
      );

      // Ajouter un timeout pour éviter les attentes infinies
      final response = await http
          .delete(Uri.parse('$baseUrl/$endpoint'), headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'La requête a pris trop de temps à s\'exécuter',
              );
            },
          );

      if (response.statusCode != 200) {
        throw _createAppError(response, 'DELETE', endpoint);
      }
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.delete($endpoint)',
      );
      throw AppError(
        message:
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        type: ErrorType.network,
        originalError: e,
      );
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.delete($endpoint)',
      );
      throw AppError(
        message: 'La requête a pris trop de temps. Veuillez réessayer.',
        type: ErrorType.network,
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.delete($endpoint)',
      );
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Erreur lors de la suppression: ${e.toString()}',
        type: ErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// Crée une AppError à partir d'une réponse HTTP
  AppError _createAppError(
    http.Response response,
    String method,
    String endpoint,
  ) {
    try {
      final Map<String, dynamic> body = json.decode(response.body);
      final message =
          body['message'] ?? body['error'] ?? 'Une erreur est survenue';

      ErrorType errorType;
      switch (response.statusCode) {
        case 400:
          errorType = ErrorType.validation;
          break;
        case 401:
          errorType = ErrorType.authentication;
          break;
        case 403:
          errorType = ErrorType.authorization;
          break;
        case 404:
          errorType = ErrorType.notFound;
          break;
        case 422:
          errorType = ErrorType.validation;
          break;
        case 500:
        case 502:
        case 503:
        case 504:
          errorType = ErrorType.server;
          break;
        default:
          errorType = ErrorType.unknown;
      }

      return AppError(
        message: message,
        type: errorType,
        originalError: response,
        context: 'ApiService.$method($endpoint)',
      );
    } catch (e) {
      return AppError(
        message: 'Erreur ${response.statusCode}: ${response.reasonPhrase}',
        type: ErrorType.unknown,
        originalError: response,
        context: 'ApiService.$method($endpoint)',
      );
    }
  }

  // Méthodes spécifiques pour les utilisateurs
  Future<List<Map<String, dynamic>>> getUsers(String role) async {
    final response = await get('users?role=$role');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getUserById(dynamic id) async {
    return await get('users/$id');
  }

  // Méthodes pour obtenir des DTOs (pour une transition progressive)
  Future<List<UserDto>> getUserDtos(String role) async {
    final response = await get('users?role=$role');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => UserDto.fromJson(json)).toList();
  }

  Future<UserDto> getUserDtoById(String id) async {
    final response = await get('users/$id');
    return UserDto.fromJson(response);
  }

  // Méthodes spécifiques pour les lots
  Future<List<Map<String, dynamic>>> getLotsByPecheurId(
    dynamic pecheurId,
  ) async {
    final response = await get('lots/pecheur/$pecheurId');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getAvailableAuctions() async {
    final response = await get('lots/available');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getAuctionDetails(dynamic auctionId) async {
    return await get('lots/$auctionId');
  }

  Future<Map<String, dynamic>> getPriseDetails(dynamic priseId) async {
    return await get('prises/$priseId');
  }

  Future<Map<String, dynamic>> getPecheurDetails(dynamic pecheurId) async {
    return await get('pecheurs/$pecheurId');
  }

  Future<Map<String, dynamic>> getVeterinaireDetails(
    dynamic veterinaireId,
  ) async {
    return await get('veterinaires/$veterinaireId');
  }

  Future<Map<String, dynamic>> getMaryeurDetails(dynamic maryeurId) async {
    return await get('maryeurs/$maryeurId');
  }

  // Méthodes pour obtenir des DTOs (pour une transition progressive)
  Future<List<LotDto>> getLotDtosByPecheurId(String pecheurId) async {
    final response = await get('lots/pecheur/$pecheurId');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => LotDto.fromJson(json)).toList();
  }

  Future<List<LotDto>> getAvailableAuctionDtos() async {
    final response = await get('lots/available');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => LotDto.fromJson(json)).toList();
  }

  Future<LotDto> getAuctionDtoDetails(String auctionId) async {
    final response = await get('lots/$auctionId');
    return LotDto.fromJson(response);
  }

  Future<PriseDto> getPriseDtoDetails(String priseId) async {
    final response = await get('prises/$priseId');
    return PriseDto.fromJson(response);
  }

  Future<UserDto> getPecheurDtoDetails(String pecheurId) async {
    final response = await get('pecheurs/$pecheurId');
    return UserDto.fromJson(response);
  }

  Future<UserDto> getVeterinaireDtoDetails(String veterinaireId) async {
    final response = await get('veterinaires/$veterinaireId');
    return UserDto.fromJson(response);
  }

  Future<UserDto> getMaryeurDtoDetails(String maryeurId) async {
    final response = await get('maryeurs/$maryeurId');
    return UserDto.fromJson(response);
  }

  Future<void> placeBid(
    dynamic auctionId,
    double bidAmount,
    dynamic userId,
  ) async {
    await post('lots/$auctionId/bid', {'amount': bidAmount, 'userId': userId});
  }

  // Méthodes spécifiques pour les espèces de poissons
  Future<Map<String, dynamic>> getEspeceByNom(String nom) async {
    final response = await get('especes/nom/$nom');
    return response;
  }

  Future<List<Map<String, dynamic>>> getAllEspeces() async {
    final response = await get('especes');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  Future<Map<String, dynamic>> createEspece(
    String nom, {
    String? imageUrl,
  }) async {
    return await post('especes', {'nom': nom, 'image_url': imageUrl});
  }

  // Méthodes spécifiques pour l'authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await post('auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('auth/register', userData);
  }

  // Méthodes pour les statistiques
  Future<Map<String, dynamic>> getDashboardStats() async {
    return await get('stats/dashboard');
  }

  Future<Map<String, dynamic>> getPecheurStats(dynamic pecheurId) async {
    return await get('stats/pecheur/$pecheurId');
  }

  Future<Map<String, dynamic>> getMaryeurStats(dynamic maryeurId) async {
    return await get('stats/maryeur/$maryeurId');
  }

  // Méthode pour récupérer les achats d'un client
  Future<List<Map<String, dynamic>>> getMyPurchases() async {
    final response = await get('purchases/me');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  // Alias pour getVeterinaireDetails pour corriger l'erreur d'orthographe
  Future<Map<String, dynamic>> getVitirinaireDetails(
    dynamic veterinaireId,
  ) async {
    return await get('veterinaires/$veterinaireId');
  }
}
