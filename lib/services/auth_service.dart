import 'dart:convert';
import 'package:seatrace/models/user.dart';
import 'package:seatrace/models/pecheur.dart';
import 'package:seatrace/models/vitirinaire.dart';
import 'package:seatrace/models/maryeur.dart';
import 'package:seatrace/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Clé pour stocker l'utilisateur dans les préférences partagées
  static const String _userKey = 'current_user';
  
  // Clé pour stocker le token de vérification d'email
  static const String _verificationTokenKey = 'email_verification_token';

  // Obtenir l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = json.decode(userJson);
      return User.fromMap(userMap);
    } catch (e) {
      return null;
    }
  }

  // Sauvegarder l'utilisateur courant
  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toMap()));
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Connexion
  Future<User?> login(String email, String password) async {
    // Essayer de trouver l'utilisateur dans marketplace_user
    final userMap = await DatabaseHelper.instance.getUserByEmail(email);
    if (userMap != null && userMap['password'] == password) {
      final user = User.fromMap(userMap);
      
      // Vérifier si l'utilisateur est vérifié
      if (!user.isVerified) {
        throw Exception('Veuillez vérifier votre email avant de vous connecter');
      }
      
      // Vérifier si l'utilisateur est bloqué
      if (user.isBlocked) {
        throw Exception('Votre compte a été bloqué. Veuillez contacter l\'administrateur');
      }
      
      await saveCurrentUser(user);
      return user;
    }

    // Essayer de trouver l'utilisateur dans marketplace_pecheur
    final pecheurMap = await DatabaseHelper.instance.getPecheurByEmail(email);
    if (pecheurMap != null && pecheurMap['password'] == password) {
      final pecheur = Pecheur.fromMap(pecheurMap);
      
      // Vérifier si le pêcheur est validé
      if (pecheur.isValid != true) {
        throw Exception('Votre compte est en attente de validation par l\'administrateur');
      }
      
      final user = User(
        id: pecheur.id,
        email: pecheur.email,
        roles: pecheur.roles,
        password: pecheur.password,
        nom: pecheur.nom,
        prenom: pecheur.prenom,
        telephone: pecheur.telephone,
        isVerified: true,
        isBlocked: false,
        isValid: pecheur.isValid,
      );
      await saveCurrentUser(user);
      return user;
    }

    // Essayer de trouver l'utilisateur dans marketplace_vitirinaire
    final vitirinaireMap = await DatabaseHelper.instance.getVitirinaireByEmail(email);
    if (vitirinaireMap != null && vitirinaireMap['password'] == password) {
      final vitirinaire = Vitirinaire.fromMap(vitirinaireMap);
      
      // Vérifier si le vétérinaire est validé
      if (!vitirinaire.isValid) {
        throw Exception('Votre compte est en attente de validation par l\'administrateur');
      }
      
      final user = User(
        id: vitirinaire.id,
        email: vitirinaire.email,
        roles: vitirinaire.roles,
        password: vitirinaire.password,
        nom: vitirinaire.nom,
        prenom: vitirinaire.prenom,
        telephone: vitirinaire.telephone,
        isVerified: true,
        isBlocked: false,
        isValid: vitirinaire.isValid,
      );
      await saveCurrentUser(user);
      return user;
    }

    // Essayer de trouver l'utilisateur dans marketplace_maryeur
    final maryeurMap = await DatabaseHelper.instance.getMaryeurByEmail(email);
    if (maryeurMap != null && maryeurMap['password'] == password) {
      final maryeur = Maryeur.fromMap(maryeurMap);
      
      // Vérifier si le maryeur est validé
      if (!maryeur.isValid) {
        throw Exception('Votre compte est en attente de validation par l\'administrateur');
      }
      
      final user = User(
        id: maryeur.id,
        email: maryeur.email,
        roles: maryeur.roles,
        password: maryeur.password,
        nom: maryeur.nom,
        prenom: maryeur.prenom,
        telephone: maryeur.telephone,
        isVerified: true,
        isBlocked: false,
        isValid: maryeur.isValid,
      );
      await saveCurrentUser(user);
      return user;
    }

    return null;
  }
  
  // Rafraîchir les données de l'utilisateur courant
  Future<User?> refreshCurrentUser() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;
    
    User? updatedUser;
    
    if (currentUser.isPecheur()) {
      final pecheurMap = await DatabaseHelper.instance.queryPecheurById(currentUser.id!);
      if (pecheurMap != null) {
        final pecheur = Pecheur.fromMap(pecheurMap);
        updatedUser = User(
          id: pecheur.id,
          email: pecheur.email,
          roles: pecheur.roles,
          password: pecheur.password,
          nom: pecheur.nom,
          prenom: pecheur.prenom,
          telephone: pecheur.telephone,
          isVerified: true,
          isBlocked: false,
          isValid: pecheur.isValid,
        );
      }
    } else if (currentUser.isVeterinaire()) {
      final vitirinaireMap = await DatabaseHelper.instance.queryVitirinaireById(currentUser.id!);
      if (vitirinaireMap != null) {
        final vitirinaire = Vitirinaire.fromMap(vitirinaireMap);
        updatedUser = User(
          id: vitirinaire.id,
          email: vitirinaire.email,
          roles: vitirinaire.roles,
          password: vitirinaire.password,
          nom: vitirinaire.nom,
          prenom: vitirinaire.prenom,
          telephone: vitirinaire.telephone,
          isVerified: true,
          isBlocked: false,
          isValid: vitirinaire.isValid,
        );
      }
    } else if (currentUser.isMaryeur()) {
      final maryeurMap = await DatabaseHelper.instance.queryMaryeurById(currentUser.id!);
      if (maryeurMap != null) {
        final maryeur = Maryeur.fromMap(maryeurMap);
        updatedUser = User(
          id: maryeur.id,
          email: maryeur.email,
          roles: maryeur.roles,
          password: maryeur.password,
          nom: maryeur.nom,
          prenom: maryeur.prenom,
          telephone: maryeur.telephone,
          isVerified: true,
          isBlocked: false,
          isValid: maryeur.isValid,
        );
      }
    } else {
      final userMap = await DatabaseHelper.instance.queryUserById(currentUser.id!);
      if (userMap != null) {
        updatedUser = User.fromMap(userMap);
      }
    }
    
    if (updatedUser != null) {
      await saveCurrentUser(updatedUser);
      return updatedUser;
    }
    
    return currentUser;
  }
  
  // Générer un token de vérification d'email
  Future<String> generateEmailVerificationToken(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Stocker le token avec l'email
    final verificationTokens = prefs.getStringList(_verificationTokenKey) ?? [];
    verificationTokens.add('$email:$token');
    await prefs.setStringList(_verificationTokenKey, verificationTokens);
    
    return token;
  }
  
  // Vérifier un token d'email
  Future<bool> verifyEmailToken(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final verificationTokens = prefs.getStringList(_verificationTokenKey) ?? [];
    
    final tokenEntry = '$email:$token';
    if (verificationTokens.contains(tokenEntry)) {
      // Supprimer le token utilisé
      verificationTokens.remove(tokenEntry);
      await prefs.setStringList(_verificationTokenKey, verificationTokens);
      
      // Mettre à jour le statut de vérification de l'utilisateur
      final userMap = await DatabaseHelper.instance.getUserByEmail(email);
      if (userMap != null) {
        await DatabaseHelper.instance.update(
          'marketplace_user',
          {'is_verified': 1},
          'id = ?',
          [userMap['id']],
        );
        return true;
      }
    }
    
    return false;
  }
  
  // Réinitialiser le mot de passe
  Future<bool> resetPassword(String email, String newPassword) async {
    // Vérifier si l'email existe
    final userMap = await DatabaseHelper.instance.getUserByEmail(email);
    if (userMap != null) {
      await DatabaseHelper.instance.update(
        'marketplace_user',
        {'password': newPassword},
        'id = ?',
        [userMap['id']],
      );
      return true;
    }
    
    final pecheurMap = await DatabaseHelper.instance.getPecheurByEmail(email);
    if (pecheurMap != null) {
      await DatabaseHelper.instance.update(
        'marketplace_pecheur',
        {'password': newPassword},
        'id = ?',
        [pecheurMap['id']],
      );
      return true;
    }
    
    final vitirinaireMap = await DatabaseHelper.instance.getVitirinaireByEmail(email);
    if (vitirinaireMap != null) {
      await DatabaseHelper.instance.update(
        'marketplace_vitirinaire',
        {'password': newPassword},
        'id = ?',
        [vitirinaireMap['id']],
      );
      return true;
    }
    
    final maryeurMap = await DatabaseHelper.instance.getMaryeurByEmail(email);
    if (maryeurMap != null) {
      await DatabaseHelper.instance.update(
        'marketplace_maryeur',
        {'password': newPassword},
        'id = ?',
        [maryeurMap['id']],
      );
      return true;
    }
    
    return false;
  }
}
