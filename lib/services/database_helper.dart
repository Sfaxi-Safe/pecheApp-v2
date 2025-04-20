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
import '../models/marketplace_prise.dart';
import '../models/marketplace_message.dart';
import '../models/marketplace_salon.dart';
import '../models/marketplace_panier.dart';
import '../models/marketplace_categorie.dart';
import '../models/marketplace_image.dart';

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
  static const String salonTable = 'marketplace_salon';
  static const String panierTable = 'marketplace_panier';
  static const String categorieTable = 'marketplace_categorie';
  static const String imageTable = 'marketplace_image';
  static const String commentsTable = 'marketplace_comments';
  static const String contactTable = 'marketplace_contact';
  static const String entrepriseTable = 'marketplace_entreprise';
  static const String equipementTable = 'marketplace_equipement';
  static const String forumTable = 'marketplace_forum';
  static const String maryeurTable = 'marketplace_maryeur';
  static const String publicationTable = 'marketplace_publication';
  static const String rfidTable = 'marketplace_rfid';
  static const String veterinaireTable = 'marketplace_vitirinaire';

  // Singleton pattern
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Réinitialiser la base de données (utile pour le développement)
  Future<void> resetDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    // Fermer la base de données si elle est ouverte
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Supprimer le fichier de la base de données
    if (await File(path).exists()) {
      await File(path).delete();
    }

    // Réinitialiser la base de données
    _database = await _initDatabase();
  }

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
      version: 4,
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
    if (!existingIndexes.contains('idx_produit_pecheurId')) {
      await db.execute(
        'CREATE INDEX idx_produit_pecheurId ON $fishTable (pecheur_id)',
      );
    }

    if (!existingIndexes.contains('idx_avis_produitId')) {
      await db.execute(
        'CREATE INDEX idx_avis_produitId ON $reviewTable (produit_id)',
      );
    }

    if (!existingIndexes.contains('idx_commande_userId')) {
      await db.execute(
        'CREATE INDEX idx_commande_userId ON $orderTable (user_id)',
      );
    }

    if (!existingIndexes.contains('idx_commande_fournisseurId')) {
      await db.execute(
        'CREATE INDEX idx_commande_fournisseurId ON $orderTable (fournisseur_id)',
      );
    }

    if (!existingIndexes.contains('idx_message_expediteurId_destinataireId')) {
      await db.execute(
        'CREATE INDEX idx_message_expediteurId_destinataireId ON $messageTable (expediteur_id, destinataire_id)',
      );
    }

    if (!existingIndexes.contains('idx_panier_userId')) {
      await db.execute(
        'CREATE INDEX idx_panier_userId ON $panierTable (user_id)',
      );
    }

    if (!existingIndexes.contains('idx_image_produitId')) {
      await db.execute(
        'CREATE INDEX idx_image_produitId ON $imageTable (produit_id)',
      );
    }

    if (!existingIndexes.contains('idx_image_priseId')) {
      await db.execute(
        'CREATE INDEX idx_image_priseId ON $imageTable (prise_id)',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Création de la table users
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        roles TEXT NOT NULL,
        password TEXT NOT NULL,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        telephone INTEGER,
        is_verified INTEGER NOT NULL,
        is_blocked INTEGER NOT NULL,
        civilite TEXT,
        service TEXT,
        fonction TEXT,
        mobile TEXT,
        linkedin TEXT,
        facebook TEXT,
        tweeter TEXT,
        photo TEXT,
        is_valid INTEGER,
        adresse TEXT
      )
    ''');

    // Création de la table pecheur
    await db.execute('''
      CREATE TABLE $fishermanTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        adresse TEXT NOT NULL,
        telephone TEXT NOT NULL,
        email TEXT NOT NULL,
        bateau TEXT,
        licence TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table categorie
    await db.execute('''
      CREATE TABLE $categorieTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');

    // Création de la table produit
    await db.execute('''
      CREATE TABLE $fishTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT NOT NULL,
        prix REAL NOT NULL,
        stock INTEGER NOT NULL,
        categorie_id INTEGER,
        pecheur_id INTEGER,
        prise_id INTEGER,
        FOREIGN KEY (categorie_id) REFERENCES $categorieTable (id),
        FOREIGN KEY (pecheur_id) REFERENCES $fishermanTable (id),
        FOREIGN KEY (prise_id) REFERENCES $catchTable (id)
      )
    ''');

    // Création de la table image
    await db.execute('''
      CREATE TABLE $imageTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        alt TEXT,
        produit_id INTEGER,
        prise_id INTEGER,
        publication_id INTEGER,
        FOREIGN KEY (produit_id) REFERENCES $fishTable (id),
        FOREIGN KEY (prise_id) REFERENCES $catchTable (id),
        FOREIGN KEY (publication_id) REFERENCES $publicationTable (id)
      )
    ''');

    // Création de la table avis
    await db.execute('''
      CREATE TABLE $reviewTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produit_id INTEGER,
        user_id INTEGER,
        note INTEGER NOT NULL,
        commentaire TEXT NOT NULL,
        date_creation DATETIME NOT NULL,
        FOREIGN KEY (produit_id) REFERENCES $fishTable (id),
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table commandes
    await db.execute('''
      CREATE TABLE $orderTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        methode_de_paiement TEXT NOT NULL,
        commentaire TEXT,
        totale REAL NOT NULL,
        statut_commande TEXT NOT NULL,
        created_at DATETIME NOT NULL,
        date_modification DATETIME NOT NULL,
        reference TEXT NOT NULL UNIQUE,
        fournisseur_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES $userTable (id),
        FOREIGN KEY (fournisseur_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table produits vendus
    await db.execute('''
      CREATE TABLE $produitVendusTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commande_id INTEGER,
        produit_id INTEGER,
        quantite INTEGER NOT NULL,
        prix REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (commande_id) REFERENCES $orderTable (id),
        FOREIGN KEY (produit_id) REFERENCES $fishTable (id)
      )
    ''');

    // Création de la table lots
    await db.execute('''
      CREATE TABLE $lotTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rfid_id INTEGER,
        veterinaire_id INTEGER,
        identifiant TEXT,
        photo TEXT NOT NULL,
        quantite TEXT NOT NULL,
        poid TEXT,
        espece TEXT NOT NULL,
        temperature TEXT,
        prix_initial TEXT,
        prix_minimal TEXT,
        prix_finale TEXT,
        date_test TEXT,
        test INTEGER,
        status INTEGER,
        vendre INTEGER,
        prise_id INTEGER,
        user_id INTEGER,
        date_soumettre TEXT,
        poid_estimatif TEXT,
        type_enchere TEXT,
        current TEXT,
        online TEXT,
        is_produit INTEGER,
        FOREIGN KEY (rfid_id) REFERENCES $rfidTable (id),
        FOREIGN KEY (veterinaire_id) REFERENCES $veterinaireTable (id),
        FOREIGN KEY (prise_id) REFERENCES $catchTable (id),
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table prises
    await db.execute('''
      CREATE TABLE $catchTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        espece TEXT NOT NULL,
        poids REAL NOT NULL,
        date_peche DATETIME NOT NULL,
        lieu TEXT,
        description TEXT,
        pecheur_id INTEGER,
        FOREIGN KEY (pecheur_id) REFERENCES $fishermanTable (id)
      )
    ''');

    // Création de la table messages
    await db.execute('''
      CREATE TABLE $messageTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenu TEXT NOT NULL,
        date_envoi DATETIME NOT NULL,
        est_lu INTEGER NOT NULL,
        expediteur_id INTEGER,
        destinataire_id INTEGER,
        FOREIGN KEY (expediteur_id) REFERENCES $userTable (id),
        FOREIGN KEY (destinataire_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table salons
    await db.execute('''
      CREATE TABLE $salonTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT NOT NULL,
        date DATE NOT NULL,
        temps_debut TIME NOT NULL,
        temps_fin TIME NOT NULL,
        lieu TEXT NOT NULL,
        max_invitation INTEGER NOT NULL,
        affiche TEXT NOT NULL
      )
    ''');

    // Création de la table panier
    await db.execute('''
      CREATE TABLE $panierTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produit_id INTEGER,
        user_id INTEGER,
        quantite INTEGER NOT NULL,
        date_ajout DATETIME NOT NULL,
        FOREIGN KEY (produit_id) REFERENCES $fishTable (id),
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table comments
    await db.execute('''
      CREATE TABLE $commentsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenu TEXT NOT NULL,
        date_creation DATETIME NOT NULL,
        user_id INTEGER,
        publication_id INTEGER,
        forum_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES $userTable (id),
        FOREIGN KEY (publication_id) REFERENCES $publicationTable (id),
        FOREIGN KEY (forum_id) REFERENCES $forumTable (id)
      )
    ''');

    // Création de la table contact
    await db.execute('''
      CREATE TABLE $contactTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT NOT NULL,
        sujet TEXT NOT NULL,
        message TEXT NOT NULL,
        date_envoi DATETIME NOT NULL,
        est_lu INTEGER NOT NULL
      )
    ''');

    // Création de la table entreprise
    await db.execute('''
      CREATE TABLE $entrepriseTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        adresse TEXT NOT NULL,
        telephone TEXT NOT NULL,
        email TEXT NOT NULL,
        site_web TEXT,
        logo TEXT,
        description TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table equipement
    await db.execute('''
      CREATE TABLE $equipementTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT NOT NULL,
        image TEXT,
        pecheur_id INTEGER,
        FOREIGN KEY (pecheur_id) REFERENCES $fishermanTable (id)
      )
    ''');

    // Création de la table forum
    await db.execute('''
      CREATE TABLE $forumTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT NOT NULL,
        date_creation DATETIME NOT NULL,
        user_id INTEGER,
        image TEXT,
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table maryeur
    await db.execute('''
      CREATE TABLE $maryeurTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        adresse TEXT NOT NULL,
        telephone TEXT NOT NULL,
        email TEXT NOT NULL,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table publication
    await db.execute('''
      CREATE TABLE $publicationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        contenu TEXT NOT NULL,
        date_publication DATETIME NOT NULL,
        user_id INTEGER,
        image TEXT,
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');

    // Création de la table rfid
    await db.execute('''
      CREATE TABLE $rfidTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        description TEXT,
        prise_id INTEGER,
        produit_id INTEGER,
        FOREIGN KEY (prise_id) REFERENCES $catchTable (id),
        FOREIGN KEY (produit_id) REFERENCES $fishTable (id)
      )
    ''');

    // Création de la table veterinaire
    await db.execute('''
      CREATE TABLE $veterinaireTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        adresse TEXT NOT NULL,
        telephone TEXT NOT NULL,
        email TEXT NOT NULL,
        specialite TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES $userTable (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajout des tables de messagerie si elles n'existent pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $messageTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contenu TEXT NOT NULL,
          date_envoi DATETIME NOT NULL,
          est_lu INTEGER NOT NULL,
          expediteur_id INTEGER,
          destinataire_id INTEGER,
          FOREIGN KEY (expediteur_id) REFERENCES $userTable (id),
          FOREIGN KEY (destinataire_id) REFERENCES $userTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $salonTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titre TEXT NOT NULL,
          description TEXT NOT NULL,
          date DATE NOT NULL,
          temps_debut TIME NOT NULL,
          temps_fin TIME NOT NULL,
          lieu TEXT NOT NULL,
          max_invitation INTEGER NOT NULL,
          affiche TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // Ajout de la table panier si elle n'existe pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $panierTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          produit_id INTEGER,
          user_id INTEGER,
          quantite INTEGER NOT NULL,
          date_ajout DATETIME NOT NULL,
          FOREIGN KEY (produit_id) REFERENCES $fishTable (id),
          FOREIGN KEY (user_id) REFERENCES $userTable (id)
        )
      ''');
    }

    if (oldVersion < 4) {
      // Ajout des nouvelles tables
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $categorieTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          image_url TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $imageTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          url TEXT NOT NULL,
          alt TEXT,
          produit_id INTEGER,
          prise_id INTEGER,
          publication_id INTEGER,
          FOREIGN KEY (produit_id) REFERENCES $fishTable (id),
          FOREIGN KEY (prise_id) REFERENCES $catchTable (id),
          FOREIGN KEY (publication_id) REFERENCES $publicationTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $commentsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contenu TEXT NOT NULL,
          date_creation DATETIME NOT NULL,
          user_id INTEGER,
          publication_id INTEGER,
          forum_id INTEGER,
          FOREIGN KEY (user_id) REFERENCES $userTable (id),
          FOREIGN KEY (publication_id) REFERENCES $publicationTable (id),
          FOREIGN KEY (forum_id) REFERENCES $forumTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $contactTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          email TEXT NOT NULL,
          sujet TEXT NOT NULL,
          message TEXT NOT NULL,
          date_envoi DATETIME NOT NULL,
          est_lu INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $entrepriseTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          adresse TEXT NOT NULL,
          telephone TEXT NOT NULL,
          email TEXT NOT NULL,
          site_web TEXT,
          logo TEXT,
          description TEXT,
          user_id INTEGER,
          FOREIGN KEY (user_id) REFERENCES $userTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $equipementTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          description TEXT NOT NULL,
          image TEXT,
          pecheur_id INTEGER,
          FOREIGN KEY (pecheur_id) REFERENCES $fishermanTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $forumTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titre TEXT NOT NULL,
          description TEXT NOT NULL,
          date_creation DATETIME NOT NULL,
          user_id INTEGER,
          image TEXT,
          FOREIGN KEY (user_id) REFERENCES $userTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $maryeurTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          prenom TEXT NOT NULL,
          adresse TEXT NOT NULL,
          telephone TEXT NOT NULL,
          email TEXT NOT NULL,
          user_id INTEGER,
          FOREIGN KEY (user_id) REFERENCES $userTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $publicationTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titre TEXT NOT NULL,
          contenu TEXT NOT NULL,
          date_publication DATETIME NOT NULL,
          user_id INTEGER,
          image TEXT,
          FOREIGN KEY (user_id) REFERENCES $userTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $rfidTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          code TEXT NOT NULL,
          description TEXT,
          prise_id INTEGER,
          produit_id INTEGER,
          FOREIGN KEY (prise_id) REFERENCES $catchTable (id),
          FOREIGN KEY (produit_id) REFERENCES $fishTable (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS $veterinaireTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          prenom TEXT NOT NULL,
          adresse TEXT NOT NULL,
          telephone TEXT NOT NULL,
          email TEXT NOT NULL,
          specialite TEXT,
          user_id INTEGER,
          FOREIGN KEY (user_id) REFERENCES $userTable (id)
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

  Future<MarketplacePecheur?> getFishermanByUserId(int userId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishermanTable,
      where: 'user_id = ?',
      whereArgs: [userId],
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

  // Méthodes CRUD pour les catégories
  Future<int> insertCategorie(MarketplaceCategorie categorie) async {
    Database db = await database;
    return await db.insert(
      categorieTable,
      categorie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceCategorie?> getCategorieById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      categorieTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceCategorie.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceCategorie>> getAllCategories() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(categorieTable);
    return List.generate(
      maps.length,
      (i) => MarketplaceCategorie.fromMap(maps[i]),
    );
  }

  Future<int> updateCategorie(MarketplaceCategorie categorie) async {
    Database db = await database;
    return await db.update(
      categorieTable,
      categorie.toMap(),
      where: 'id = ?',
      whereArgs: [categorie.id],
    );
  }

  Future<int> deleteCategorie(int id) async {
    Database db = await database;
    return await db.delete(categorieTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les images
  Future<int> insertImage(MarketplaceImage image) async {
    Database db = await database;
    return await db.insert(
      imageTable,
      image.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceImage?> getImageById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      imageTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceImage.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceImage>> getImagesByProduitId(int produitId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      imageTable,
      where: 'produit_id = ?',
      whereArgs: [produitId],
    );
    return List.generate(
      maps.length,
      (i) => MarketplaceImage.fromMap(maps[i]),
    );
  }

  Future<List<MarketplaceImage>> getImagesByPriseId(int priseId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      imageTable,
      where: 'prise_id = ?',
      whereArgs: [priseId],
    );
    return List.generate(
      maps.length,
      (i) => MarketplaceImage.fromMap(maps[i]),
    );
  }

  Future<int> updateImage(MarketplaceImage image) async {
    Database db = await database;
    return await db.update(
      imageTable,
      image.toMap(),
      where: 'id = ?',
      whereArgs: [image.id],
    );
  }

  Future<int> deleteImage(int id) async {
    Database db = await database;
    return await db.delete(imageTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteImagesByProduitId(int produitId) async {
    Database db = await database;
    return await db.delete(
      imageTable,
      where: 'produit_id = ?',
      whereArgs: [produitId],
    );
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

    if (maps.isEmpty) {
      return null;
    }

    // Récupérer les images associées
    final produit = MarketplaceProduit.fromMap(maps.first);
    if (produit.id != null) {
      final images = await getImagesByProduitId(produit.id!);
      
      // Récupérer la catégorie si elle existe
      MarketplaceCategorie? categorie;
      if (produit.categorieId != null) {
        categorie = await getCategorieById(produit.categorieId!);
      }
      
      return produit.copyWith(images: images, categorie: categorie);
    }
    
    return produit;
  }

  Future<List<MarketplaceProduit>> getAllProduits() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(fishTable);
    
    List<MarketplaceProduit> produits = [];
    for (var map in maps) {
      final produit = MarketplaceProduit.fromMap(map);
      if (produit.id != null) {
        final images = await getImagesByProduitId(produit.id!);
        
        // Récupérer la catégorie si elle existe
        MarketplaceCategorie? categorie;
        if (produit.categorieId != null) {
          categorie = await getCategorieById(produit.categorieId!);
        }
        
        produits.add(produit.copyWith(images: images, categorie: categorie));
      } else {
        produits.add(produit);
      }
    }
    
    return produits;
  }

  Future<List<MarketplaceProduit>> getProduitsByPecheur(int pecheurId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'pecheur_id = ?',
      whereArgs: [pecheurId],
    );
    
    List<MarketplaceProduit> produits = [];
    for (var map in maps) {
      final produit = MarketplaceProduit.fromMap(map);
      if (produit.id != null) {
        final images = await getImagesByProduitId(produit.id!);
        
        // Récupérer la catégorie si elle existe
        MarketplaceCategorie? categorie;
        if (produit.categorieId != null) {
          categorie = await getCategorieById(produit.categorieId!);
        }
        
        produits.add(produit.copyWith(images: images, categorie: categorie));
      } else {
        produits.add(produit);
      }
    }
    
    return produits;
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

    // Récupérer l'ID de la commande
    final result = await batch.commit();
    final commandeId = result[0] as int;

    // Insérer les produits vendus
    for (var produit in produits) {
      await db.insert(
        produitVendusTable,
        produit.copyWith(commandeId: commandeId).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return commandeId;
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

  // Méthodes CRUD pour les prises
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

    if (maps.isEmpty) {
      return null;
    }

    // Récupérer les images associées
    final prise = MarketplacePrise.fromMap(maps.first);
    if (prise.id != null) {
      final images = await getImagesByPriseId(prise.id!);
      return prise.copyWith(images: images);
    }
    
    return prise;
  }

  Future<List<MarketplacePrise>> getPrisesByPecheur(int pecheurId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      catchTable,
      where: 'pecheur_id = ?',
      whereArgs: [pecheurId],
    );
    
    List<MarketplacePrise> prises = [];
    for (var map in maps) {
      final prise = MarketplacePrise.fromMap(map);
      if (prise.id != null) {
        final images = await getImagesByPriseId(prise.id!);
        prises.add(prise.copyWith(images: images));
      } else {
        prises.add(prise);
      }
    }
    
    return prises;
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
    int expediteurId,
    int destinataireId,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT * FROM $messageTable
      WHERE (expediteur_id = ? AND destinataire_id = ?) OR (expediteur_id = ? AND destinataire_id = ?)
      ORDER BY date_envoi ASC
    ''',
      [expediteurId, destinataireId, destinataireId, expediteurId],
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
      {'est_lu': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<int> markAllMessagesAsRead(int destinataireId, int expediteurId) async {
    Database db = await database;
    return await db.update(
      messageTable,
      {'est_lu': 1},
      where: 'destinataire_id = ? AND expediteur_id = ? AND est_lu = 0',
      whereArgs: [destinataireId, expediteurId],
    );
  }

  Future<int> deleteMessage(int id) async {
    Database db = await database;
    return await db.delete(messageTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les salons
  Future<int> insertSalon(MarketplaceSalon salon) async {
    Database db = await database;
    return await db.insert(
      salonTable,
      salon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplaceSalon?> getSalonById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      salonTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MarketplaceSalon.fromMap(maps.first);
    }
    return null;
  }

  Future<List<MarketplaceSalon>> getAllSalons() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(salonTable);
    return List.generate(maps.length, (i) => MarketplaceSalon.fromMap(maps[i]));
  }

  Future<int> updateSalon(MarketplaceSalon salon) async {
    Database db = await database;
    return await db.update(
      salonTable,
      salon.toMap(),
      where: 'id = ?',
      whereArgs: [salon.id],
    );
  }

  Future<int> deleteSalon(int id) async {
    Database db = await database;
    return await db.delete(salonTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes CRUD pour les paniers
  Future<int> insertPanier(MarketplacePanier panier) async {
    Database db = await database;
    return await db.insert(
      panierTable,
      panier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MarketplacePanier?> getPanierById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      panierTable,
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
      panierTable,
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
      panierTable,
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
      panierTable,
      panier.toMap(),
      where: 'id = ?',
      whereArgs: [panier.id],
    );
  }

  Future<int> deletePanier(int id) async {
    Database db = await database;
    return await db.delete(panierTable, where: 'id = ?', whereArgs: [id]);
  }

  // Méthode pour récupérer tous les messages
  Future<List<MarketplaceMessage>> getAllMessages() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(messageTable);
    return List.generate(
      maps.length,
      (i) => MarketplaceMessage.fromMap(maps[i]),
    );
  }
}
