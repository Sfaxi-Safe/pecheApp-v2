import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:seatrace/models/espece.dart';
import 'package:seatrace/models/lot.dart';
import 'package:seatrace/models/pecheur.dart';
import 'package:seatrace/models/vitirinaire.dart';
import 'package:seatrace/models/maryeur.dart';
import 'package:seatrace/models/user.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ===== Méthodes pour les utilisateurs =====

  // Récupérer un utilisateur par email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final querySnapshot =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    }

    return null;
  }

  // Récupérer un pêcheur par email
  Future<Map<String, dynamic>?> getPecheurByEmail(String email) async {
    final querySnapshot =
        await _firestore
            .collection('pecheurs')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    }

    return null;
  }

  // Récupérer un vétérinaire par email
  Future<Map<String, dynamic>?> getVitirinaireByEmail(String email) async {
    final querySnapshot =
        await _firestore
            .collection('vitirinaires')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    }

    return null;
  }

  // Récupérer un maryeur par email
  Future<Map<String, dynamic>?> getMaryeurByEmail(String email) async {
    final querySnapshot =
        await _firestore
            .collection('maryeurs')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    }

    return null;
  }

  // ===== Méthodes pour les espèces =====

  // Récupérer toutes les espèces
  Future<List<Map<String, dynamic>>> getAllEspeces() async {
    final querySnapshot = await _firestore.collection('especes').get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Récupérer une espèce par nom
  Future<Map<String, dynamic>?> getEspeceByNom(String nom) async {
    final querySnapshot =
        await _firestore
            .collection('especes')
            .where('nom', isEqualTo: nom)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {'id': doc.id, ...doc.data()};
    }

    return null;
  }

  // Ajouter une espèce
  Future<String> addEspece(Map<String, dynamic> especeData) async {
    final docRef = await _firestore.collection('especes').add(especeData);
    return docRef.id;
  }

  // ===== Méthodes pour les prises =====

  // Ajouter une prise
  Future<String> addPrise(Map<String, dynamic> priseData) async {
    final docRef = await _firestore.collection('prises').add(priseData);
    return docRef.id;
  }

  // Récupérer les prises d'un pêcheur
  Future<List<Map<String, dynamic>>> getPrisesByPecheurId(
    String pecheurId,
  ) async {
    final querySnapshot =
        await _firestore
            .collection('prises')
            .where('pecheur_id', isEqualTo: pecheurId)
            .get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // ===== Méthodes pour les lots =====

  // Ajouter un lot
  Future<String> addLot(Map<String, dynamic> lotData, File? imageFile) async {
    // Si une image est fournie, la télécharger sur Firebase Storage
    if (imageFile != null) {
      final storageRef = _storage.ref().child(
        'lots/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      final imageUrl = await snapshot.ref.getDownloadURL();

      lotData['photo'] = imageUrl;
    }

    final docRef = await _firestore.collection('lots').add({
      ...lotData,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Mettre à jour un lot
  Future<void> updateLot(String lotId, Map<String, dynamic> lotData) async {
    await _firestore.collection('lots').doc(lotId).update(lotData);
  }

  // Récupérer un lot par ID
  Future<Map<String, dynamic>?> getLotById(String lotId) async {
    final docSnapshot = await _firestore.collection('lots').doc(lotId).get();

    if (docSnapshot.exists) {
      return {'id': docSnapshot.id, ...docSnapshot.data()!};
    }

    return null;
  }

  // Récupérer les lots d'un pêcheur
  Future<List<Map<String, dynamic>>> getLotsByPecheurId(
    String pecheurId,
  ) async {
    final querySnapshot =
        await _firestore
            .collection('lots')
            .where('pecheur_id', isEqualTo: pecheurId)
            .get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Récupérer les lots en attente de validation par un vétérinaire
  Future<List<Map<String, dynamic>>> getPendingLotsForVitirinaire() async {
    final querySnapshot =
        await _firestore
            .collection('lots')
            .where('test', isEqualTo: false)
            .get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Récupérer les lots validés en attente de prix par un maryeur
  Future<List<Map<String, dynamic>>> getPendingLotsForMaryeur() async {
    final querySnapshot =
        await _firestore
            .collection('lots')
            .where('test', isEqualTo: true)
            .where('status', isEqualTo: true)
            .where('prixinitial', isEqualTo: null)
            .get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Récupérer les lots disponibles pour enchères
  Future<List<Map<String, dynamic>>> getAvailableAuctions() async {
    final querySnapshot =
        await _firestore
            .collection('lots')
            .where('prixinitial', isNull: false)
            .where('vendre', isEqualTo: false)
            .get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Récupérer les achats d'un client
  Future<List<Map<String, dynamic>>> getPurchasesByUserId(String userId) async {
    final querySnapshot =
        await _firestore
            .collection('lots')
            .where('user_id', isEqualTo: userId)
            .where('vendre', isEqualTo: true)
            .get();

    return querySnapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Placer une enchère
  Future<void> placeBid(String lotId, String userId, String bidAmount) async {
    // Utiliser une transaction pour garantir l'intégrité des données
    await _firestore.runTransaction((transaction) async {
      final lotRef = _firestore.collection('lots').doc(lotId);
      final lotSnapshot = await transaction.get(lotRef);

      if (!lotSnapshot.exists) {
        throw Exception('Le lot n\'existe pas');
      }

      final lotData = lotSnapshot.data()!;
      final currentPrice = double.parse(
        lotData['current'] ?? lotData['prixinitial'] ?? '0',
      );
      final newBidAmount = double.parse(bidAmount);

      if (newBidAmount <= currentPrice) {
        throw Exception('L\'enchère doit être supérieure au prix actuel');
      }

      // Mettre à jour le lot avec la nouvelle enchère
      transaction.update(lotRef, {
        'current': bidAmount,
        'user_id': userId,
        'lastBidAt': FieldValue.serverTimestamp(),
      });

      // Ajouter l'enchère à l'historique
      final bidRef = _firestore.collection('bids').doc();
      transaction.set(bidRef, {
        'lot_id': lotId,
        'user_id': userId,
        'amount': bidAmount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Finaliser une vente (marquer un lot comme vendu)
  Future<void> finalizeSale(String lotId, String userId) async {
    await _firestore.runTransaction((transaction) async {
      final lotRef = _firestore.collection('lots').doc(lotId);
      final lotSnapshot = await transaction.get(lotRef);

      if (!lotSnapshot.exists) {
        throw Exception('Le lot n\'existe pas');
      }

      final lotData = lotSnapshot.data()!;

      // Vérifier que l'utilisateur est bien le dernier enchérisseur
      if (lotData['user_id'] != userId) {
        throw Exception('Vous n\'êtes pas le dernier enchérisseur');
      }

      // Marquer le lot comme vendu
      transaction.update(lotRef, {
        'vendre': true,
        'datevendre': DateTime.now().toIso8601String(),
      });

      // Ajouter la vente à l'historique
      final saleRef = _firestore.collection('sales').doc();
      transaction.set(saleRef, {
        'lot_id': lotId,
        'user_id': userId,
        'amount': lotData['current'] ?? lotData['prixinitial'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Récupérer l'historique des enchères pour un lot
  Future<List<Map<String, dynamic>>> getBidHistoryForLot(String lotId) async {
    final querySnapshot =
        await _firestore
            .collection('bids')
            .where('lot_id', isEqualTo: lotId)
            .orderBy('createdAt', descending: true)
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{'id': doc.id, ...data};
    }).toList();
  }

  // Récupérer les enchères en cours d'un utilisateur
  Future<List<Map<String, dynamic>>> getActiveBidsByUserId(
    String userId,
  ) async {
    final querySnapshot =
        await _firestore
            .collection('lots')
            .where('user_id', isEqualTo: userId)
            .where('vendre', isEqualTo: false)
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{'id': doc.id, ...data};
    }).toList();
  }

  // Méthode générique pour les requêtes avec conditions
  Future<List<Map<String, dynamic>>> queryWhere(
    String collection,
    String field,
    dynamic value,
  ) async {
    final querySnapshot =
        await _firestore
            .collection(collection)
            .where(field, isEqualTo: value)
            .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{'id': doc.id, ...data};
    }).toList();
  }

  // Méthode générique pour les requêtes avec plusieurs conditions
  Future<List<Map<String, dynamic>>> queryWhereMultiple(
    String collection,
    List<Map<String, dynamic>> conditions,
  ) async {
    Query query = _firestore.collection(collection);

    for (final condition in conditions) {
      query = query.where(
        condition['field'] as String,
        isEqualTo: condition['value'],
      );
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return <String, dynamic>{'id': doc.id, ...data};
    }).toList();
  }
}
