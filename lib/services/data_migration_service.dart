import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peche_app/models/user.dart';
import 'package:peche_app/models/fish.dart';
import 'package:peche_app/models/order.dart';
import 'package:peche_app/models/review.dart';
import 'package:peche_app/models/fisherman.dart';
import 'package:peche_app/models/catch.dart';
import 'package:peche_app/models/lot.dart';
import 'package:peche_app/utils/sql_parser.dart';
import 'package:uuid/uuid.dart';
//fedeeeeeeeeeeeeeeeeeeeet

class DataMigrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Migrer les utilisateurs
  Future<void> migrateUsers(List<Map<String, dynamic>> sqlUsers) async {
    final batch = _db.batch();
    final usersRef = _db.collection('users');

    for (final userData in sqlUsers) {
      final userId = userData['id']?.toString() ?? const Uuid().v4();

      final user = User(
        id: userId,
        email: userData['email'] ?? '',
        password: '', // Ne pas migrer les mots de passe
        name: '${userData['prenom']} ${userData['nom']}',
        phoneNumber: userData['telephone']?.toString() ?? '',
        userType: 'client',
        profileImageUrl: userData['photo'],
        createdAt: DateTime.now(),
      );

      batch.set(usersRef.doc(userId), user.toMap());
    }

    await batch.commit();
  }

  // Migrer les pêcheurs
  Future<void> migrateFishermen(List<Map<String, dynamic>> sqlFishermen) async {
    final batch = _db.batch();
    final fishermanRef = _db.collection('fishermen');

    for (final fishermanData in sqlFishermen) {
      final fishermanId = fishermanData['id']?.toString() ?? const Uuid().v4();

      final fisherman = Fisherman(
        id: fishermanId,
        email: fishermanData['email'] ?? '',
        nom: fishermanData['nom'] ?? '',
        prenom: fishermanData['prenom'] ?? '',
        cin: fishermanData['cin'],
        matricule: fishermanData['matricule'],
        capacite: fishermanData['capacite'],
        longeur: fishermanData['longeur'],
        largeur: fishermanData['largeur'],
        bateau: fishermanData['bateau'],
        pays: fishermanData['pays'],
        proprietaire: fishermanData['proprietaire'],
        serie: fishermanData['serie'],
        certification: fishermanData['certification'],
        port: fishermanData['port'],
        engin: fishermanData['engin'],
        telephone: fishermanData['telephone']?.toString(),
        isValid: fishermanData['is_valid'] == 1,
      );

      batch.set(fishermanRef.doc(fishermanId), fisherman.toMap());
    }

    await batch.commit();
  }

  // Migrer les prises
  Future<void> migrateCatches(List<Map<String, dynamic>> sqlCatches) async {
    final batch = _db.batch();
    final catchesRef = _db.collection('catches');

    for (final catchData in sqlCatches) {
      final catchId = catchData['id']?.toString() ?? const Uuid().v4();

      final catch_ = Catch(
        id: catchId,
        fishermanId: catchData['pecheur_id']?.toString() ?? '',
        maryeurId: catchData['maryeur_id']?.toString(),
        nom: catchData['nom'] ?? '',
        debut: catchData['debut'] ?? '',
        fin: catchData['fin'],
        latitude: catchData['latitude'] ?? '',
        longitude: catchData['langitude'] ?? '',
        engin: catchData['engin'] ?? '',
        zone: catchData['zone'],
        affectationDate: catchData['affectationdate'],
        dateDebarquement: catchData['datedebarquement'],
      );

      batch.set(catchesRef.doc(catchId), catch_.toMap());
    }

    await batch.commit();
  }

  // Migrer les lots
  Future<void> migrateLots(List<Map<String, dynamic>> sqlLots) async {
    final batch = _db.batch();
    final lotsRef = _db.collection('lots');

    for (final lotData in sqlLots) {
      final lotId = lotData['id']?.toString() ?? const Uuid().v4();

      final lot = Lot(
        id: lotId,
        rfidId: lotData['rfid_id']?.toString(),
        veterinaireId: lotData['vitirinaire_id']?.toString(),
        identifiant: lotData['identifiant'],
        photo: lotData['photo'] ?? '',
        quantite: lotData['quantite'] ?? '',
        poid: lotData['poid'],
        espece: lotData['espece'] ?? '',
        temperature: lotData['temperature'],
        prixInitial: lotData['prixinitial'],
        prixMinimal: lotData['prixminimal'],
        prixFinale: lotData['prixfinale'],
        dateTest: lotData['datetest'],
        test: lotData['test'] == 1,
        status: lotData['status'] == 1,
        vendre: lotData['vendre'] == 1,
        priseId: lotData['prise_id']?.toString(),
        userId: lotData['user_id']?.toString(),
        dateSoumettre: lotData['datesoumettre'],
        poidEstimatif: lotData['poidestimatif'],
        typeEnchere: lotData['typeenchere'],
        current: lotData['current'],
        online: lotData['online'],
        isProduit: lotData['is_produit'] == 1,
      );

      batch.set(lotsRef.doc(lotId), lot.toMap());
    }

    await batch.commit();
  }

  // Migrer les produits
  Future<void> migrateProducts(List<Map<String, dynamic>> sqlProducts) async {
    final batch = _db.batch();
    final productsRef = _db.collection('fish');

    for (final productData in sqlProducts) {
      final productId = productData['id']?.toString() ?? const Uuid().v4();

      final fish = Fish(
        id: productId,
        species: productData['nom'] ?? '',
        imageUrl: _getProductImageUrl(productData),
        weight: double.tryParse(productData['stock']?.toString() ?? '0') ?? 0.0,
        length: 0.0, // Information non disponible dans la table produit
        location: productData['zonedepeche'] ?? '',
        fishingMethod: productData['methodedecapture'] ?? '',
        captureDate: _parseDate(productData['datedepeche']),
        fishermanId: productData['user_id']?.toString() ?? '',
      );

      batch.set(productsRef.doc(productId), fish.toMap());
    }

    await batch.commit();
  }

  // Migrer les commandes
  Future<void> migrateOrders(List<Map<String, dynamic>> sqlOrders) async {
    final batch = _db.batch();
    final ordersRef = _db.collection('orders');

    for (final orderData in sqlOrders) {
      final orderId = orderData['id']?.toString() ?? const Uuid().v4();

      final order = Order(
        id: orderId,
        clientId: orderData['user_id']?.toString() ?? '',
        fishId: '', // Nécessite de récupérer les produits vendus
        fishermanId: orderData['fournisseur_id']?.toString() ?? '',
        quantity: 0.0, // Nécessite de récupérer les produits vendus
        totalPrice:
            double.tryParse(orderData['totale']?.toString() ?? '0') ?? 0.0,
        status: _mapOrderStatus(orderData['statut_commande']),
        orderDate: DateTime.parse(
          orderData['created_at'] ?? DateTime.now().toString(),
        ),
        deliveryDate: null,
        deliveryAddress: null,
        notes: orderData['commentaire'],
      );

      batch.set(ordersRef.doc(orderId), order.toMap());
    }

    await batch.commit();
  }

  // Migrer les avis
  Future<void> migrateReviews(List<Map<String, dynamic>> sqlReviews) async {
    final batch = _db.batch();
    final reviewsRef = _db.collection('reviews');

    for (final reviewData in sqlReviews) {
      final reviewId = reviewData['id']?.toString() ?? const Uuid().v4();

      final review = Review(
        id: reviewId,
        fishId: reviewData['produit_id']?.toString() ?? '',
        userId: reviewData['user_id']?.toString() ?? '',
        userName:
            'Utilisateur', // Nécessite de récupérer le nom de l'utilisateur
        userImageUrl: null,
        rating:
            double.tryParse(reviewData['etoile_nb']?.toString() ?? '0') ?? 0.0,
        comment: reviewData['commentaire'] ?? '',
        createdAt: DateTime.parse(
          reviewData['created_at'] ?? DateTime.now().toString(),
        ),
      );

      batch.set(reviewsRef.doc(reviewId), review.toMap());
    }

    await batch.commit();
  }

  // Méthodes utilitaires

  String _getProductImageUrl(Map<String, dynamic> productData) {
    // Dans une implémentation réelle, vous devriez récupérer l'URL de l'image
    // à partir de la table marketplace_image
    return 'https://images.unsplash.com/photo-1545816250-e12bedba42ba?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80';
  }

  DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }

    try {
      // Format attendu: DD/MM/YYYY
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // année
          int.parse(parts[1]), // mois
          int.parse(parts[0]), // jour
        );
      }
    } catch (e) {
      print('Erreur lors de l\'analyse de la date: $e');
    }

    return DateTime.now();
  }

  OrderStatus _mapOrderStatus(String? status) {
    switch (status) {
      case 'En Cours':
        return OrderStatus.inProgress;
      case 'Livrée':
        return OrderStatus.delivered;
      case 'Annulée':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
