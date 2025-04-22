import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fish_marketplace/models/espece.dart';
import 'package:fish_marketplace/models/lot.dart';
import 'package:fish_marketplace/models/maryeur.dart';
import 'package:fish_marketplace/models/pecheur.dart';
import 'package:fish_marketplace/models/prise.dart';
import 'package:fish_marketplace/models/user.dart';
import 'package:fish_marketplace/models/vitirinaire.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fish_marketplace.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const boolType = 'INTEGER';
    const jsonType = 'TEXT';

    // Create User table
    await db.execute('''
    CREATE TABLE marketplace_user (
      id $idType,
      email $textType,
      roles $jsonType NOT NULL,
      password $textType,
      nom $textType,
      prenom $textType,
      telephone $intType,
      is_verified $boolType NOT NULL,
      is_blocked $boolType NOT NULL,
      civilite $textType,
      service $textType,
      fonction $textType,
      mobile $textType,
      linkedin $textType,
      facebook $textType,
      tweeter $textType,
      photo $textType,
      is_valid $boolType,
      adresse $textType
    )
    ''');

    // Create Pecheur table
    await db.execute('''
    CREATE TABLE marketplace_pecheur (
      id $idType,
      email $textType,
      roles $jsonType NOT NULL,
      password $textType,
      nom $textType,
      prenom $textType,
      cin $textType,
      matricule $textType,
      capacite $textType,
      longeur $textType,
      largeur $textType,
      bateau $textType,
      pays $textType,
      proprietaire $textType,
      serie $textType,
      certification $textType,
      port $textType,
      engin $textType,
      wallet $textType,
      mykeyss $textType,
      telephone $intType,
      is_valid $boolType
    )
    ''');

    // Create Vitirinaire table
    await db.execute('''
    CREATE TABLE marketplace_vitirinaire (
      id $idType,
      email $textType,
      roles $jsonType NOT NULL,
      password $textType,
      nom $textType,
      prenom $textType,
      cin $textType,
      matricule $textType,
      port $textType,
      pays $textType,
      wallet $textType,
      mykeyss $textType,
      telephone $intType,
      is_valid $boolType NOT NULL
    )
    ''');

    // Create Maryeur table
    await db.execute('''
    CREATE TABLE marketplace_maryeur (
      id $idType,
      email $textType,
      roles $jsonType NOT NULL,
      password $textType,
      nom $textType,
      prenom $textType,
      cin $textType,
      matricule $textType,
      port $textType,
      pays $textType,
      wallet $textType,
      mykeyss $textType,
      telephone $intType,
      is_valid $boolType NOT NULL,
      signature $textType
    )
    ''');

    // Create Espece table
    await db.execute('''
    CREATE TABLE marketplace_espece (
      id $idType,
      nom $textType,
      image_url $textType
    )
    ''');

    // Create Prise table
    await db.execute('''
    CREATE TABLE marketplace_prise (
      id $idType,
      pecheur_id $intType,
      maryeur_id $intType,
      nom $textType,
      debut $textType,
      fin $textType,
      latitude $textType,
      langitude $textType,
      engin $textType,
      zone $textType,
      affectationdate $textType,
      datedebarquement $textType
    )
    ''');

    // Create Lots table
    await db.execute('''
    CREATE TABLE marketplace_lots (
      id $idType,
      rfid_id $intType,
      vitirinaire_id $intType,
      identifiant $textType,
      photo $textType,
      quantite $textType,
      poid $textType,
      espece $textType,
      temperature $textType,
      prixinitial $textType,
      prixminimal $textType,
      prixfinale $textType,
      datetest $textType,
      test $boolType,
      status $boolType,
      vendre $boolType,
      prise_id $intType,
      user_id $intType,
      datesoumettre $textType,
      poidestimatif $textType,
      typeenchere $textType,
      current $textType,
      online $textType,
      is_produit $boolType
    )
    ''');

    // Insert sample data for testing
    await _insertSampleData(db);
  }

  Future _insertSampleData(Database db) async {
    // Insert sample users
    await db.insert('marketplace_user', {
      'email': 'client@example.com',
      'roles': '["ROLE_CLIENT"]',
      'password': 'password123',
      'nom': 'Dupont',
      'prenom': 'Jean',
      'telephone': 123456789,
      'is_verified': 1,
      'is_blocked': 0,
      'is_valid': 1,
    });

    // Insert sample pecheur
    await db.insert('marketplace_pecheur', {
      'email': 'pecheur@example.com',
      'roles': '["ROLE_PECHEUR"]',
      'password': 'password123',
      'nom': 'Martin',
      'prenom': 'Pierre',
      'cin': 'AB123456',
      'matricule': 'P001',
      'capacite': '500kg',
      'bateau': 'Bateau 1',
      'port': 'Port A',
      'telephone': 987654321,
      'is_valid': 1,
    });

    // Insert sample vitirinaire
    await db.insert('marketplace_vitirinaire', {
      'email': 'vet@example.com',
      'roles': '["ROLE_VETERINAIRE"]',
      'password': 'password123',
      'nom': 'Dubois',
      'prenom': 'Marie',
      'cin': 'CD789012',
      'matricule': 'V001',
      'port': 'Port A',
      'telephone': 456789123,
      'is_valid': 1,
    });

    // Insert sample maryeur
    await db.insert('marketplace_maryeur', {
      'email': 'maryeur@example.com',
      'roles': '["ROLE_MARYEUR"]',
      'password': 'password123',
      'nom': 'Leroy',
      'prenom': 'Sophie',
      'cin': 'EF345678',
      'matricule': 'M001',
      'port': 'Port A',
      'telephone': 789123456,
      'is_valid': 1,
    });

    // Insert sample especes
    await db.insert('marketplace_espece', {
      'nom': 'Thon rouge',
      'image_url': 'assets/images/thon.jpg',
    });

    await db.insert('marketplace_espece', {
      'nom': 'Dorade',
      'image_url': 'assets/images/dorade.jpg',
    });

    await db.insert('marketplace_espece', {
      'nom': 'Sardine',
      'image_url': 'assets/images/sardine.jpg',
    });

    // Insert sample prise
    final priseId = await db.insert('marketplace_prise', {
      'pecheur_id': 1,
      'maryeur_id': 1,
      'nom': 'Prise 1',
      'debut': '2023-04-20 08:00:00',
      'fin': '2023-04-20 12:00:00',
      'latitude': '43.296482',
      'langitude': '5.369780',
      'engin': 'Filet',
      'zone': 'Zone A',
      'affectationdate': '2023-04-20',
      'datedebarquement': '2023-04-20',
    });

    // Insert sample lots
    await db.insert('marketplace_lots', {
      'prise_id': priseId,
      'vitirinaire_id': 1,
      'identifiant': 'LOT001',
      'photo': 'assets/images/thon.jpg',
      'quantite': '100',
      'poid': '50',
      'espece': 'Thon rouge',
      'temperature': '4',
      'test': 1,
      'status': 1,
      'vendre': 0,
      'datetest': '2023-04-21',
      'datesoumettre': '2023-04-21',
      'poidestimatif': '50',
      'is_produit': 1,
    });
  }

  // Query methods for authentication
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_user',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPecheurByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_pecheur',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getVitirinaireByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_vitirinaire',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getMaryeurByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_maryeur',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Generic query method
  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Insert methods
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_user', row);
  }

  Future<int> insertPecheur(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_pecheur', row);
  }

  Future<int> insertVitirinaire(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_vitirinaire', row);
  }

  Future<int> insertMaryeur(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_maryeur', row);
  }

  Future<int> insertEspece(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_espece', row);
  }

  Future<int> insertPrise(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_prise', row);
  }

  Future<int> insertLot(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('marketplace_lots', row);
  }

  // Query methods
  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    final db = await instance.database;
    return await db.query('marketplace_user');
  }

  Future<List<Map<String, dynamic>>> queryAllPecheurs() async {
    final db = await instance.database;
    return await db.query('marketplace_pecheur');
  }

  Future<List<Map<String, dynamic>>> queryAllVitirinaires() async {
    final db = await instance.database;
    return await db.query('marketplace_vitirinaire');
  }

  Future<List<Map<String, dynamic>>> queryAllMaryeurs() async {
    final db = await instance.database;
    return await db.query('marketplace_maryeur');
  }

  Future<List<Map<String, dynamic>>> queryAllEspeces() async {
    final db = await instance.database;
    return await db.query('marketplace_espece');
  }

  Future<List<Map<String, dynamic>>> queryAllPrises() async {
    final db = await instance.database;
    return await db.query('marketplace_prise');
  }

  Future<List<Map<String, dynamic>>> queryAllLots() async {
    final db = await instance.database;
    return await db.query('marketplace_lots');
  }

  // Query by ID methods
  Future<Map<String, dynamic>?> queryUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_user',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryPecheurById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_pecheur',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryVitirinaireById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_vitirinaire',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryMaryeurById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_maryeur',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryEspeceById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_espece',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryPriseById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_prise',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> queryLotById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'marketplace_lots',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // Update methods
  Future<int> updateUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_user',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePecheur(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_pecheur',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateVitirinaire(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_vitirinaire',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateMaryeur(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_maryeur',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateEspece(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_espece',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updatePrise(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_prise',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateLot(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(
      'marketplace_lots',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete methods
  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_user',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePecheur(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_pecheur',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteVitirinaire(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_vitirinaire',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMaryeur(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_maryeur',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEspece(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_espece',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePrise(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_prise',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLot(int id) async {
    final db = await instance.database;
    return await db.delete(
      'marketplace_lots',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Custom queries
  Future<List<Map<String, dynamic>>> queryLotsByPecheurId(int pecheurId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.* FROM marketplace_lots l
      JOIN marketplace_prise p ON l.prise_id = p.id
      WHERE p.pecheur_id = ?
    ''', [pecheurId]);
  }

  Future<List<Map<String, dynamic>>> queryLotsByVitirinaireId(int vitirinaireId) async {
    final db = await instance.database;
    return await db.query(
      'marketplace_lots',
      where: 'vitirinaire_id = ?',
      whereArgs: [vitirinaireId],
    );
  }

  Future<List<Map<String, dynamic>>> queryLotsByMaryeurId(int maryeurId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.* FROM marketplace_lots l
      JOIN marketplace_prise p ON l.prise_id = p.id
      WHERE p.maryeur_id = ?
    ''', [maryeurId]);
  }

  Future<List<Map<String, dynamic>>> queryPendingLotsForVitirinaire() async {
    final db = await instance.database;
    return await db.query(
      'marketplace_lots',
      where: 'test = ? AND status IS NULL',
      whereArgs: [0], // 0 means not tested yet
    );
  }

  Future<List<Map<String, dynamic>>> queryApprovedLotsForMaryeur(int maryeurId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.* FROM marketplace_lots l
      JOIN marketplace_prise p ON l.prise_id = p.id
      WHERE p.maryeur_id = ? AND l.status = ? AND l.prixinitial IS NULL
    ''', [maryeurId, 1]); // 1 means approved by vitirinaire
  }

  Future<List<Map<String, dynamic>>> queryAvailableAuctions() async {
    final db = await instance.database;
    return await db.query(
      'marketplace_lots',
      where: 'status = ? AND prixinitial IS NOT NULL AND vendre = ?',
      whereArgs: [1, 0], // 1 means approved, 0 means not sold yet
    );
  }

  Future<List<Map<String, dynamic>>> queryPurchasesByUserId(int userId) async {
    final db = await instance.database;
    return await db.query(
      'marketplace_lots',
      where: 'user_id = ? AND vendre = ?',
      whereArgs: [userId, 1], // 1 means sold
    );
  }

  // Get lots by user role
  Future<List<Map<String, dynamic>>> getLotsByPecheurId(int pecheurId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.* FROM marketplace_lots l
      JOIN marketplace_prise p ON l.prise_id = p.id
      WHERE p.pecheur_id = ?
    ''', [pecheurId]);
  }

  Future<List<Map<String, dynamic>>> getLotsByMaryeurId(int maryeurId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT l.* FROM marketplace_lots l
      JOIN marketplace_prise p ON l.prise_id = p.id
      WHERE p.maryeur_id = ?
    ''', [maryeurId]);
  }

  // Check if email exists in any table
  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    if (user != null) return true;
    
    final pecheur = await getPecheurByEmail(email);
    if (pecheur != null) return true;
    
    final vitirinaire = await getVitirinaireByEmail(email);
    if (vitirinaire != null) return true;
    
    final maryeur = await getMaryeurByEmail(email);
    if (maryeur != null) return true;
    
    return false;
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
