import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/marketplace_aommande.dart';
import '../models/marketplace_produitvendus.dart';
import '../models/marketplace_user.dart';
import '../models/marketplace_pecheur.dart';
import '../models/marketplace_produit.dart';
import '../models/marketplace_avis.dart';
import '../models/marketplace_lots.dart';
import '../models/marketplace_prise.dart';
import '../models/marketplace_message.dart';
import '../models/marketplace_salon.dart';
import '../models/marketplace_panier.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Nom de la base de données
  static const String dbName = 'peche_app.db';

  // Noms des tables
  static const String userTable = 'marketplace_user';
  static const String fishermanTable = 'marketplace_pecheur';
  static const String fishTable = 'marketplace_produit';
  static const String reviewTable = 'marketplace_avis';
  static const String orderTable = 'marketplace_aommande';
  static const String produitVendusTable = 'marketplace_produitvendus';
  static const String lotTable = 'marketplace_lots';
  static const String catchTable = 'marketplace_prise';
  static const String messageTable = 'marketplace_message';
  static const String conversationTable = 'marketplace_salon';
  static const String paymentTable = 'marketplace_panier';

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
    final indexesResult = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );
    final existingIndexes =
        indexesResult.map((e) => e['name'] as String).toList();

    // Créer des index pour les colonnes fréquemment utilisées dans les requêtes
    if (!existingIndexes.contains('idx_fish_fishermanId')) {
      await db.execute(
        'CREATE INDEX idx_fish_fishermanId ON $fishTable (fishermanId)',
      );
    }

    if (!existingIndexes.contains('idx_review_fishId')) {
      await db.execute(
        'CREATE INDEX idx_review_fishId ON $reviewTable (fishId)',
      );
    }

    if (!existingIndexes.contains('idx_order_clientId')) {
      await db.execute(
        'CREATE INDEX idx_order_clientId ON $orderTable (clientId)',
      );
    }

    if (!existingIndexes.contains('idx_order_fishermanId')) {
      await db.execute(
        'CREATE INDEX idx_order_fishermanId ON $orderTable (fishermanId)',
      );
    }

    if (!existingIndexes.contains('idx_message_senderId_receiverId')) {
      await db.execute(
        'CREATE INDEX idx_message_senderId_receiverId ON $messageTable (senderId, receiverId)',
      );
    }

    if (!existingIndexes.contains('idx_conversation_user1Id_user2Id')) {
      await db.execute(
        'CREATE INDEX idx_conversation_user1Id_user2Id ON $conversationTable (user1Id, user2Id)',
      );
    }

    if (!existingIndexes.contains('idx_payment_orderId')) {
      await db.execute(
        'CREATE INDEX idx_payment_orderId ON $paymentTable (orderId)',
      );
    }

    if (!existingIndexes.contains('idx_payment_userId')) {
      await db.execute(
        'CREATE INDEX idx_payment_userId ON $paymentTable (userId)',
      );
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
  Future<void> batchInsert<T>(
    String table,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(table, item, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  // Optimisation: Pagination pour les requêtes de grande taille (ancienne méthode, remplacée par celle ci-dessous)
  // Cette méthode est conservée pour référence mais n'est plus utilisée
  /*
  Future<List<MarketplaceProduit>> getFishesPaginatedOld(int page, int pageSize) async {
    final db = await database;
    final offset = page * pageSize;

    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      limit: pageSize,
      offset: offset,
      orderBy: 'date_de_peche DESC',
    );

    return List.generate(maps.length, (i) => MarketplaceProduit.fromMap(maps[i]));
  }
  */

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
  Future<List<Map<String, dynamic>>> getOrdersWithDetails(
    String userId,
    String userType,
  ) async {
    final db = await database;
    final whereClause =
        userType == 'client' ? 'o.clientId = ?' : 'o.fishermanId = ?';

    return await db.rawQuery(
      '''
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
    ''',
      [userType, userId],
    );
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
  Future<Map<String, int>> getOrderCountsByStatus(
    String userId,
    String userType,
  ) async {
    final db = await database;
    final whereClause =
        userType == 'client' ? 'user_id = ?' : 'fournisseur_id = ?';

    final result = await db.rawQuery(
      'SELECT statut_commande, COUNT(*) as count FROM $orderTable WHERE $whereClause GROUP BY statut_commande',
      [int.tryParse(userId)],
    );

    final Map<String, int> counts = {
      'pending': 0,
      'confirmed': 0,
      'in_progress': 0,
      'delivered': 0,
      'cancelled': 0,
    };

    for (var row in result) {
      final status = row['statut_commande'] as String? ?? 'pending';
      counts[status] = row['count'] as int;
    }

    return counts;
  }

  // Optimisation: Requête pour obtenir les statistiques de vente par mois
  Future<List<Map<String, dynamic>>> getMonthlySalesStats(
    String fishermanId,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT
        strftime('%Y-%m', created_at) as month,
        COUNT(*) as orderCount,
        SUM(totale) as totalSales
      FROM $orderTable
      WHERE fournisseur_id = ? AND statut_commande != ?
      GROUP BY month
      ORDER BY month DESC
      LIMIT 12
    ''',
      [int.tryParse(fishermanId), 'cancelled'],
    );
  }

  // Optimisation: Requête pour obtenir les espèces les plus vendues
  Future<List<Map<String, dynamic>>> getTopSellingSpecies(
    String fishermanId,
  ) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT
        p.nom as species,
        COUNT(pv.id) as orderCount,
        SUM(pv.quantite) as totalQuantity
      FROM $produitVendusTable pv
      JOIN $orderTable o ON pv.commande_id = o.id
      JOIN $fishTable p ON pv.produit_id = p.id
      WHERE o.fournisseur_id = ? AND o.statut_commande != ?
      GROUP BY p.nom
      ORDER BY orderCount DESC
      LIMIT 5
    ''',
      [int.tryParse(fishermanId), 'cancelled'],
    );
  }

  // Méthodes CRUD pour les utilisateurs
  Future<int> insertUser(MarketplaceUser user) async {
    Database db = await database;
    return await db.insert(
      userTable,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceUser?> getUserById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceUser.fromMap(maps.first);
    }
    return null;
  }

  Future<MarketplaceUser?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      userTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return MarketplaceUser.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceUser>> getAllUsers() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(userTable);
    return List.generate(maps.length, (i) => MarketplaceUser.fromMap(maps[i]));
  }

  Future<int> updateUser(MarketplaceUser user) async {
    Database db = await database;
    return await db.update(
      userTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database db = await database;
    return await db.delete(userTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les pêcheurs
  Future<int> insertFisherman(MarketplacePecheur fisherman) async {
    Database db = await database;
    return await db.insert(
      fishermanTable,
      fisherman.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplacePecheur?> getFishermanById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishermanTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplacePecheur.fromMap(maps.first);
    }
    return null;
  }

  Future<MarketplacePecheur?> getFishermanByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishermanTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return MarketplacePecheur.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplacePecheur>> getAllFishermen() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(fishermanTable);
    return List.generate(
      maps.length,
      (i) => MarketplacePecheur.fromMap(maps[i]),
    );
  }

  Future<int> updateFisherman(MarketplacePecheur fisherman) async {
    Database db = await database;
    return await db.update(
      fishermanTable,
      fisherman.toMap(),
      where: 'id = ?',
      whereArgs: [fisherman.id],
    );
  }

  Future<int> deleteFisherman(int id) async {
    Database db = await database;
    return await db.delete(fishermanTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les produits (poissons)
  Future<int> insertProduit(MarketplaceProduit produit) async {
    Database db = await database;
    return await db.insert(
      fishTable,
      produit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceProduit?> getProduitById(dynamic id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceProduit.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceProduit>> getAllProduits() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(fishTable);
    return List.generate(
      maps.length,
      (i) => MarketplaceProduit.fromMap(maps[i]),
    );
  }

  Future<List<MarketplaceProduit>> getProduitsByUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(
      maps.length,
      (i) => MarketplaceProduit.fromMap(maps[i]),
    );
  }

  Future<int> updateProduit(MarketplaceProduit produit) async {
    Database db = await database;
    return await db.update(
      fishTable,
      produit.toMap(),
      where: 'id = ?',
      whereArgs: [produit.id],
    );
  }

  Future<int> deleteProduit(int id) async {
    Database db = await database;
    return await db.delete(fishTable, where: 'id = ?', whereArgs: [id]);
  }

  // Pour la compatibilité avec l'ancien code
  Future<List<MarketplaceProduit>> getFishesPaginated(
    int page,
    int pageSize,
  ) async {
    return getProduitsPaginated(page, pageSize);
  }

  // Méthode pour récupérer les produits avec pagination
  Future<List<MarketplaceProduit>> getProduitsPaginated(
    int page,
    int pageSize,
  ) async {
    final db = await database;
    final offset = page * pageSize;

    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      limit: pageSize,
      offset: offset,
      orderBy: 'id DESC',
    );

    return List.generate(
      maps.length,
      (i) => MarketplaceProduit.fromMap(maps[i]),
    );
  }

  // Méthodes CRUD pour les avis
  Future<int> insertAvis(MarketplaceAvis avis) async {
    Database db = await database;
    return await db.insert(
      reviewTable,
      avis.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceAvis?> getAvisById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      reviewTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceAvis.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceAvis>> getAvisByProduit(int produitId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      reviewTable,
      where: 'produit_id = ?',
      whereArgs: [produitId],
    );
    return List.generate(maps.length, (i) => MarketplaceAvis.fromMap(maps[i]));
  }

  Future<List<MarketplaceAvis>> getAvisByUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      reviewTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => MarketplaceAvis.fromMap(maps[i]));
  }

  // Récupérer tous les avis
  Future<List<MarketplaceAvis>> getAllAvis() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(reviewTable);
    return List.generate(maps.length, (i) => MarketplaceAvis.fromMap(maps[i]));
  }

  Future<int> updateAvis(MarketplaceAvis avis) async {
    Database db = await database;
    return await db.update(
      reviewTable,
      avis.toMap(),
      where: 'id = ?',
      whereArgs: [avis.id],
    );
  }

  Future<int> deleteAvis(int id) async {
    Database db = await database;
    return await db.delete(reviewTable, where: 'id = ?', whereArgs: [id]);
  }

  // Pour la compatibilité avec l'ancien code
  Future<List<MarketplaceAvis>> getReviewsByFish(int fishId) async {
    return getAvisByProduit(fishId);
  }

  // Méthodes CRUD pour les commandes
  Future<int> insertCommande(
    MarketplaceAommande commande,
    List<MarketplaceProduitVendus> produits,
  ) async {
    Database db = await database;
    final batch = db.batch();

    // Insérer la commande
    batch.insert(
      orderTable,
      commande.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insérer les produits vendus
    for (var produit in produits) {
      batch.insert(
        produitVendusTable,
        produit.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    return 1; // Succès
  }

  Future<MarketplaceAommande?> getOrderById(dynamic id) async {
    Database db = await database;

    // Récupérer la commande
    List<Map<String, dynamic>> orderMaps = await db.query(
      orderTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (orderMaps.isEmpty) {
      return null;
    }

    return MarketplaceAommande.fromMap(orderMaps.first);
  }

  // Récupérer les produits vendus associés à une commande
  Future<List<MarketplaceProduitVendus>> getProduitVendusByCommandeId(
    int commandeId,
  ) async {
    Database db = await database;

    List<Map<String, dynamic>> produitsMaps = await db.query(
      produitVendusTable,
      where: 'commande_id = ?',
      whereArgs: [commandeId],
    );

    return produitsMaps
        .map((map) => MarketplaceProduitVendus.fromMap(map))
        .toList();
  }

  Future<List<MarketplaceAommande>> getAllOrders() async {
    Database db = await database;
    List<Map<String, dynamic>> orderMaps = await db.query(orderTable);

    return orderMaps.map((map) => MarketplaceAommande.fromMap(map)).toList();
  }

  Future<List<MarketplaceAommande>> getOrdersByClient(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> orderMaps = await db.query(
      orderTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return orderMaps.map((map) => MarketplaceAommande.fromMap(map)).toList();
  }

  Future<List<MarketplaceAommande>> getOrdersByFisherman(
    int fournisseurId,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> orderMaps = await db.query(
      orderTable,
      where: 'fournisseur_id = ?',
      whereArgs: [fournisseurId],
    );

    return orderMaps.map((map) => MarketplaceAommande.fromMap(map)).toList();
  }

  Future<int> updateCommande(MarketplaceAommande commande) async {
    Database db = await database;
    return await db.update(
      orderTable,
      commande.toMap(),
      where: 'id = ?',
      whereArgs: [commande.id],
    );
  }

  // Mettre à jour le statut d'une commande
  Future<int> updateOrderStatus(dynamic orderId, String newStatus) async {
    Database db = await database;
    return await db.update(
      orderTable,
      {
        'statut_commande': newStatus,
        'date_modification': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Mettre à jour une commande avec ses produits vendus
  Future<int> updateCommandeWithProduits(
    MarketplaceAommande commande,
    List<MarketplaceProduitVendus> produits,
  ) async {
    Database db = await database;
    final batch = db.batch();

    // Mettre à jour la commande
    batch.update(
      orderTable,
      commande.toMap(),
      where: 'id = ?',
      whereArgs: [commande.id],
    );

    // Supprimer les anciens produits vendus
    batch.delete(
      produitVendusTable,
      where: 'commande_id = ?',
      whereArgs: [commande.id],
    );

    // Insérer les nouveaux produits vendus
    for (var produit in produits) {
      batch.insert(
        produitVendusTable,
        produit.copyWith(commandeId: commande.id).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    return 1; // Succès
  }

  Future<int> deleteCommande(int id) async {
    Database db = await database;
    final batch = db.batch();

    // Supprimer les produits vendus associés à cette commande
    batch.delete(produitVendusTable, where: 'commande_id = ?', whereArgs: [id]);

    // Supprimer la commande
    batch.delete(orderTable, where: 'id = ?', whereArgs: [id]);

    await batch.commit(noResult: true);
    return 1; // Succès
  }

  // Méthodes CRUD pour les produits vendus
  Future<int> insertProduitVendu(MarketplaceProduitVendus produit) async {
    Database db = await database;
    return await db.insert(
      produitVendusTable,
      produit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceProduitVendus?> getProduitVenduById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      produitVendusTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceProduitVendus.fromMap(maps.first);
    }
    return null;
  }

  // Cette méthode a été déplacée plus haut dans le fichier

  Future<int> updateProduitVendu(MarketplaceProduitVendus produit) async {
    Database db = await database;
    return await db.update(
      produitVendusTable,
      produit.toMap(),
      where: 'id = ?',
      whereArgs: [produit.id],
    );
  }

  Future<int> deleteProduitVendu(int id) async {
    Database db = await database;
    return await db.delete(
      produitVendusTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes CRUD pour les lots
  Future<int> insertLot(MarketplaceLots lot) async {
    Database db = await database;
    return await db.insert(
      lotTable,
      lot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceLots?> getLotById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      lotTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceLots.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceLots>> getAllLots() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(lotTable);
    return List.generate(maps.length, (i) => MarketplaceLots.fromMap(maps[i]));
  }

  Future<int> updateLot(MarketplaceLots lot) async {
    Database db = await database;
    return await db.update(
      lotTable,
      lot.toMap(),
      where: 'id = ?',
      whereArgs: [lot.id],
    );
  }

  Future<int> deleteLot(int id) async {
    Database db = await database;
    return await db.delete(lotTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les captures (prises)
  Future<int> insertPrise(MarketplacePrise prise) async {
    Database db = await database;
    return await db.insert(
      catchTable,
      prise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplacePrise?> getPriseById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      catchTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplacePrise.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplacePrise>> getPrisesByPecheur(int pecheurId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      catchTable,
      where: 'pecheur_id = ?',
      whereArgs: [pecheurId],
    );
    return List.generate(maps.length, (i) => MarketplacePrise.fromMap(maps[i]));
  }

  Future<int> updatePrise(MarketplacePrise prise) async {
    Database db = await database;
    return await db.update(
      catchTable,
      prise.toMap(),
      where: 'id = ?',
      whereArgs: [prise.id],
    );
  }

  Future<int> deletePrise(int id) async {
    Database db = await database;
    return await db.delete(catchTable, where: 'id = ?', whereArgs: [id]);
  }

  // Pour la compatibilité avec l'ancien code
  Future<List<MarketplacePrise>> getCatchesByFisherman(int fishermanId) async {
    return getPrisesByPecheur(fishermanId);
  }

  // Méthodes CRUD pour les messages
  Future<int> insertMessage(MarketplaceMessage message) async {
    Database db = await database;
    return await db.insert(
      messageTable,
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceMessage?> getMessageById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      messageTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceMessage.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceMessage>> getMessagesBetweenUsers(
    int userId1,
    int userId2,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM $messageTable
      WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
      ORDER BY timestamp ASC
    ''',
      [userId1, userId2, userId2, userId1],
    );

    return List.generate(
      maps.length,
      (i) => MarketplaceMessage.fromMap(maps[i]),
    );
  }

  Future<int> markMessageAsRead(int messageId) async {
    Database db = await database;
    return await db.update(
      messageTable,
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<int> markAllMessagesAsRead(int receiverId, int senderId) async {
    Database db = await database;
    return await db.update(
      messageTable,
      {'is_read': 1},
      where: 'receiver_id = ? AND sender_id = ? AND is_read = 0',
      whereArgs: [receiverId, senderId],
    );
  }

  Future<int> deleteMessage(int id) async {
    Database db = await database;
    return await db.delete(messageTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les conversations (salons)
  Future<int> getOrCreateSalon(int user1Id, int user2Id) async {
    Database db = await database;

    // Vérifier si un salon existe déjà entre ces deux utilisateurs
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM $conversationTable
      WHERE (user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)
    ''',
      [user1Id, user2Id, user2Id, user1Id],
    );

    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    }

    // Créer un nouveau salon
    final Map<String, dynamic> salonData = {
      'titre': 'Conversation',
      'description': 'Conversation entre utilisateurs',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'temps_debut': '${DateTime.now().hour}:${DateTime.now().minute}:00',
      'temps_fin': '23:59:59',
      'lieu': 'En ligne',
      'max_invitation': 2,
      'affiche': '',
    };

    return await db.insert(conversationTable, salonData);
  }

  Future<List<MarketplaceSalon>> getSalonsForUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(conversationTable);
    return List.generate(maps.length, (i) => MarketplaceSalon.fromMap(maps[i]));
  }

  // Pour la compatibilité avec l'ancien code
  Future<List<Map<String, dynamic>>> getConversationsForUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> salons = await db.query(conversationTable);

    // Convertir les salons en format compatible avec l'ancien code
    List<Map<String, dynamic>> conversations = [];
    for (var salon in salons) {
      conversations.add({
        'id': salon['id'],
        'titre': salon['titre'],
        'description': salon['description'],
        'date': salon['date'],
        'temps_debut': salon['temps_debut'],
        'temps_fin': salon['temps_fin'],
        'lieu': salon['lieu'],
        'max_invitation': salon['max_invitation'],
        'affiche': salon['affiche'],
      });
    }

    return conversations;
  }

  Future<int> updateSalon(int salonId, String titre, String description) async {
    Database db = await database;
    return await db.update(
      conversationTable,
      {'titre': titre, 'description': description},
      where: 'id = ?',
      whereArgs: [salonId],
    );
  }

  // Pour la compatibilité avec l'ancien code
  Future<int> updateConversationLastMessage(
    int conversationId,
    String content,
    DateTime timestamp,
    bool hasUnread,
  ) async {
    return await updateSalon(conversationId, 'Conversation', content);
  }

  Future<int> markConversationAsRead(int conversationId) async {
    // Cette fonction n'a plus d'effet direct, mais est conservée pour la compatibilité
    return 1;
  }

  Future<int> deleteSalon(int salonId) async {
    Database db = await database;

    // Supprimer tous les messages associés au salon
    await db.delete(messageTable, where: 'salon_id = ?', whereArgs: [salonId]);

    // Supprimer le salon
    return await db.delete(
      conversationTable,
      where: 'id = ?',
      whereArgs: [salonId],
    );
  }

  // Pour la compatibilité avec l'ancien code
  Future<int> deleteConversation(int conversationId) async {
    return await deleteSalon(conversationId);
  }

  // Méthodes CRUD pour les paiements (paniers)
  Future<int> insertPanier(MarketplacePanier panier) async {
    Database db = await database;
    return await db.insert(
      paymentTable,
      panier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplacePanier?> getPanierById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      paymentTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplacePanier.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplacePanier>> getPaniersByProduit(int produitId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      paymentTable,
      where: 'produit_id = ?',
      whereArgs: [produitId],
    );
    return List.generate(
      maps.length,
      (i) => MarketplacePanier.fromMap(maps[i]),
    );
  }

  Future<List<MarketplacePanier>> getPaniersByUser(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      paymentTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(
      maps.length,
      (i) => MarketplacePanier.fromMap(maps[i]),
    );
  }

  Future<int> updatePanier(MarketplacePanier panier) async {
    Database db = await database;
    return await db.update(
      paymentTable,
      panier.toMap(),
      where: 'id = ?',
      whereArgs: [panier.id],
    );
  }

  Future<int> deletePanier(int id) async {
    Database db = await database;
    return await db.delete(paymentTable, where: 'id = ?', whereArgs: [id]);
  }
}
