import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:peche_app/models/user.dart';
import 'package:peche_app/models/fish.dart';
import 'package:peche_app/models/order.dart';
import 'package:peche_app/models/review.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Références des collections
  final CollectionReference _usersCollection;
  final CollectionReference _fishCollection;
  final CollectionReference _ordersCollection;
  final CollectionReference _reviewsCollection;

  DatabaseService()
    : _usersCollection = FirebaseFirestore.instance.collection('users'),
      _fishCollection = FirebaseFirestore.instance.collection('fish'),
      _ordersCollection = FirebaseFirestore.instance.collection('orders'),
      _reviewsCollection = FirebaseFirestore.instance.collection('reviews');

  // Opérations utilisateur
  Future<void> createUser(User user) async {
    await _usersCollection.doc(user.id).set(user.toMap());
  }

  Future<User?> getUser(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      return User.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<User>> getFishermen() async {
    final snapshot =
        await _usersCollection.where('userType', isEqualTo: 'fisherman').get();

    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Opérations poisson
  Future<void> createFish(Fish fish) async {
    await _fishCollection.doc(fish.id).set(fish.toMap());
  }

  Future<List<Fish>> getAllFish() async {
    final snapshot = await _fishCollection.get();

    return snapshot.docs
        .map((doc) => Fish.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Fish>> getFishByFisherman(String fishermanId) async {
    final snapshot =
        await _fishCollection
            .where('fishermanId', isEqualTo: fishermanId)
            .get();

    return snapshot.docs
        .map((doc) => Fish.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Opérations commande
  Future<void> createOrder(PecheOrder order) async {
    await _ordersCollection.doc(order.id).set(order.toMap());
  }

  Future<List<PecheOrder>> getOrdersByClient(String clientId) async {
    final snapshot =
        await _ordersCollection.where('clientId', isEqualTo: clientId).get();

    return snapshot.docs
        .map((doc) => PecheOrder.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<PecheOrder>> getOrdersByFisherman(String fishermanId) async {
    final snapshot =
        await _ordersCollection
            .where('fishermanId', isEqualTo: fishermanId)
            .get();

    return snapshot.docs
        .map((doc) => PecheOrder.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Opérations avis
  Future<void> addReview(Review review) async {
    await _reviewsCollection.doc(review.id).set(review.toMap());
  }

  Future<List<Review>> getReviewsForFish(String fishId) async {
    final snapshot =
        await _reviewsCollection.where('fishId', isEqualTo: fishId).get();

    return snapshot.docs
        .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Calculer la note moyenne pour un poisson
  Future<double> getAverageRating(String fishId) async {
    final reviews = await getReviewsForFish(fishId);

    if (reviews.isEmpty) {
      return 0.0;
    }

    final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }
}
