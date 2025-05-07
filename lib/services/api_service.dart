import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as baseUrl;
import 'package:seatrace/dtos/lot_dto.dart';
import 'package:seatrace/dtos/prise_dto.dart';
import 'package:seatrace/dtos/user_dto.dart';
import 'package:seatrace/utils/error_handler.dart';

class ApiService {
  static final ApiService instance = ApiService._init();
  late String baseUrl;
  String? _authToken;

  // Configuration des retries et timeouts
  static const int maxRetries = 3;
  static const Duration initialTimeout = Duration(seconds: 10);
  static const Duration retryDelay = Duration(seconds: 2);

  // Instance de Dio avec configuration
  final Dio _dio = Dio(
  BaseOptions(
    connectTimeout: Duration(milliseconds: initialTimeout.inMilliseconds),
    receiveTimeout: Duration(milliseconds: initialTimeout.inMilliseconds),
  ),
);



  // URLs de fallback pour gérer plusieurs environnements
  final List<String> _fallbackUrls = [
    'http://localhost:3005/api',
    'http://127.0.0.1:3005/api',
    'http://192.168.1.1:3005/api',
    'http://10.0.2.2:3005/api', // Émulateur Android
  ];

  ApiService._init() {
    baseUrl = 'http://172.16.10.12:3005/api'; // Adresse principale
    debugPrint('Base URL configurée: $baseUrl');
  }

  // Définir ou supprimer le token d'authentification
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Vérifier si un token est défini
  bool hasToken() => _authToken != null && _authToken!.isNotEmpty;

