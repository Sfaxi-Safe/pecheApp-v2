import 'dart:convert';
import 'package:peche_app/models/user.dart';
import 'package:peche_app/models/pecheur.dart';
import 'package:peche_app/models/vitirinaire.dart';
import 'package:peche_app/models/maryeur.dart';
import 'package:peche_app/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson == null) return null;
    
    try {
      final userMap = json.decode(userJson);
      return User.fromMap(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toMap()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  Future<User?> login(String email, String password) async {
    // Try to find user in marketplace_user
    final userMap = await DatabaseHelper.instance.getUserByEmail(email);
    if (userMap != null && userMap['password'] == password) {
      final user = User.fromMap(userMap);
      await saveCurrentUser(user);
      return user;
    }

    // Try to find user in marketplace_pecheur
    final pecheurMap = await DatabaseHelper.instance.getPecheurByEmail(email);
    if (pecheurMap != null && pecheurMap['password'] == password) {
      final pecheur = Pecheur.fromMap(pecheurMap);
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

    // Try to find user in marketplace_vitirinaire
    final vitirinaireMap = await DatabaseHelper.instance.getVitirinaireByEmail(email);
    if (vitirinaireMap != null && vitirinaireMap['password'] == password) {
      final vitirinaire = Vitirinaire.fromMap(vitirinaireMap);
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

    // Try to find user in marketplace_maryeur
    final maryeurMap = await DatabaseHelper.instance.getMaryeurByEmail(email);
    if (maryeurMap != null && maryeurMap['password'] == password) {
      final maryeur = Maryeur.fromMap(maryeurMap);
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
}
