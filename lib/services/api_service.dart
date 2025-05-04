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
  // URL de l'API
  late String baseUrl;
  String? _authToken;

  // Constructeur privé qui initialise l'URL de l'API
  ApiService._init() {
    // Adresse IP de votre ordinateur pour les tests sur appareil physique
    const String physicalDeviceUrl =
        'http://192.168.3.233:3005/api'; // Adresse IP de votre carte Wi-Fi
    const String emulatorUrl = 'http://10.0.2.2:3005/api';

    // Utilisez l'URL appropriée selon le contexte
    // Décommentez la ligne ci-dessous pour utiliser l'émulateur
    // baseUrl = emulatorUrl;

    // Décommentez la ligne ci-dessous pour utiliser un appareil physique
    baseUrl =
        physicalDeviceUrl; // ⚠️ N'oubliez pas de remplacer X par votre adresse IP
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  bool hasToken() {
    return _authToken != null && _authToken!.isNotEmpty;
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

      // Gérer spécifiquement les erreurs 404 pour certaines routes
      if (response.statusCode == 404) {
        ErrorHandler.instance.logError(
          'Route non trouvée: $endpoint',
          context: 'ApiService.get',
        );

        // Pour les routes de recherche ou de liste, retourner un résultat vide au lieu de lancer une exception
        if (endpoint.contains('search') ||
            endpoint.contains('available') ||
            endpoint.contains('featured') ||
            endpoint.contains('purchases/me')) {
          return {'success': true, 'data': []};
        }
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
            const Duration(
              seconds: 60,
            ), // Augmenter le délai d'attente à 60 secondes
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

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      // Journaliser la requête
      ErrorHandler.instance.logInfo(
        'PATCH request: $endpoint',
        context: 'ApiService',
      );

      // Ajouter un timeout pour éviter les attentes infinies
      final response = await http
          .patch(
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

      throw _createAppError(response, 'PATCH', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      throw AppError(
        message:
            'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        type: ErrorType.network,
        originalError: e,
      );
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      throw AppError(
        message: 'La requête a pris trop de temps. Veuillez réessayer.',
        type: ErrorType.network,
        originalError: e,
      );
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      throw AppError(
        message: 'Erreur de format de données reçues du serveur.',
        type: ErrorType.server,
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        message: 'Erreur lors de la requête PATCH: ${e.toString()}',
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
          // Log l'erreur 404 pour le débogage
          ErrorHandler.instance.logError(
            'Erreur 404: $method $endpoint - $message',
            context: 'ApiService._createAppError',
          );
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

      // Log toutes les erreurs pour le débogage
      ErrorHandler.instance.logError(
        'Erreur HTTP ${response.statusCode}: $method $endpoint - $message',
        context: 'ApiService._createAppError',
      );

      return AppError(
        message: message,
        type: errorType,
        originalError: response,
        context: 'ApiService.$method($endpoint)',
      );
    } catch (e) {
      // Log l'erreur de décodage
      ErrorHandler.instance.logError(
        'Erreur de décodage de la réponse: $method $endpoint - ${response.statusCode}',
        context: 'ApiService._createAppError',
      );

      return AppError(
        message: 'Erreur ${response.statusCode}: ${response.reasonPhrase}',
        type: ErrorType.unknown,
        originalError: response,
        context: 'ApiService.$method($endpoint)',
      );
    }
  }

  // Méthodes spécifiques pour les administrateurs
  Future<List<Map<String, dynamic>>> getAdmins() async {
    final response = await get('admins');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getAdminById(dynamic id) async {
    return await get('admins/$id');
  }

  // Méthodes pour obtenir des DTOs (pour une transition progressive)
  Future<List<UserDto>> getAdminDtos() async {
    final response = await get('admins');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => UserDto.fromJson(json)).toList();
  }

  Future<UserDto> getAdminDtoById(String id) async {
    final response = await get('admins/$id');
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
    try {
      final response = await get('lots/available');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getAvailableAuctions',
      );
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  Future<Map<String, dynamic>> getAuctionDetails(dynamic auctionId) async {
    return await get('lots/$auctionId');
  }

  Future<Map<String, dynamic>> getPriseDetails(dynamic priseId) async {
    return await get('prises/$priseId');
  }

  Future<Map<String, dynamic>> getPecheurDetails(dynamic pecheurId) async {
    try {
      final response = await get('pecheurs/$pecheurId');
      // Conserver les valeurs réelles même si elles sont null
      if (response['photo'] == null) response['photo'] = '';
      if (response['email'] == null) response['email'] = '';
      if (response['telephone'] == null) response['telephone'] = '';
      if (response['matricule'] == null) response['matricule'] = '';
      if (response['bateau'] == null) response['bateau'] = '';
      if (response['port'] == null) response['port'] = '';
      if (response['cin'] == null) response['cin'] = '';
      return response;
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getPecheurDetails',
      );
      // Retourner des données par défaut en cas d'erreur
      return {
        'id': pecheurId,
        'nom': 'Utilisateur',
        'prenom': 'Inconnu',
        'photo': '',
        'email': '',
        'telephone': '',
        'matricule': '',
        'bateau': '',
        'port': '',
        'cin': '',
      };
    }
  }

  Future<Map<String, dynamic>> getVeterinaireDetails(
    dynamic veterinaireId,
  ) async {
    try {
      final response = await get('veterinaires/$veterinaireId');
      // Conserver les valeurs réelles même si elles sont null
      if (response['photo'] == null) response['photo'] = '';
      if (response['email'] == null) response['email'] = '';
      if (response['telephone'] == null) response['telephone'] = '';
      if (response['specialite'] == null) response['specialite'] = '';
      if (response['licence'] == null) response['licence'] = '';
      if (response['etablissement'] == null) response['etablissement'] = '';
      return response;
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getVeterinaireDetails',
      );
      // Retourner des données par défaut en cas d'erreur
      return {
        'id': veterinaireId,
        'nom': 'Utilisateur',
        'prenom': 'Inconnu',
        'photo': '',
        'email': '',
        'telephone': '',
        'specialite': '',
        'licence': '',
        'etablissement': '',
      };
    }
  }

  Future<Map<String, dynamic>> getMaryeurDetails(dynamic maryeurId) async {
    try {
      final response = await get('maryeurs/$maryeurId');
      // Conserver les valeurs réelles même si elles sont null
      if (response['photo'] == null) response['photo'] = '';
      if (response['email'] == null) response['email'] = '';
      if (response['telephone'] == null) response['telephone'] = '';
      if (response['societe'] == null) response['societe'] = '';
      if (response['registre'] == null) response['registre'] = '';
      if (response['adresse'] == null) response['adresse'] = '';
      return response;
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getMaryeurDetails',
      );
      // Retourner des données par défaut en cas d'erreur
      return {
        'id': maryeurId,
        'nom': 'Utilisateur',
        'prenom': 'Inconnu',
        'photo': '',
        'email': '',
        'telephone': '',
        'societe': '',
        'registre': '',
        'adresse': '',
      };
    }
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
    try {
      return await get('stats/dashboard');
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getDashboardStats',
      );
      // Retourner des données par défaut en cas d'erreur
      return {'availableAuctions': 0, 'myPurchases': 0};
    }
  }

  Future<Map<String, dynamic>> getPecheurStats(dynamic pecheurId) async {
    try {
      return await get('stats/pecheur/$pecheurId');
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getPecheurStats');
      // Retourner des données par défaut en cas d'erreur
      return {
        'totalCaptures': 0,
        'pendingValidation': 0,
        'validated': 0,
        'rejected': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getMaryeurStats(dynamic maryeurId) async {
    try {
      return await get('stats/maryeur/$maryeurId');
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getMaryeurStats');
      // Retourner des données par défaut en cas d'erreur
      return {'pendingLots': 0, 'activeAuctions': 0, 'completedAuctions': 0};
    }
  }

  Future<Map<String, dynamic>> getVeterinaireStats(
    dynamic veterinaireId,
  ) async {
    try {
      final response = await get('stats/veterinaire/$veterinaireId');
      return response['data'] ??
          {'pendingLots': 0, 'approvedLots': 0, 'rejectedLots': 0};
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getVeterinaireStats',
      );
      // Retourner des données par défaut en cas d'erreur
      return {'pendingLots': 0, 'approvedLots': 0, 'rejectedLots': 0};
    }
  }

  Future<Map<String, dynamic>> getClientStats(dynamic clientId) async {
    try {
      final response = await get('stats/client/$clientId');
      return response['data'] ?? {'purchases': 0, 'activeAuctions': 0};
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getClientStats');
      // Retourner des données par défaut en cas d'erreur
      return {'purchases': 0, 'activeAuctions': 0};
    }
  }

  // Méthode pour récupérer les lots d'un vétérinaire
  Future<List<Map<String, dynamic>>> getLotsByVeterinaireId(
    dynamic veterinaireId, {
    bool? status,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    try {
      // Construire les paramètres de requête
      final Map<String, dynamic> queryParams = {};

      // Ajouter les filtres si fournis
      if (status != null) {
        queryParams['status'] = status.toString();
      }

      if (dateDebut != null) {
        queryParams['dateDebut'] = dateDebut.toIso8601String();
      }

      if (dateFin != null) {
        queryParams['dateFin'] = dateFin.toIso8601String();
      }

      // Construire l'URL avec les paramètres de requête
      String url = 'lots/veterinaire/$veterinaireId';
      if (queryParams.isNotEmpty) {
        url += '?';
        queryParams.forEach((key, value) {
          url += '$key=$value&';
        });
        url = url.substring(0, url.length - 1); // Supprimer le dernier &
      }

      final response = await get(url);
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getLotsByVeterinaireId',
      );
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActiveAuctionsByMaryeurId(
    dynamic maryeurId,
  ) async {
    try {
      final response = await get('lots/auctions/maryeur/$maryeurId');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getActiveAuctionsByMaryeurId',
      );
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  // Méthode pour récupérer les lots d'un maryeur
  Future<List<Map<String, dynamic>>> getLotsByMaryeurId(
    dynamic maryeurId, {
    bool? vendu,
    bool? status,
    bool? hasPrixInitial,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    try {
      // Construire les paramètres de requête
      final Map<String, dynamic> queryParams = {};

      // Ajouter les filtres si fournis
      if (vendu != null) {
        queryParams['vendu'] = vendu.toString();
      }

      if (status != null) {
        queryParams['status'] = status.toString();
      }

      if (hasPrixInitial != null) {
        queryParams['hasPrixInitial'] = hasPrixInitial.toString();
      }

      if (dateDebut != null) {
        queryParams['dateDebut'] = dateDebut.toIso8601String();
      }

      if (dateFin != null) {
        queryParams['dateFin'] = dateFin.toIso8601String();
      }

      // Construire l'URL avec les paramètres de requête
      String url = 'lots/maryeur/$maryeurId';
      if (queryParams.isNotEmpty) {
        url += '?';
        queryParams.forEach((key, value) {
          url += '$key=$value&';
        });
        url = url.substring(0, url.length - 1); // Supprimer le dernier &
      }

      final response = await get(url);
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getLotsByMaryeurId',
      );
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  // Méthode pour récupérer les détails d'un client
  Future<Map<String, dynamic>> getClientDetails(dynamic clientId) async {
    try {
      final response = await get('clients/$clientId');
      // Conserver les valeurs réelles même si elles sont null
      if (response['photo'] == null) response['photo'] = '';
      if (response['email'] == null) response['email'] = '';
      if (response['telephone'] == null) response['telephone'] = '';
      if (response['adresse'] == null) response['adresse'] = '';
      return response;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getClientDetails');
      // Retourner des données par défaut en cas d'erreur
      return {
        'id': clientId,
        'nom': 'Utilisateur',
        'prenom': 'Inconnu',
        'photo': '',
        'email': '',
        'telephone': '',
        'adresse': '',
      };
    }
  }

  // Méthode pour récupérer les achats du client connecté
  Future<List<Map<String, dynamic>>> getMyPurchases() async {
    try {
      final response = await get('clients/purchases/me');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getMyPurchases');
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  // Méthode pour récupérer les achats d'un client spécifique
  Future<List<Map<String, dynamic>>> getClientPurchases(
    dynamic clientId,
  ) async {
    try {
      final response = await get('clients/purchases/$clientId');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getClientPurchases',
      );
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  // Cette méthode est obsolète, utilisez getVeterinaireDetails à la place
  @Deprecated(
    "Cette méthode est obsolète, utilisez getVeterinaireDetails à la place",
  )
  Future<Map<String, dynamic>> getVitirinaireDetails(
    dynamic veterinaireId,
  ) async {
    return await getVeterinaireDetails(veterinaireId);
  }

  // Méthode pour construire l'URL complète d'une image
  String getImageUrl(String imagePath) {
    // Si le chemin commence déjà par http, c'est une URL complète
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Sinon, construire l'URL complète
    // Supprimer le slash initial si présent pour éviter les doubles slashes
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    return '$baseUrl/images/$path';
  }
}
