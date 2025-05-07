import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as baseUrl; // Import inutilisé
import 'package:seatrace/dtos/lot_dto.dart';
import 'package:seatrace/dtos/prise_dto.dart';
import 'package:seatrace/dtos/user_dto.dart';
import 'package:seatrace/utils/error_handler.dart'; // Assurez-vous que AppError et ErrorType sont ici

class ApiService {
  static final ApiService instance = ApiService._init();
  late String baseUrl;
  String? _authToken;

  static const int _maxHttpRetries = 3;
  static const Duration _initialTimeout = Duration(seconds: 10);
  static const Duration _retryDelay = Duration(seconds: 2);

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _initialTimeout,
      receiveTimeout: _initialTimeout,
    ),
  );

  final List<String> _fallbackUrls = [
    'http://localhost:3005/api',
    'http://127.0.0.1:3005/api',
    'http://192.168.1.1:3005/api',
    'http://10.0.2.2:3005/api', // Émulateur Android
  ];

  ApiService._init() {
    baseUrl = 'http://172.16.10.12:3005/api';
    _dio.options.baseUrl = baseUrl.split('/api').first; // Initialiser pour Dio également
    debugPrint('ApiService: Base URL configurée: $baseUrl');
  }

  // --- Core & Setup ---

  void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('ApiService: Auth token ${_authToken == null ? "supprimé" : "défini"}.');
  }

  bool hasToken() => _authToken != null && _authToken!.isNotEmpty;

  Future<bool> isServerReachable(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/health'))
          .timeout(_initialTimeout);
      debugPrint('ApiService: Vérification serveur pour $url - Statut: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      debugPrint('ApiService: Erreur lors de la vérification de la joignabilité de $url: $e');
      return false;
    }
  }

  Future<bool> checkServerConnectivity() async {
    debugPrint('ApiService: Vérification de la connectivité au serveur...');
    if (await isServerReachable(baseUrl)) {
      debugPrint('ApiService: Connexion établie avec l\'URL principale: $baseUrl');
      _dio.options.baseUrl = baseUrl.split('/api').first; // S'assurer que Dio est à jour
      return true;
    }

    for (final fallbackUrl in _fallbackUrls) {
      debugPrint('ApiService: Essai de $fallbackUrl');
      if (await isServerReachable(fallbackUrl)) {
        baseUrl = fallbackUrl;
        _dio.options.baseUrl = baseUrl.split('/api').first;
        debugPrint('ApiService: Connexion établie avec $fallbackUrl. Nouvelle URL de base: $baseUrl');
        return true;
      }
    }

    debugPrint('ApiService: Aucune connexion établie avec les URLs configurées.');
    return false;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (hasToken()) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  AppError _createAppError(
    http.Response response,
    String method,
    String endpoint,
  ) {
    String message = 'Une erreur est survenue.';
    dynamic responseBody = response.body;

    try {
      final Map<String, dynamic>? body = json.decode(response.body);
      message = body?['message'] ?? body?['error'] ?? response.reasonPhrase ?? 'Erreur inconnue';
      responseBody = body ?? response.body;
    } catch (e) {
      message = response.reasonPhrase ?? 'Erreur de communication avec le serveur.';
      ErrorHandler.instance.logWarning(
        'ApiService: Corps de réponse non-JSON pour $method $endpoint - Statut: ${response.statusCode}',
        context: 'ApiService._createAppError',
      );
    }

    ErrorType errorType;
    switch (response.statusCode) {
      case 400: errorType = ErrorType.validation; break;
      case 401: errorType = ErrorType.authentication; break;
      case 403: errorType = ErrorType.authorization; break;
      case 404: errorType = ErrorType.notFound; break;
      case 422: errorType = ErrorType.validation; break;
      case 500: case 502: case 503: case 504: errorType = ErrorType.server; break;
      default: errorType = ErrorType.unknown;
    }

    ErrorHandler.instance.logError(
      'ApiService: Erreur HTTP ${response.statusCode}: $method $endpoint - $message',
      context: 'ApiService._createAppError',
    );

    return AppError(
      message: message,
      type: errorType,
      originalError: responseBody,
      context: 'ApiService.$method($endpoint)',
      statusCode: response.statusCode,
    );
  }

  // --- Generic CRUD (using http package) ---

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    ErrorHandler.instance.logInfo('ApiService: GET $baseUrl/$endpoint, Params: $queryParameters', context: 'ApiService.get');
    try {
      Uri uri;
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParameters.map((key, value) => MapEntry(key, value.toString())));
      } else {
        uri = Uri.parse('$baseUrl/$endpoint');
      }

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_initialTimeout, onTimeout: () {
        throw TimeoutException('La requête GET a pris trop de temps (${_initialTimeout.inSeconds}s).');
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }

      if (response.statusCode == 404) {
        ErrorHandler.instance.logWarning('ApiService: Route non trouvée (404): $endpoint', context: 'ApiService.get');
        if (endpoint.contains('search') || endpoint.contains('available') || endpoint.contains('featured') || endpoint.contains('purchases/me') || endpoint == 'maryeurs' || endpoint.startsWith('maryeurs/')) {
          debugPrint('ApiService: Route 404 ($endpoint) mais retournant un résultat vide.');
          return {'success': true, 'data': []};
        }
      }
      throw _createAppError(response, 'GET', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      throw AppError(message: 'Impossible de se connecter. Vérifiez votre connexion.', type: ErrorType.network, originalError: e);
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      throw AppError(message: e.message ?? 'La requête a expiré.', type: ErrorType.network, originalError: e);
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      throw AppError(message: 'Erreur de format des données serveur.', type: ErrorType.server, originalError: e);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.get($endpoint)');
      if (e is AppError) rethrow;
      throw AppError(message: 'Erreur GET inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    ErrorHandler.instance.logInfo('ApiService: POST $baseUrl/$endpoint, Data: $data', context: 'ApiService.post');
    final urlsToTry = [baseUrl, ..._fallbackUrls];

    for (final url in urlsToTry) {
      for (int retry = 0; retry < _maxHttpRetries; retry++) {
        try {
          final currentTimeout = Duration(seconds: retry == 0 ? _initialTimeout.inSeconds : _initialTimeout.inSeconds ~/ 1.5);
          ErrorHandler.instance.logInfo(
            'ApiService: Tentative POST ${retry + 1}/$_maxHttpRetries avec $url/$endpoint, Timeout: ${currentTimeout.inSeconds}s',
            context: 'ApiService.post',
          );

          final response = await http
              .post(Uri.parse('$url/$endpoint'), headers: _headers, body: json.encode(data))
              .timeout(currentTimeout, onTimeout: () {
            throw TimeoutException('La requête POST a pris trop de temps (${currentTimeout.inSeconds}s).');
          });

          if (response.statusCode == 201 || response.statusCode == 200) {
            if (url != baseUrl) {
              ErrorHandler.instance.logInfo('ApiService: Changement d\'URL de base: $baseUrl -> $url', context: 'ApiService.post');
              baseUrl = url;
              _dio.options.baseUrl = baseUrl.split('/api').first;
            }
            return json.decode(response.body);
          }
          throw _createAppError(response, 'POST', endpoint);
        } on SocketException catch (e) {
          ErrorHandler.instance.logError('ApiService: POST Tentative ${retry + 1} échouée (SocketException): ${e.toString()}', context: 'ApiService.post($endpoint)');
          if (retry == _maxHttpRetries - 1 && url == urlsToTry.last) {
             throw AppError(message: 'Connexion impossible après plusieurs essais.', type: ErrorType.network, originalError: e);
          }
          await Future.delayed(_retryDelay);
        } on TimeoutException catch (e) {
          ErrorHandler.instance.logError('ApiService: POST Tentative ${retry + 1} échouée (Timeout): ${e.toString()}', context: 'ApiService.post($endpoint)');
           if (retry == _maxHttpRetries - 1 && url == urlsToTry.last) {
             throw AppError(message: 'La requête a expiré après plusieurs essais.', type: ErrorType.network, originalError: e);
          }
          await Future.delayed(_retryDelay);
        } on FormatException catch (e) {
          ErrorHandler.instance.logError(e, context: 'ApiService.post($endpoint)');
          throw AppError(message: 'Erreur de format des données serveur.', type: ErrorType.server, originalError: e);
        } catch (e) {
          ErrorHandler.instance.logError(e, context: 'ApiService.post($endpoint)');
          if (e is AppError) rethrow;
          throw AppError(message: 'Erreur POST inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
        }
      }
    }
    throw AppError(message: 'Toutes les tentatives POST ont échoué.', type: ErrorType.network);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    ErrorHandler.instance.logInfo('ApiService: PUT $baseUrl/$endpoint, Data: $data', context: 'ApiService.put');
    try {
      final response = await http
          .put(Uri.parse('$baseUrl/$endpoint'), headers: _headers, body: json.encode(data))
          .timeout(_initialTimeout, onTimeout: () {
        throw TimeoutException('La requête PUT a pris trop de temps (${_initialTimeout.inSeconds}s).');
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      throw _createAppError(response, 'PUT', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      throw AppError(message: 'Impossible de se connecter. Vérifiez votre connexion.', type: ErrorType.network, originalError: e);
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      throw AppError(message: e.message ?? 'La requête a expiré.', type: ErrorType.network, originalError: e);
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      throw AppError(message: 'Erreur de format des données serveur.', type: ErrorType.server, originalError: e);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.put($endpoint)');
      if (e is AppError) rethrow;
      throw AppError(message: 'Erreur PUT inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> data) async {
    ErrorHandler.instance.logInfo('ApiService: PATCH $baseUrl/$endpoint, Data: $data', context: 'ApiService.patch');
     try {
      final response = await http
          .patch(Uri.parse('$baseUrl/$endpoint'), headers: _headers, body: json.encode(data))
          .timeout(_initialTimeout, onTimeout: () {
        throw TimeoutException('La requête PATCH a pris trop de temps (${_initialTimeout.inSeconds}s).');
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      throw _createAppError(response, 'PATCH', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      throw AppError(message: 'Impossible de se connecter. Vérifiez votre connexion.', type: ErrorType.network, originalError: e);
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      throw AppError(message: e.message ?? 'La requête a expiré.', type: ErrorType.network, originalError: e);
    } on FormatException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      throw AppError(message: 'Erreur de format des données serveur.', type: ErrorType.server, originalError: e);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.patch($endpoint)');
      if (e is AppError) rethrow;
      throw AppError(message: 'Erreur PATCH inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
    }
  }

  Future<void> delete(String endpoint) async {
    ErrorHandler.instance.logInfo('ApiService: DELETE $baseUrl/$endpoint', context: 'ApiService.delete');
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$endpoint'), headers: _headers)
          .timeout(_initialTimeout, onTimeout: () {
        throw TimeoutException('La requête DELETE a pris trop de temps (${_initialTimeout.inSeconds}s).');
      });

      if (response.statusCode >= 200 && response.statusCode < 300) { // 200 OK ou 204 No Content
        return; // Pas de corps à parser pour un DELETE réussi typiquement
      }
      throw _createAppError(response, 'DELETE', endpoint);
    } on SocketException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.delete($endpoint)');
      throw AppError(message: 'Impossible de se connecter. Vérifiez votre connexion.', type: ErrorType.network, originalError: e);
    } on TimeoutException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.delete($endpoint)');
      throw AppError(message: e.message ?? 'La requête a expiré.', type: ErrorType.network, originalError: e);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.delete($endpoint)');
      if (e is AppError) rethrow;
      throw AppError(message: 'Erreur DELETE inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
    }
  }

  // --- File Upload (using Dio for FormData) ---

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    Map<String, String> additionalData,
  ) async {
    ErrorHandler.instance.logInfo('ApiService: UploadFile $baseUrl/$endpoint, File: $filePath', context: 'ApiService.uploadFile');
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...additionalData,
      });
      
      // _dio.options.baseUrl est déjà configuré dans _init et checkServerConnectivity
      final response = await _dio.post(
        '/api/$endpoint', // Endpoint relatif à la base URL de Dio (sans /api)
        data: formData,
        options: Options(headers: { // Dio gère Content-Type pour FormData
          if (hasToken()) 'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        }),
      );
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
         ErrorHandler.instance.logWarning('ApiService: Réponse UploadFile non Map. Data: ${response.data}', context: 'ApiService.uploadFile');
         return {'success': true, 'data': response.data};
      }
    } on DioException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.uploadFile($endpoint)');
      throw AppError(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Erreur upload fichier.',
        type: (e.type == DioExceptionType.connectionTimeout || 
               e.type == DioExceptionType.sendTimeout || 
               e.type == DioExceptionType.receiveTimeout ||
               e.type == DioExceptionType.connectionError)
            ? ErrorType.network
            : ErrorType.server,
        originalError: e.response?.data ?? e,
        statusCode: e.response?.statusCode, // Corrigé en supposant AppError l'accepte
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.uploadFile($endpoint)');
      throw AppError(message: 'Erreur upload fichier inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
    }
  }

  // --- Authentication ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await post('auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('auth/register', userData);
  }

  // --- Admins ---
  Future<List<UserDto>> getAdminDtos() async {
    final response = await get('admins');
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => UserDto.fromJson(json)).toList();
  }

  Future<UserDto> getAdminDtoById(String id) async {
    final response = await get('admins/$id');
    return UserDto.fromJson(response['data'] ?? response);
  }

  // --- Lots & Prises ---
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
    return LotDto.fromJson(response['data'] ?? response);
  }

   Future<Map<String, dynamic>> getAuctionDetails(String auctionId) async {
     return await get('lots/$auctionId');
  }

  Future<PriseDto> getPriseDtoDetails(String priseId) async {
    final response = await get('prises/$priseId');
    return PriseDto.fromJson(response['data'] ?? response);
  }

   Future<Map<String, dynamic>> getPriseDetails(String priseId) async {
    return await get('prises/$priseId');
  }

  Future<void> placeBid(String auctionId, double bidAmount, String userId) async {
    await post('lots/$auctionId/bid', {'amount': bidAmount, 'userId': userId});
  }

  Future<List<Map<String, dynamic>>> getLotsByPecheurId(String pecheurId) async {
    final response = await get('lots/pecheur/$pecheurId');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getAvailableAuctions() async {
    try {
      final response = await get('lots/available');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getAvailableAuctions');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getLotsByVeterinaireId(
    String veterinaireId, {
    bool? status,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null) queryParams['status'] = status.toString();
    if (dateDebut != null) queryParams['dateDebut'] = dateDebut.toIso8601String();
    if (dateFin != null) queryParams['dateFin'] = dateFin.toIso8601String();
    
    try {
        final response = await get('lots/veterinaire/$veterinaireId', queryParameters: queryParams);
        return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getLotsByVeterinaireId');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getActiveAuctionsByMaryeurId(String maryeurId) async {
    try {
      final response = await get('lots/auctions/maryeur/$maryeurId');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getActiveAuctionsByMaryeurId');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLotsByMaryeurId(
    String maryeurId, {
    bool? vendu,
    bool? status,
    bool? hasPrixInitial,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (vendu != null) queryParams['vendu'] = vendu.toString();
    if (status != null) queryParams['status'] = status.toString();
    if (hasPrixInitial != null) queryParams['hasPrixInitial'] = hasPrixInitial.toString();
    if (dateDebut != null) queryParams['dateDebut'] = dateDebut.toIso8601String();
    if (dateFin != null) queryParams['dateFin'] = dateFin.toIso8601String();

    try {
      final response = await get('lots/maryeur/$maryeurId', queryParameters: queryParams);
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getLotsByMaryeurId');
      return [];
    }
  }

  // --- Users (Pecheur, Veterinaire, Maryeur, Client) ---
  Map<String, dynamic> _normalizeUserData(dynamic responseData, String userId, List<String> fields, Map<String, dynamic> defaultValues) {
    final data = (responseData is Map && responseData.containsKey('data') && responseData['data'] is Map)
        ? responseData['data'] as Map<String, dynamic>
        : (responseData is Map<String, dynamic> ? responseData : <String, dynamic>{});

    final result = <String, dynamic>{...defaultValues, 'id': userId};
    fields.forEach((field) {
      result[field] = data[field] ?? defaultValues[field] ?? '';
    });
    return result;
  }
  
  Future<UserDto> getPecheurDtoDetails(String pecheurId) async {
    final response = await get('pecheurs/$pecheurId');
    return UserDto.fromJson(response['data'] ?? response);
  }

  Future<Map<String, dynamic>> getPecheurDetails(String pecheurId) async {
    try {
      final response = await get('pecheurs/$pecheurId');
      return _normalizeUserData(response, pecheurId, 
        ['nom', 'prenom', 'photo', 'email', 'telephone', 'matricule', 'bateau', 'port', 'cin'], 
        {'nom': 'Utilisateur', 'prenom': 'Inconnu'});
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getPecheurDetails($pecheurId)');
      return _normalizeUserData(null, pecheurId, 
        ['nom', 'prenom', 'photo', 'email', 'telephone', 'matricule', 'bateau', 'port', 'cin'], 
        {'nom': 'Utilisateur', 'prenom': 'Inconnu'});
    }
  }

  Future<UserDto> getVeterinaireDtoDetails(String veterinaireId) async {
    final response = await get('veterinaires/$veterinaireId');
    return UserDto.fromJson(response['data'] ?? response);
  }

  Future<Map<String, dynamic>> getVeterinaireDetails(String veterinaireId) async {
     try {
      final response = await get('veterinaires/$veterinaireId');
      return _normalizeUserData(response, veterinaireId, 
        ['nom', 'prenom', 'photo', 'email', 'telephone', 'specialite', 'licence', 'etablissement'], 
        {'nom': 'Utilisateur', 'prenom': 'Inconnu'});
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getVeterinaireDetails($veterinaireId)');
      return _normalizeUserData(null, veterinaireId, 
        ['nom', 'prenom', 'photo', 'email', 'telephone', 'specialite', 'licence', 'etablissement'], 
        {'nom': 'Utilisateur', 'prenom': 'Inconnu'});
    }
  }

  @Deprecated("Utilisez getVeterinaireDetails à la place")
  Future<Map<String, dynamic>> getVitirinaireDetails(String veterinaireId) async {
    ErrorHandler.instance.logWarning('ApiService: getVitirinaireDetails est obsolète.', context: 'ApiService.getVitirinaireDetails');
    return getVeterinaireDetails(veterinaireId);
  }
  
  Future<UserDto> getMaryeurDtoDetails(String maryeurId) async {
    final response = await get('maryeurs/$maryeurId');
    return UserDto.fromJson(response['data'] ?? response);
  }

  Future<Map<String, dynamic>> getMaryeurDetails(String maryeurId) async {
    debugPrint('ApiService: Récupération détails mareyeur ID: $maryeurId');
    try {
      final response = await get('maryeurs/$maryeurId');
      final maryeurData = (response.containsKey('data') && response['data'] is Map<String, dynamic>) 
                          ? response['data'] as Map<String, dynamic>
                          : (response is Map<String, dynamic> ? response : null);

      if (maryeurData != null && maryeurData['nom'] != null && maryeurData['prenom'] != null) {
        debugPrint('ApiService: Mareyeur trouvé: ${maryeurData['prenom']} ${maryeurData['nom']}');
        return _normalizeUserData(maryeurData, maryeurId, 
            ['nom', 'prenom', 'photo', 'email', 'telephone', 'societe', 'registre', 'adresse', 'isValidated', 'isBlocked'],
            {}); // Default values already handled by _normalizeUserData if null
      } else {
        debugPrint('ApiService: Mareyeur non trouvé ou structure inattendue pour ID: $maryeurId. Réponse: $response');
        throw AppError(message: 'Mareyeur non trouvé ou données invalides.', type: ErrorType.notFound, statusCode: 404);
      }
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getMaryeurDetails($maryeurId)');
      if (e is AppError) rethrow;
      throw AppError(message: 'Erreur récupération mareyeur ID: $maryeurId.', type: ErrorType.unknown, originalError: e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllMaryeurs() async {
    debugPrint('ApiService: Récupération de tous les mareyeurs actifs.');
    try {
      final response = await get('maryeurs');
      final List<dynamic> maryeursList = response['data'] ?? (response is List ? response : []);
      
      debugPrint('ApiService: Mareyeurs bruts récupérés: ${maryeursList.length}');

      final validMaryeurs = maryeursList.whereType<Map<String, dynamic>>().where((m) {
        final isValid = m['nom'] != null && m['nom'].toString().isNotEmpty &&
                        m['prenom'] != null && m['prenom'].toString().isNotEmpty &&
                        (m['isValidated'] == true || m['isValidated'].toString().toLowerCase() == 'true') &&
                        (m['isBlocked'] == false || m['isBlocked'].toString().toLowerCase() == 'false');
        if (isValid) {
          debugPrint('ApiService: Mareyeur valide: ${m['prenom']} ${m['nom']} (ID: ${m['_id'] ?? m['id']})');
        }
        return isValid;
      }).toList();

      debugPrint('ApiService: Mareyeurs actifs et valides: ${validMaryeurs.length}');
      return validMaryeurs;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getAllMaryeurs');
      if (e is AppError) rethrow;
      throw AppError(message: 'Erreur récupération des mareyeurs.', type: ErrorType.network, originalError: e);
    }
  }

  Future<Map<String, dynamic>> assignMaryeurToPrise(String veterinaireId, String priseId, String maryeurId) async {
    return await put('veterinaires/$veterinaireId/assign-maryeur', {
      'priseId': priseId,
      'maryeurId': maryeurId,
    });
  }

  Future<Map<String, dynamic>> getClientDetails(String clientId) async {
    try {
      final response = await get('clients/$clientId');
       return _normalizeUserData(response, clientId, 
        ['nom', 'prenom', 'photo', 'email', 'telephone', 'adresse'], 
        {'nom': 'Utilisateur', 'prenom': 'Inconnu'});
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getClientDetails($clientId)');
      return _normalizeUserData(null, clientId, 
        ['nom', 'prenom', 'photo', 'email', 'telephone', 'adresse'], 
        {'nom': 'Utilisateur', 'prenom': 'Inconnu'});
    }
  }

  Future<List<Map<String, dynamic>>> getMyPurchases() async {
    try {
      final response = await get('clients/purchases/me');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getMyPurchases');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClientPurchases(String clientId) async {
    try {
      final response = await get('clients/purchases/$clientId');
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getClientPurchases($clientId)');
      return [];
    }
  }

  // --- Fish Species & Classification ---
  Future<Map<String, dynamic>> getEspeceByNom(String nom) async {
    return await get('especes/nom/$nom');
  }

  Future<List<Map<String, dynamic>>> getAllEspeces() async {
    final response = await get('especes');
    return List<Map<String, dynamic>>.from(response['data'] ?? []);
  }

  Future<Map<String, dynamic>> createEspece(
    String nom, {
    String? imageUrl, String? description, String? nomScientifique,
    double? prixMinimal, double? prixMoyen, double? confiance,
    String? source, List<Map<String, dynamic>>? alternatives,
  }) async {
    final Map<String, dynamic> data = {'nom': nom};
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (description != null) data['description'] = description;
    if (nomScientifique != null) data['nomScientifique'] = nomScientifique;
    if (prixMinimal != null) data['prixMinimal'] = prixMinimal;
    if (prixMoyen != null) data['prixMoyen'] = prixMoyen;
    if (confiance != null) data['confiance'] = confiance;
    if (source != null) data['source'] = source;
    if (alternatives != null) data['alternatives'] = alternatives;
    return await post('especes', data);
  }

  Future<Map<String, dynamic>> classifyFish(String nom) async {
    return await post('fish-classification/classify', {'nom': nom});
  }

  Future<Map<String, dynamic>> classifyFishImage(File imageFile) async {
    ErrorHandler.instance.logInfo('ApiService: classifyFishImage: ${imageFile.path}', context: 'ApiService.classifyFishImage');
    try {
      // _dio.options.baseUrl est déjà configuré
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last),
      });

      final response = await _dio.post(
        '/api/fish-classification/classify-image',
        data: formData,
        options: Options(headers: {
            if (hasToken()) 'Authorization': 'Bearer $_authToken',
            'Accept': 'application/json',
        }),
      );
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      ErrorHandler.instance.logWarning('ApiService: Réponse classifyFishImage non Map. Data: ${response.data}', context: 'ApiService.classifyFishImage');
      return {'success': true, 'data': response.data};

    } on DioException catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.classifyFishImage');
      throw AppError(
        message: e.response?.data?['message']?.toString() ?? e.message ?? 'Erreur classification image.',
        type: (e.type == DioExceptionType.connectionTimeout || 
               e.type == DioExceptionType.sendTimeout || 
               e.type == DioExceptionType.receiveTimeout ||
               e.type == DioExceptionType.connectionError)
            ? ErrorType.network
            : ErrorType.server,
        originalError: e.response?.data ?? e,
        statusCode: e.response?.statusCode, // Corrigé en supposant AppError l'accepte
      );
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.classifyFishImage');
      throw AppError(message: 'Erreur classification image inattendue: ${e.toString()}', type: ErrorType.unknown, originalError: e);
    }
  }

  Future<List<String>> getFishSpecies() async {
    final response = await get('fish-classification/species');
    final List<dynamic> species = response['data']?['species'] ?? response['species'] ?? []; // Plus robuste
    return species.map((e) => e.toString()).toList();
  }

  // --- Statistics ---
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await get('stats/dashboard');
      return response['data'] ?? response;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getDashboardStats');
      return {'availableAuctions': 0, 'myPurchases': 0};
    }
  }

  Future<Map<String, dynamic>> getPecheurStats(String pecheurId) async {
    try {
      final response = await get('stats/pecheur/$pecheurId');
      return response['data'] ?? response;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getPecheurStats($pecheurId)');
      return {'totalCaptures': 0, 'pendingValidation': 0, 'validated': 0, 'rejected': 0};
    }
  }

  Future<Map<String, dynamic>> getMaryeurStats(String maryeurId) async {
    try {
      final response = await get('stats/maryeur/$maryeurId');
      return response['data'] ?? response;
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getMaryeurStats($maryeurId)');
      return {'pendingLots': 0, 'activeAuctions': 0, 'completedAuctions': 0};
    }
  }

  Future<Map<String, dynamic>> getVeterinaireStats(String veterinaireId) async {
    try {
      final response = await get('stats/veterinaire/$veterinaireId');
      return response['data'] ?? {'pendingLots': 0, 'approvedLots': 0, 'rejectedLots': 0};
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getVeterinaireStats($veterinaireId)');
      return {'pendingLots': 0, 'approvedLots': 0, 'rejectedLots': 0};
    }
  }

  Future<Map<String, dynamic>> getClientStats(String clientId) async {
    try {
      final response = await get('stats/client/$clientId');
      return response['data'] ?? {'purchases': 0, 'activeAuctions': 0};
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getClientStats($clientId)');
      return {'purchases': 0, 'activeAuctions': 0};
    }
  }
  
  // --- Utility ---
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      debugPrint('ApiService: Chemin d\'image vide ou null.');
      return ''; // Retourner un placeholder ou une URL d'image par défaut si nécessaire
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      debugPrint('ApiService: URL d\'image déjà complète: $imagePath');
      return imagePath;
    }

    String domainBase = baseUrl.endsWith('/api') 
                        ? baseUrl.substring(0, baseUrl.length - '/api'.length) 
                        : baseUrl;
    
    String pathSegment = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // Si le backend sert les images via /api/images/...
    if (pathSegment.startsWith('images/') || pathSegment.startsWith('uploads/')) { // Cas commun pour les fichiers statiques
        final fullUrl = '$domainBase/$pathSegment';
        debugPrint('ApiService: URL d\'image construite (chemin statique relatif au domaine): $fullUrl');
        return fullUrl;
    } else if (pathSegment.startsWith('api/images/') || pathSegment.startsWith('api/uploads/')) {
        final fullUrl = '$domainBase/$pathSegment'; // pathSegment inclut déjà /api/
        debugPrint('ApiService: URL d\'image construite (chemin API relatif au domaine): $fullUrl');
        return fullUrl;
    }
     else { // Cas par défaut: image servie par /api/images/nom_fichier
        final fullUrl = '$domainBase/api/images/$pathSegment'; 
        // OU si les images ne sont PAS servies via /api mais directement depuis le domaine:
        // final fullUrl = '$domainBase/images/$pathSegment';
        debugPrint('ApiService: URL d\'image construite (chemin par défaut /api/images/): $fullUrl');
        return fullUrl;
    }
  }
}