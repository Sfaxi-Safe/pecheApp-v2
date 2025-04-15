import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/fisherman.dart';
import '../models/fish.dart';
import '../models/review.dart';
import '../models/order.dart';
import '../models/lot.dart';
import '../models/catch.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Nom de la base de données
  static const String dbName = 'peche_app.db';
  
  // Noms des tables
  static const String userTable = 'users';
  static const String fishermanTable = 'fishermen';
  static const String fishTable = 'fishes';
  static const String reviewTable = 'reviews';
  static const String orderTable = 'orders';
  static const String lotTable = 'lots';
  static const String catchTable = 'catches';
  
  // Singleton pattern
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Création de la table users
    await db.execute('''
      CREATE TABLE $userTable (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        userType TEXT NOT NULL,
        profileImageUrl TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // Création de la table fishermen (informations spécifiques aux pêcheurs)
    await db.execute('''
      CREATE TABLE $fishermanTable (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        cin TEXT,
        matricule TEXT,
        capacite TEXT,
        longeur TEXT,
        largeur TEXT,
        bateau TEXT,
        pays TEXT,
        proprietaire TEXT,
        serie TEXT,
        certification TEXT,
        port TEXT,
        engin TEXT,
        telephone TEXT,
        isValid INTEGER
      )
    ''');

    // Création de la table fishes
    await db.execute('''
      CREATE TABLE $fishTable (
        id TEXT PRIMARY KEY,
        species TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        weight REAL NOT NULL,
        length REAL NOT NULL,
        location TEXT NOT NULL,
        fishingMethod TEXT NOT NULL,
        captureDate TEXT NOT NULL,
        fishermanId TEXT NOT NULL,
        FOREIGN KEY (fishermanId) REFERENCES $fishermanTable (id)
      )
    ''');

    // Création de la table reviews
    await db.execute('''
      CREATE TABLE $reviewTable (
        id TEXT PRIMARY KEY,
        fishId TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        userImageUrl TEXT,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (fishId) REFERENCES $fishTable (id),
        FOREIGN KEY (userId) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table orders
    await db.execute('''
      CREATE TABLE $orderTable (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        fishId TEXT NOT NULL,
        fishermanId TEXT NOT NULL,
        quantity REAL NOT NULL,
        totalPrice REAL NOT NULL,
        status INTEGER NOT NULL,
        orderDate TEXT NOT NULL,
        deliveryDate TEXT,
        deliveryAddress TEXT,
        notes TEXT,
        FOREIGN KEY (clientId) REFERENCES $userTable (id),
        FOREIGN KEY (fishId) REFERENCES $fishTable (id),
        FOREIGN KEY (fishermanId) REFERENCES $fishermanTable (id)
      )
    ''');

    // Création de la table lots
    await db.execute('''
      CREATE TABLE $lotTable (
        id TEXT PRIMARY KEY,
        rfidId TEXT,
        veterinaireId TEXT,
        identifiant TEXT,
        photo TEXT NOT NULL,
        quantite TEXT NOT NULL,
        poid TEXT,
        espece TEXT NOT NULL,
        temperature TEXT,
        prixInitial TEXT,
        prixMinimal TEXT,
        prixFinale TEXT,
        dateTest TEXT,
        test INTEGER,
        status INTEGER,
        vendre INTEGER,
        priseId TEXT,
        userId TEXT,
        dateSoumettre TEXT,
        poidEstimatif TEXT,
        typeEnchere TEXT,
        current TEXT,
        online TEXT,
        isProduit INTEGER
      )
    ''');

    // Création de la table catches
    await db.execute('''
      CREATE TABLE $catchTable (
        id TEXT PRIMARY KEY,
        fishermanId TEXT NOT NULL,
        maryeurId TEXT,
        nom TEXT NOT NULL,
        debut TEXT NOT NULL,
        fin TEXT,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        engin TEXT NOT NULL,
        zone TEXT,
        affectationDate TEXT,
        dateDebarquement TEXT,
        FOREIGN KEY (fishermanId) REFERENCES $fishermanTable (id)
      )
    ''');
  }

  // Méthodes CRUD pour les utilisateurs
  Future<int> insertUser(User user) async {
    Database db = await database;
    return await db.insert(
      userTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<User?> getUserById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(userTable);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<int> updateUser(User user) async {
    Database db = await database;
    return await db.update(
      userTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    Database db = await database;
    return await db.delete(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les pêcheurs
  Future<int> insertFisherman(Fisherman fisherman) async {
    Database db = await database;
    return await db.insert(
      fishermanTable,
      fisherman.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Fisherman?> getFishermanById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishermanTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Fisherman.fromMap(maps.first);
    }
    return null;
  }

  Future<Fisherman?> getFishermanByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishermanTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return Fisherman.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Fisherman>> getAllFishermen() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(fishermanTable);
    return List.generate(maps.length, (i) => Fisherman.fromMap(maps[i]));
  }

  Future<int> updateFisherman(Fisherman fisherman) async {
    Database db = await database;
    return await db.update(
      fishermanTable,
      fisherman.toMap(),
      where: 'id = ?',
      whereArgs: [fisherman.id],
    );
  }

  Future<int> deleteFisherman(String id) async {
    Database db = await database;
    return await db.delete(
      fishermanTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les poissons
  Future<int> insertFish(Fish fish) async {
    Database db = await database;
    return await db.insert(
      fishTable,
      fish.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Fish?> getFishById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Fish.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Fish>> getAllFishes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(fishTable);
    return List.generate(maps.length, (i) => Fish.fromMap(maps[i]));
  }

  Future<List<Fish>> getFishesByFisherman(String fishermanId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'fishermanId = ?',
      whereArgs: [fishermanId],
    );
    return List.generate(maps.length, (i) => Fish.fromMap(maps[i]));
  }

  Future<int> updateFish(Fish fish) async {
    Database db = await database;
    return await db.update(
      fishTable,
      fish.toMap(),
      where: 'id = ?',
      whereArgs: [fish.id],
    );
  }

  Future<int> deleteFish(String id) async {
    Database db = await database;
    return await db.delete(
      fishTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les avis
  Future<int> insertReview(Review review) async {
    Database db = await database;
    return await db.insert(
      reviewTable,
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Review?> getReviewById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      reviewTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Review.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Review>> getReviewsByFish(String fishId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      reviewTable,
      where: 'fishId = ?',
      whereArgs: [fishId],
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<List<Review>> getReviewsByUser(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      reviewTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Review.fromMap(maps[i]));
  }

  Future<int> updateReview(Review review) async {
    Database db = await database;
    return await db.update(
      reviewTable,
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(String id) async {
    Database db = await database;
    return await db.delete(
      reviewTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les commandes
  Future<int> insertOrder(PecheOrder order) async {
    Database db = await database;
    return await db.insert(
      orderTable,
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PecheOrder?> getOrderById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      orderTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PecheOrder.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PecheOrder>> getOrdersByClient(String clientId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      orderTable,
      where: 'clientId = ?',
      whereArgs: [clientId],
    );
    return List.generate(maps.length, (i) => PecheOrder.fromMap(maps[i]));
  }

  Future<List<PecheOrder>> getOrdersByFisherman(String fishermanId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      orderTable,
      where: 'fishermanId = ?',
      whereArgs: [fishermanId],
    );
    return List.generate(maps.length, (i) => PecheOrder.fromMap(maps[i]));
  }

  Future<int> updateOrder(PecheOrder order) async {
    Database db = await database;
    return await db.update(
      orderTable,
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(String id) async {
    Database db = await database;
    return await db.delete(
      orderTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les lots
  Future<int> insertLot(Lot lot) async {
    Database db = await database;
    return await db.insert(
      lotTable,
      lot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Lot?> getLotById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      lotTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Lot.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Lot>> getAllLots() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(lotTable);
    return List.generate(maps.length, (i) => Lot.fromMap(maps[i]));
  }

  Future<int> updateLot(Lot lot) async {
    Database db = await database;
    return await db.update(
      lotTable,
      lot.toMap(),
      where: 'id = ?',
      whereArgs: [lot.id],
    );
  }

  Future<int> deleteLot(String id) async {
    Database db = await database;
    return await db.delete(
      lotTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les captures
  Future<int> insertCatch(Catch catch_) async {
    Database db = await database;
    return await db.insert(
      catchTable,
      catch_.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Catch?> getCatchById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      catchTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Catch.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Catch>> getCatchesByFisherman(String fishermanId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      catchTable,
      where: 'fishermanId = ?',
      whereArgs: [fishermanId],
    );
    return List.generate(maps.length, (i) => Catch.fromMap(maps[i]));
  }

  Future<int> updateCatch(Catch catch_) async {
    Database db = await database;
    return await db.update(
      catchTable,
      catch_.toMap(),
      where: 'id = ?',
      whereArgs: [catch_.id],
    );
  }

  Future<int> deleteCatch(String id) async {
    Database db = await database;
    return await db.delete(
      catchTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
