import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Classe utilitaire pour initialiser les données dans Firebase
class FirebaseDataInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialiser les données de démonstration dans Firebase
  Future<void> initializeDemoData() async {
    await _initializeEspeces();
    await _initializeUsers();
  }

  /// Initialiser les espèces de poissons
  Future<void> _initializeEspeces() async {
    // Vérifier si la collection especes existe déjà
    final especesSnapshot = await _firestore.collection('especes').limit(1).get();
    if (especesSnapshot.docs.isNotEmpty) {
      print('Les espèces existent déjà dans Firestore');
      return;
    }

    // Liste des espèces à ajouter
    final especes = [
      {'nom': 'Thon rouge', 'imageUrl': 'assets/images/thon.jpg'},
      {'nom': 'Dorade', 'imageUrl': 'assets/images/dorade.jpg'},
      {'nom': 'Sardine', 'imageUrl': 'assets/images/sardine.jpg'},
      {'nom': 'Bar', 'imageUrl': 'assets/images/bar.jpg'},
      {'nom': 'Maquereau', 'imageUrl': 'assets/images/maquereau.jpg'},
      {'nom': 'Merlu', 'imageUrl': 'assets/images/merlu.jpg'},
      {'nom': 'Sole', 'imageUrl': 'assets/images/sole.jpg'},
      {'nom': 'Loup de mer', 'imageUrl': 'assets/images/loup.jpg'},
      {'nom': 'Rouget', 'imageUrl': 'assets/images/rouget.jpg'},
      {'nom': 'Anchois', 'imageUrl': 'assets/images/anchois.jpg'},
    ];

    // Ajouter les espèces à Firestore
    for (final espece in especes) {
      await _firestore.collection('especes').add({
        ...espece,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('Espèces initialisées dans Firestore');
  }

  /// Initialiser les utilisateurs de démonstration
  Future<void> _initializeUsers() async {
    // Vérifier si les utilisateurs existent déjà
    try {
      await _auth.signInWithEmailAndPassword(
        email: 'client@example.com',
        password: 'password123',
      );
      print('Les utilisateurs existent déjà dans Firebase Auth');
      await _auth.signOut();
      return;
    } catch (e) {
      // Continuer si l'utilisateur n'existe pas
    }

    // Créer les utilisateurs de démonstration
    await _createDemoUser(
      email: 'client@example.com',
      password: 'password123',
      userData: {
        'nom': 'Dupont',
        'prenom': 'Jean',
        'telephone': 123456789,
        'roles': '["ROLE_CLIENT"]',
        'isVerified': true,
        'isBlocked': false,
        'isValid': true,
      },
      collection: 'users',
    );

    await _createDemoUser(
      email: 'pecheur@example.com',
      password: 'password123',
      userData: {
        'nom': 'Martin',
        'prenom': 'Pierre',
        'cin': 'AB123456',
        'matricule': 'P001',
        'capacite': '500kg',
        'bateau': 'Bateau 1',
        'port': 'Port A',
        'telephone': 987654321,
        'roles': '["ROLE_PECHEUR"]',
        'isValid': true,
      },
      collection: 'pecheurs',
    );

    await _createDemoUser(
      email: 'vet@example.com',
      password: 'password123',
      userData: {
        'nom': 'Dubois',
        'prenom': 'Marie',
        'cin': 'CD789012',
        'matricule': 'V001',
        'port': 'Port A',
        'telephone': 456789123,
        'roles': '["ROLE_VETERINAIRE"]',
        'isValid': true,
      },
      collection: 'vitirinaires',
    );

    await _createDemoUser(
      email: 'maryeur@example.com',
      password: 'password123',
      userData: {
        'nom': 'Leroy',
        'prenom': 'Sophie',
        'cin': 'EF345678',
        'matricule': 'M001',
        'port': 'Port A',
        'telephone': 789123456,
        'roles': '["ROLE_MARYEUR"]',
        'isValid': true,
      },
      collection: 'maryeurs',
    );

    print('Utilisateurs de démonstration initialisés dans Firebase');
  }

  /// Créer un utilisateur de démonstration
  Future<void> _createDemoUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
    required String collection,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ajouter les données utilisateur à Firestore
      await _firestore.collection(collection).doc(userCredential.user!.uid).set({
        ...userData,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Se déconnecter
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur $email: ${e.toString()}');
    }
  }
}