  // Vérification si le serveur est accessible
  Future<bool> isServerReachable(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/health'))
          .timeout(initialTimeout);
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de $url: $e');
      return false;
    }
  }

  // Essayer différentes URLs pour trouver une connexion fonctionnelle
  Future<bool> checkServerConnectivity() async {
    debugPrint('Vérification de la connectivité au serveur...');
    if (await isServerReachable(baseUrl)) return true;

    for (final fallbackUrl in _fallbackUrls) {
      debugPrint('Essai de $fallbackUrl');
      if (await isServerReachable(fallbackUrl)) {
        baseUrl = fallbackUrl;
        debugPrint('Connexion établie avec $fallbackUrl');
        return true;
      }
    }

    debugPrint('Aucune connexion établie avec les URLs configurées.');
    return false;
  }

  // Gestion des headers pour les requêtes HTTP
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Requête GET
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête GET: $e');
    }
  }

  // Requête POST
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête POST: $e');
    }
  }

  // Requête PUT
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête PUT: $e');
    }
  }

  // Requête DELETE
  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête DELETE: $e');
    }
  }

  // Gestion des réponses HTTP
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Erreur HTTP ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  // Méthode pour les requêtes multipart (upload de fichiers)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    Map<String, String> additionalData,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...additionalData,
      });

      final response = await _dio.post(
        '$baseUrl/$endpoint',
        data: formData,
        options: Options(headers: _headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de fichier: $e');
    }
  }
}


  // Méthodes génériques CRUD
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      // Journaliser la requête
      ErrorHandler.instance.logInfo(
        'GET request: $endpoint',
        context: 'ApiService',
      );

      // Construire l'URI avec les paramètres de requête
      Uri uri;
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final queryString = queryParameters.entries
            .map(
              (e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
            )
            .join('&');
        uri = Uri.parse('$baseUrl/$endpoint?$queryString');
      } else {
        uri = Uri.parse('$baseUrl/$endpoint');
      }

      // Ajouter un timeout pour éviter les attentes infinies
      final response = await http
          .get(uri, headers: _headers)
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
            endpoint.contains('purchases/me') ||
            endpoint == 'maryeurs' ||
            endpoint.startsWith('maryeurs/')) {
          debugPrint(
            'Route non trouvée mais retournant un résultat vide: $endpoint',
          );

          // Ne pas retourner de mareyeur par défaut, laisser l'erreur se propager
          // pour que l'application puisse afficher un message approprié

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
  
  class _headers {
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // Liste des URLs à essayer, en commençant par l'URL principale
    final urlsToTry = [baseUrl, ..._fallbackUrls];

    // Nombre maximum de tentatives
    const maxRetries = 2;

    // Journaliser la requête
    ErrorHandler.instance.logInfo(
      'POST request: $endpoint',
      context: 'ApiService',
    );

    // Pour chaque URL à essayer
    for (final url in urlsToTry) {
      // Essayer plusieurs fois avec la même URL
      for (int retry = 0; retry < maxRetries; retry++) {
        try {
          // Ajouter un timeout pour éviter les attentes infinies
          // Réduire le timeout pour les tentatives suivantes
          final timeout = retry == 0 ? 30 : 15; // secondes

          ErrorHandler.instance.logInfo(
            'Tentative ${retry + 1}/$maxRetries avec URL: $url/$endpoint',
            context: 'ApiService',
          );

          final response = await http
              .post(
                Uri.parse('$url/$endpoint'),
                headers: _headers,
                body: json.encode(data),
              )
              .timeout(
                Duration(seconds: timeout),
                onTimeout: () {
                  throw TimeoutException(
                    'La requête a pris trop de temps à s\'exécuter (${timeout}s)',
                  );
                },
              );

          if (response.statusCode == 201 || response.statusCode == 200) {
            // Si cette URL fonctionne, la définir comme URL par défaut
            if (url != baseUrl) {
              ErrorHandler.instance.logInfo(
                'Changement d\'URL de base: $baseUrl -> $url',
                context: 'ApiService',
              );
              baseUrl = url;
            }

            final responseData = json.decode(response.body);
            return responseData;
          }

          throw _createAppError(response, 'POST', endpoint);
        } on SocketException catch (e) {
          ErrorHandler.instance.logError(
            'Tentative ${retry + 1}/$maxRetries échouée: ${e.toString()}',
            context: 'ApiService.post($endpoint)',
          );

          // Si c'est la dernière tentative avec cette URL, continuer avec l'URL suivante
          if (retry == maxRetries - 1) {
            continue;
          }

          // Attendre un peu avant de réessayer
          await Future.delayed(const Duration(milliseconds: 500));
        } on TimeoutException catch (e) {
          ErrorHandler.instance.logError(
            'Timeout lors de la tentative ${retry + 1}/$maxRetries: ${e.toString()}',
            context: 'ApiService.post($endpoint)',
          );

          // Si c'est la dernière tentative avec cette URL, continuer avec l'URL suivante
          if (retry == maxRetries - 1) {
            continue;
          }

          // Attendre un peu avant de réessayer
          await Future.delayed(const Duration(milliseconds: 500));
        } on FormatException catch (e) {
          // Erreur de format, pas besoin de réessayer
          ErrorHandler.instance.logError(
            e,
            context: 'ApiService.post($endpoint)',
          );
          throw AppError(
            message: 'Erreur de format de données reçues du serveur.',
            type: ErrorType.server,
            originalError: e,
          );
        } catch (e) {
          // Autres erreurs, pas besoin de réessayer
          ErrorHandler.instance.logError(
            e,
            context: 'ApiService.post($endpoint)',
          );
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
    }

    // Si toutes les tentatives ont échoué
    ErrorHandler.instance.logError(
      'Toutes les tentatives ont échoué pour POST $endpoint',
      context: 'ApiService.post',
    );

    throw AppError(
      message:
          'Impossible de se connecter au serveur après plusieurs tentatives. Vérifiez votre connexion internet et réessayez plus tard.',
      type: ErrorType.network,
    );
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
      debugPrint('Récupération des détails du mareyeur avec ID: $maryeurId');

      // Afficher l'URL complète pour le débogage
      final fullUrl = '$baseUrl/maryeurs/$maryeurId';
      debugPrint('URL complète: $fullUrl');

      final response = await get('maryeurs/$maryeurId');

      // Afficher la réponse complète pour le débogage
      debugPrint('Réponse brute: ${response.toString()}');

      // Vérifier si la réponse est valide
      if (response.containsKey('nom') && response.containsKey('prenom')) {
        debugPrint('Mareyeur trouvé: ${response['prenom']} ${response['nom']}');

        // Conserver les valeurs réelles même si elles sont null
        if (response['photo'] == null) response['photo'] = '';
        if (response['email'] == null) response['email'] = '';
        if (response['telephone'] == null) response['telephone'] = '';
        if (response['societe'] == null) response['societe'] = '';
        if (response['registre'] == null) response['registre'] = '';
        if (response['adresse'] == null) response['adresse'] = '';

        // Vérifier si le mareyeur est validé
        final isValidated = response['isValidated'];
        final isBlocked = response['isBlocked'];

        debugPrint('Mareyeur validé: $isValidated, bloqué: $isBlocked');

        return response;
      } else {
        // Si la réponse ne contient pas les champs attendus, essayer de l'extraire d'un champ 'data'
        if (response.containsKey('data') &&
            response['data'] is Map<String, dynamic>) {
          final data = response['data'] as Map<String, dynamic>;

          if (data.containsKey('nom') && data.containsKey('prenom')) {
            debugPrint(
              'Mareyeur trouvé dans le champ data: ${data['prenom']} ${data['nom']}',
            );

            // Conserver les valeurs réelles même si elles sont null
            if (data['photo'] == null) data['photo'] = '';
            if (data['email'] == null) data['email'] = '';
            if (data['telephone'] == null) data['telephone'] = '';
            if (data['societe'] == null) data['societe'] = '';
            if (data['registre'] == null) data['registre'] = '';
            if (data['adresse'] == null) data['adresse'] = '';

            return data;
          }
        }

        debugPrint('Mareyeur non trouvé dans la réponse');
        throw Exception('Mareyeur non trouvé');
      }
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.getMaryeurDetails',
      );
      debugPrint('Erreur lors de la récupération des détails du mareyeur: $e');

      // Propager l'erreur au lieu de retourner un mareyeur par défaut
      throw AppError(
        message: 'Mareyeur non trouvé ou erreur de connexion',
        type: ErrorType.notFound,
        originalError: e,
      );
    }
  }

  // La méthode getDefaultMaryeur a été supprimée car elle n'est plus nécessaire

  /// Récupère la liste de tous les mareyeurs actifs (validés et non bloqués)
  Future<List<Map<String, dynamic>>> getAllMaryeurs() async {
    try {
      debugPrint('Récupération de la liste des mareyeurs actifs');

      // Afficher l'URL complète pour le débogage
      final fullUrl = '$baseUrl/maryeurs';
      debugPrint('URL complète: $fullUrl');

      final response = await get('maryeurs');

      // Vérifier si la réponse contient directement les mareyeurs ou s'ils sont dans un champ 'data'
      List<dynamic> maryeurs = [];

      if (response.containsKey('data')) {
        // Si la réponse contient un champ 'data', l'utiliser
        final data = response['data'];
        if (data is List) {
          maryeurs = data;
          debugPrint(
            'Mareyeurs trouvés dans le champ data: ${maryeurs.length}',
          );
        }
      } else if (response.containsKey('nom') &&
          response.containsKey('prenom')) {
        // Si la réponse ressemble à un seul mareyeur
        maryeurs = [response];
        debugPrint('Un seul mareyeur trouvé dans la réponse');
      }

      // Vérifier que chaque mareyeur a un nom et un prénom et est validé et non bloqué
      final validMaryeurs =
          maryeurs.where((maryeur) {
            if (maryeur is! Map) return false;

            final nom = maryeur['nom'];
            final prenom = maryeur['prenom'];
            final isValidated = maryeur['isValidated'];
            final isBlocked = maryeur['isBlocked'];

            return nom != null &&
                nom.toString().isNotEmpty &&
                prenom != null &&
                prenom.toString().isNotEmpty &&
                (isValidated == true || isValidated == 'true') &&
                (isBlocked == false || isBlocked == 'false');
          }).toList();

      debugPrint(
        'Nombre de mareyeurs actifs valides récupérés: ${validMaryeurs.length}',
      );

      // Afficher les détails des mareyeurs valides pour le débogage
      for (var maryeur in validMaryeurs) {
        debugPrint(
          'Mareyeur valide trouvé: ${maryeur['prenom']} ${maryeur['nom']} (ID: ${maryeur['_id'] ?? maryeur['id']})',
        );
      }

      return List<Map<String, dynamic>>.from(validMaryeurs);
    } catch (e) {
      ErrorHandler.instance.logError(e, context: 'ApiService.getAllMaryeurs');
      debugPrint('Erreur lors de la récupération des mareyeurs: $e');

      // Propager l'erreur au lieu de retourner une liste vide
      throw AppError(
        message: 'Erreur lors de la récupération des mareyeurs',
        type: ErrorType.network,
        originalError: e,
      );
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
    String? description,
    String? nomScientifique,
    double? prixMinimal,
    double? prixMoyen,
    double? confiance,
    String? source,
    List<Map<String, dynamic>>? alternatives,
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

  // Méthodes pour la classification des poissons
  Future<Map<String, dynamic>> classifyFish(String nom) async {
    final response = await post('fish-classification/classify', {'nom': nom});
    return response;
  }

  Future<Map<String, dynamic>> classifyFishImage(File imageFile) async {
    try {
      // Préparer les en-têtes
      final headers = _headers;

      // Configurer l'URL de base pour Dio
      _dio.options.baseUrl = baseUrl.split('/api').first;

      // Créer un FormData avec l'image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'fish_image.jpg',
        ),
      });

      // Envoyer la requête
      final response = await _dio.post(
        '/api/fish-classification/classify-image',
        data: formData,
        options: Options(headers: headers),
      );

      // Retourner les données
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      } else {
        return {'success': true, 'data': response.data};
      }
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.classifyFishImage',
      );

      // Retourner une erreur formatée
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erreur lors de la classification de l\'image',
      };
    }
  }

  Future<List<String>> getFishSpecies() async {
    final response = await get('fish-classification/species');
    final List<dynamic> species = response['species'] ?? [];
    return species.map((e) => e.toString()).toList();
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
    // Log pour aider à identifier les endroits où cette méthode est encore utilisée
    ErrorHandler.instance.logWarning(
      'La méthode getVitirinaireDetails est obsolète. Utilisez getVeterinaireDetails à la place.',
      context: 'ApiService.getVitirinaireDetails',
    );
    return await getVeterinaireDetails(veterinaireId);
  }

  // Méthode pour qu'un vétérinaire assigne un mareyeur à une prise
  Future<Map<String, dynamic>> assignMaryeurToPrise(
    dynamic veterinaireId,
    dynamic priseId,
    dynamic maryeurId,
  ) async {
    try {
      final response = await put('veterinaires/$veterinaireId/assign-maryeur', {
        'priseId': priseId,
        'maryeurId': maryeurId,
      });
      return response;
    } catch (e) {
      ErrorHandler.instance.logError(
        e,
        context: 'ApiService.assignMaryeurToPrise',
      );
      rethrow;
    }
  }

  // Méthode pour construire l'URL complète d'une image
  String getImageUrl(String? imagePath) {
    // Si le chemin est null ou vide, retourner une chaîne vide
    if (imagePath == null || imagePath.isEmpty) {
      debugPrint('Chemin d\'image vide ou null');
      return '';
    }

    // Si le chemin commence déjà par http, c'est une URL complète
    if (imagePath.startsWith('http')) {
      debugPrint('URL d\'image déjà complète: $imagePath');
      return imagePath;
    }

    // Si le chemin commence par /api/images, construire l'URL complète
    if (imagePath.startsWith('/api/images/')) {
      final baseUrlWithoutApi = baseUrl.split('/api').first;
      final fullUrl = '$baseUrlWithoutApi$imagePath';
      debugPrint('URL d\'image construite (chemin API): $fullUrl');
      return fullUrl;
    }

    // Si le chemin commence par /api/, construire l'URL complète
    if (imagePath.startsWith('/api/')) {
      final baseUrlWithoutApi = baseUrl.split('/api').first;
      final fullUrl = '$baseUrlWithoutApi$imagePath';
      debugPrint('URL d\'image construite (chemin API): $fullUrl');
      return fullUrl;
    }

    // Sinon, construire l'URL complète en supposant que c'est un nom de fichier
    // Supprimer le slash initial si présent pour éviter les doubles slashes
    final path = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    final fullUrl = '$baseUrl/images/$path';
    debugPrint('URL d\'image construite (nom de fichier): $fullUrl');
    return fullUrl;
  }
}
