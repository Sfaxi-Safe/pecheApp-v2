import 'dart:convert';
import 'package:http/http.dart' as http;

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
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw _handleError(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête GET: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw _handleError(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête POST: $e');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw _handleError(response);
    } catch (e) {
      throw Exception('Erreur lors de la requête PUT: $e');
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  Exception _handleError(http.Response response) {
    try {
      final Map<String, dynamic> body = json.decode(response.body);
      return Exception(body['message'] ?? 'Une erreur est survenue');
    } catch (e) {
      return Exception('Erreur ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Méthodes spécifiques pour les utilisateurs
  Future<List<Map<String, dynamic>>> getUsers(String role) async {
    final response = await get('users?role=$role');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    return await get('users/$id');
  }

  // Méthodes spécifiques pour les lots
  Future<List<Map<String, dynamic>>> getLotsByPecheurId(int pecheurId) async {
    final response = await get('lots/pecheur/$pecheurId');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  Future<List<Map<String, dynamic>>> getAvailableAuctions() async {
    final response = await get('lots/available');
    return List<Map<String, dynamic>>.from(response['data']);
  }

  Future<Map<String, dynamic>> getAuctionDetails(int auctionId) async {
    return await get('lots/$auctionId');
  }

  Future<Map<String, dynamic>> getPriseDetails(int priseId) async {
    return await get('prises/$priseId');
  }

  Future<Map<String, dynamic>> getPecheurDetails(int pecheurId) async {
    return await get('pecheurs/$pecheurId');
  }

  Future<Map<String, dynamic>> getVeterinaireDetails(int veterinaireId) async {
    return await get('veterinaires/$veterinaireId');
  }

  Future<Map<String, dynamic>> getMaryeurDetails(int maryeurId) async {
    return await get('maryeurs/$maryeurId');
  }

  Future<void> placeBid(int auctionId, double bidAmount, int userId) async {
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

  Future<Map<String, dynamic>> createEspece(String nom, {String? imageUrl}) async {
    return await post('especes', {'nom': nom, 'image_url': imageUrl});
  }

  // Méthodes spécifiques pour l'authentification
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await post('auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post('auth/register', userData);
  }
}

