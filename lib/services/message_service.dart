import 'package:flutter/foundation.dart';
import '../models/marketplace_message.dart';
import '../models/marketplace_salon.dart';

import 'database_helper.dart';

class MessageService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MarketplaceMessage> _messages = [];
  List<MarketplaceSalon> _salons = [];
  int? _currentUserId;
  bool _isLoading = false;

  // Getters
  List<MarketplaceMessage> get messages => _messages;
  List<MarketplaceSalon> get salons => _salons;
  bool get isLoading => _isLoading;

  // Initialiser le service
  Future<void> init(int userId) async {
    _currentUserId = userId;
    await loadSalons();
  }

  // Charger les salons
  Future<void> loadSalons() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _salons = await _dbHelper.getAllSalons();
    } catch (e) {
      print('Erreur lors du chargement des salons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les messages entre deux utilisateurs
  Future<void> loadMessages(int destinataireId) async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _dbHelper.getMessagesBetweenUsers(
        _currentUserId!,
        destinataireId,
      );

      // Marquer les messages comme lus
      for (var message in _messages) {
        if (message.destinataireId == _currentUserId && !message.estLu) {
          if (message.id != null) {
            await _dbHelper.markMessageAsRead(message.id!);
          }
        }
      }

      // Marquer tous les messages comme lus
      await _dbHelper.markAllMessagesAsRead(_currentUserId!, destinataireId);
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Envoyer un message
  Future<bool> sendMessage({
    required int destinataireId,
    required String contenu,
  }) async {
    if (_currentUserId == null) return false;

    try {
      // Créer un nouveau message
      final message = MarketplaceMessage.create(
        contenu: contenu,
        expediteurId: _currentUserId,
        destinataireId: destinataireId,
      );

      // Insérer le message dans la base de données
      final messageId = await _dbHelper.insertMessage(message);
      
      // Ajouter le message à la liste locale
      _messages.add(message.copyWith(id: messageId));

      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      return false;
    }
  }

  // Supprimer un message
  Future<bool> deleteMessage(int messageId) async {
    try {
      await _dbHelper.deleteMessage(messageId);
      _messages.removeWhere((message) => message.id == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du message: $e');
      return false;
    }
  }

  // Créer un salon
  Future<bool> createSalon({
    required String titre,
    required String description,
    required DateTime date,
    required DateTime tempsDebut,
    required DateTime tempsFin,
    required String lieu,
    required int maxInvitation,
    required String affiche,
  }) async {
    try {
      final salon = MarketplaceSalon.create(
        titre: titre,
        description: description,
        date: date,
        tempsDebut: tempsDebut,
        tempsFin: tempsFin,
        lieu: lieu,
        maxInvitation: maxInvitation,
        affiche: affiche,
      );
      
      final salonId = await _dbHelper.insertSalon(salon);
      _salons.add(salon.copyWith(id: salonId));
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la création du salon: $e');
      return false;
    }
  }

  // Supprimer un salon
  Future<bool> deleteSalon(int salonId) async {
    try {
      await _dbHelper.deleteSalon(salonId);
      _salons.removeWhere((salon) => salon.id == salonId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du salon: $e');
      return false;
    }
  }

  // Obtenir le nombre de messages non lus
  Future<int> getUnreadMessagesCount() async {
    if (_currentUserId == null) return 0;

    try {
      int count = 0;
      
      // Récupérer tous les messages où l'utilisateur courant est le destinataire
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.messageTable,
        where: 'destinataire_id = ? AND est_lu = 0',
        whereArgs: [_currentUserId],
      );
      
      return maps.length;
    } catch (e) {
      print('Erreur lors du comptage des messages non lus: $e');
      return 0;
    }
  }
}
