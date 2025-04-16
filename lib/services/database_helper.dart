import 'package:uuid/uuid.dart';
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
import '../models/message.dart';
import '../models/payment.dart';

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
  static const String messageTable = 'messages';
  static const String conversationTable = 'conversations';
  static const String paymentTable = 'payments';
  
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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  // Optimisation: Ajouter des index lors de l'ouverture de la base de données
  Future<void> _onOpen(Database db) async {
    // Vérifier si les index existent déjà
    final indexesResult = await db.rawQuery("SELECT name FROM sqlite_master WHERE type = 'index'");
    final existingIndexes = indexesResult.map((e) => e['name'] as String).toList();

    // Créer des index pour les colonnes fréquemment utilisées dans les requêtes
    if (!existingIndexes.contains('idx_fish_fishermanId')) {
      await db.execute('CREATE INDEX idx_fish_fishermanId ON $fishTable (fishermanId)');
    }
    
    if (!existingIndexes.contains('idx_review_fishId')) {
      await db.execute('CREATE INDEX idx_review_fishId ON $reviewTable (fishId)');
    }
    
    if (!existingIndexes.contains('idx_order_clientId')) {
      await db.execute('CREATE INDEX idx_order_clientId ON $orderTable (clientId)');
    }
    
    if (!existingIndexes.contains('idx_order_fishermanId')) {
      await db.execute('CREATE INDEX idx_order_fishermanId ON $orderTable (fishermanId)');
    }
    
    if (!existingIndexes.contains('idx_message_senderId_receiverId')) {
      await db.execute('CREATE INDEX idx_message_senderId_receiverId ON $messageTable (senderId, receiverId)');
    }
    
    if (!existingIndexes.contains('idx_conversation_user1Id_user2Id')) {
      await db.execute('CREATE INDEX idx_conversation_user1Id_user2Id ON $conversationTable (user1Id, user2Id)');
    }
    
    if (!existingIndexes.contains('idx_payment_orderId')) {
      await db.execute('CREATE INDEX idx_payment_orderId ON $paymentTable (orderId)');
    }
    
    if (!existingIndexes.contains('idx_payment_userId')) {
      await db.execute('CREATE INDEX idx_payment_userId ON $paymentTable (userId)');
    }
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

    // Création de la table messages
    await db.execute('''
      CREATE TABLE $messageTable (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        imageUrl TEXT,
        FOREIGN KEY (senderId) REFERENCES $userTable (id),
        FOREIGN KEY (receiverId) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table conversations
    await db.execute('''
      CREATE TABLE $conversationTable (
        id TEXT PRIMARY KEY,
        user1Id TEXT NOT NULL,
        user2Id TEXT NOT NULL,
        lastMessageTime TEXT NOT NULL,
        lastMessageContent TEXT,
        hasUnreadMessages INTEGER NOT NULL,
        FOREIGN KEY (user1Id) REFERENCES $userTable (id),
        FOREIGN KEY (user2Id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table payments
    await db.execute('''
      CREATE TABLE $paymentTable (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        status INTEGER NOT NULL,
        method INTEGER NOT NULL,
        date TEXT NOT NULL,
        transactionId TEXT,
        notes TEXT,
        FOREIGN KEY (orderId) REFERENCES $orderTable (id),
        FOREIGN KEY (userId) REFERENCES $userTable (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajout des tables de messagerie si elles n'existent pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $messageTable (
          id TEXT PRIMARY KEY,
          senderId TEXT NOT NULL,
          receiverId TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          isRead INTEGER NOT NULL,
          imageUrl TEXT,
          FOREIGN KEY (senderId) REFERENCES $userTable (id),
          FOREIGN KEY (receiverId) REFERENCES $userTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $conversationTable (
          id TEXT PRIMARY KEY,
          user1Id TEXT NOT NULL,
          user2Id TEXT NOT NULL,
          lastMessageTime TEXT NOT NULL,
          lastMessageContent TEXT,
          hasUnreadMessages INTEGER NOT NULL,
          FOREIGN KEY (user1Id) REFERENCES $userTable (id),
          FOREIGN KEY (user2Id) REFERENCES $userTable (id)
        )
      ''');
    }

    if (oldVersion < 3) {
      // Ajout de la table payments si elle n'existe pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $paymentTable (
          id TEXT PRIMARY KEY,
          orderId TEXT NOT NULL,
          userId TEXT NOT NULL,
          amount REAL NOT NULL,
          status INTEGER NOT NULL,
          method INTEGER NOT NULL,
          date TEXT NOT NULL,
          transactionId TEXT,
          notes TEXT,
          FOREIGN KEY (orderId) REFERENCES $orderTable (id),
          FOREIGN KEY (userId) REFERENCES $userTable (id)
        )
      ''');
    }
  }

  // Optimisation: Utiliser des transactions pour les opérations multiples
  Future<void> batchInsert<T>(String table, List<Map<String, dynamic>> items) async {
    final db = await database;
    final batch = db.batch();
    
    for (var item in items) {
      batch.insert(table, item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
  }

  // Optimisation: Pagination pour les requêtes de grande taille
  Future<List<Fish>> getFishesPaginated(int page, int pageSize) async {
    final db = await database;
    final offset = page * pageSize;
    
    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      limit: pageSize,
      offset: offset,
      orderBy: 'captureDate DESC',
    );
    
    return List.generate(maps.length, (i) => Fish.fromMap(maps[i]));
  }

  // Optimisation: Requête avec jointure pour récupérer les poissons avec leurs avis
  Future<List<Map<String, dynamic>>> getFishesWithReviews() async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT f.*, 
             COUNT(r.id) as reviewCount, 
             AVG(r.rating) as averageRating
      FROM $fishTable f
      LEFT JOIN $reviewTable r ON f.id = r.fishId
      GROUP BY f.id
      ORDER BY f.captureDate DESC
    ''');
  }

  // Optimisation: Requête avec jointure pour récupérer les commandes avec les détails du poisson
  Future<List<Map<String, dynamic>>> getOrdersWithDetails(String userId, String userType) async {
    final db = await database;
    final whereClause = userType == 'client' ? 'o.clientId = ?' : 'o.fishermanId = ?';
    
    return await db.rawQuery('''
      SELECT o.*, 
             f.species, 
             f.imageUrl,
             u.name as otherUserName,
             u.profileImageUrl as otherUserImageUrl
      FROM $orderTable o
      JOIN $fishTable f ON o.fishId = f.id
      JOIN $userTable u ON (
        CASE 
          WHEN ? = 'client' THEN o.fishermanId 
          ELSE o.clientId 
        END = u.id
      )
      WHERE $whereClause
      ORDER BY o.orderDate DESC
    ''', [userType, userId]);
  }

  // Optimisation: Requête pour vérifier si un email existe déjà
  Future<bool> isEmailTaken(String email) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $userTable WHERE email = ?',
      [email],
    );
    
    return (result.first.values.first as int) > 0;
  }

  // Optimisation: Requête pour obtenir le nombre de commandes par statut
  Future<Map<OrderStatus, int>> getOrderCountsByStatus(String userId, String userType) async {
    final db = await database;
    final whereClause = userType == 'client' ? 'clientId = ?' : 'fishermanId = ?';
    
    final result = await db.rawQuery(
      'SELECT status, COUNT(*) as count FROM $orderTable WHERE $whereClause GROUP BY status',
      [userId],
    );
    
    final Map<OrderStatus, int> counts = {};
    for (var status in OrderStatus.values) {
      counts[status] = 0;
    }
    
    for (var row in result) {
      final status = OrderStatus.values[row['status'] as int];
      counts[status] = row['count'] as int;
    }
    
    return counts;
  }

  // Optimisation: Requête pour obtenir les statistiques de vente par mois
  Future<List<Map<String, dynamic>>> getMonthlySalesStats(String fishermanId) async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', orderDate) as month,
        COUNT(*) as orderCount,
        SUM(totalPrice) as totalSales
      FROM $orderTable
      WHERE fishermanId = ? AND status != ?
      GROUP BY month
      ORDER BY month DESC
      LIMIT 12
    ''', [fishermanId, OrderStatus.cancelled.index]);
  }

  // Optimisation: Requête pour obtenir les espèces les plus vendues
  Future<List<Map<String, dynamic>>> getTopSellingSpecies(String fishermanId) async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT 
        f.species,
        COUNT(o.id) as orderCount,
        SUM(o.quantity) as totalQuantity
      FROM $orderTable o
      JOIN $fishTable f ON o.fishId = f.id
      WHERE o.fishermanId = ? AND o.status != ?
      GROUP BY f.species
      ORDER BY orderCount DESC
      LIMIT 5
    ''', [fishermanId, OrderStatus.cancelled.index]);
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

  // Méthodes CRUD pour les messages
  Future<int> insertMessage(Message message) async {
    Database db = await database;
    return await db.insert(
      messageTable,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Message?> getMessageById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      messageTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Message.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Message>> getMessagesBetweenUsers(String userId1, String userId2) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM $messageTable 
      WHERE (senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)
      ORDER BY timestamp ASC
    ''', [userId1, userId2, userId2, userId1]);
    
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }

  Future<int> markMessageAsRead(String messageId) async {
    Database db = await database;
    return await db.update(
      messageTable,
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<int> markAllMessagesAsRead(String receiverId, String senderId) async {
    Database db = await database;
    return await db.update(
      messageTable,
      {'isRead': 1},
      where: 'receiverId = ? AND senderId = ? AND isRead = 0',
      whereArgs: [receiverId, senderId],
    );
  }

  Future<int> deleteMessage(String id) async {
    Database db = await database;
    return await db.delete(
      messageTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les conversations
  Future<String> getOrCreateConversation(String user1Id, String user2Id) async {
    Database db = await database;
    
    // Vérifier si une conversation existe déjà entre ces deux utilisateurs
    List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM $conversationTable 
      WHERE (user1Id = ? AND user2Id = ?) OR (user1Id = ? AND user2Id = ?)
    ''', [user1Id, user2Id, user2Id, user1Id]);
    
    if (maps.isNotEmpty) {
      return maps.first['id'] as String;
    }
    
    // Créer une nouvelle conversation
    final conversationId = const Uuid().v4();
    await db.insert(
      conversationTable,
      {
        'id': conversationId,
        'user1Id': user1Id,
        'user2Id': user2Id,
        'lastMessageTime': DateTime.now().toIso8601String(),
        'lastMessageContent': null,
        'hasUnreadMessages': 0,
      },
    );
    
    return conversationId;
  }

  Future<List<Map<String, dynamic>>> getConversationsForUser(String userId) async {
    Database db = await database;
    
    // Récupérer toutes les conversations où l'utilisateur est impliqué
    List<Map<String, dynamic>> conversations = await db.rawQuery('''
      SELECT c.*, 
             CASE 
               WHEN c.user1Id = ? THEN c.user2Id 
               ELSE c.user1Id 
             END as otherUserId,
             u.name as otherUserName,
             u.profileImageUrl as otherUserImageUrl,
             u.userType as otherUserType
      FROM $conversationTable c
      JOIN $userTable u ON (
        CASE 
          WHEN c.user1Id = ? THEN c.user2Id 
          ELSE c.user1Id 
        END = u.id
      )
      WHERE c.user1Id = ? OR c.user2Id = ?
      ORDER BY c.lastMessageTime DESC
    ''', [userId, userId, userId, userId]);
    
    return conversations;
  }

  Future<int> updateConversationLastMessage(String conversationId, String content, DateTime timestamp, bool hasUnread) async {
    Database db = await database;
    return await db.update(
      conversationTable,
      {
        'lastMessageContent': content,
        'lastMessageTime': timestamp.toIso8601String(),
        'hasUnreadMessages': hasUnread ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<int> markConversationAsRead(String conversationId) async {
    Database db = await database;
    return await db.update(
      conversationTable,
      {'hasUnreadMessages': 0},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<int> deleteConversation(String conversationId) async {
    Database db = await database;
    
    // Supprimer tous les messages de la conversation
    await db.rawDelete('''
      DELETE FROM $messageTable 
      WHERE id IN (
        SELECT m.id FROM $messageTable m
        JOIN $conversationTable c ON 
          ((m.senderId = c.user1Id AND m.receiverId = c.user2Id) OR 
           (m.senderId = c.user2Id AND m.receiverId = c.user1Id))
        WHERE c.id = ?
      )
    ''', [conversationId]);
    
    // Supprimer la conversation
    return await db.delete(
      conversationTable,
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  // Méthodes CRUD pour les paiements
  Future<int> insertPayment(Payment payment) async {
    Database db = await database;
    return await db.insert(
      paymentTable,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Payment?> getPaymentById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      paymentTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Payment>> getPaymentsByOrder(String orderId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      paymentTable,
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<List<Payment>> getPaymentsByUser(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      paymentTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Payment.fromMap(maps[i]));
  }

  Future<int> updatePayment(Payment payment) async {
    Database db = await database;
    return await db.update(
      paymentTable,
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(String id) async {
    Database db = await database;
    return await db.delete(
      paymentTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}


