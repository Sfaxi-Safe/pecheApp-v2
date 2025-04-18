import 'package:flutter/foundation.dart';
import '../models/marketplace_message.dart';
import '../models/marketplace_user.dart';

import 'database_helper.dart';

class MessageService with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<MarketplaceMessage> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  int? _currentUserId;
  bool _isLoading = false;

  // Getters
  List<MarketplaceMessage> get messages => _messages;
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoading => _isLoading;

  // Initialiser le service
  Future<void> init(String userId) async {
    _currentUserId = int.tryParse(userId);
    await loadConversations();
  }

  // Charger les conversations de l'utilisateur
  Future<void> loadConversations() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _conversations = await _dbHelper.getConversationsForUser(_currentUserId!);
    } catch (e) {
      print('Erreur lors du chargement des conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les messages entre deux utilisateurs
  Future<void> loadMessages(String otherUserIdStr) async {
    if (_currentUserId == null) return;

    final otherUserId = int.tryParse(otherUserIdStr);
    if (otherUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _dbHelper.getMessagesBetweenUsers(
        _currentUserId!,
        otherUserId,
      );

      // Marquer les messages comme lus
      for (var message in _messages) {
        if (message.receiverId == _currentUserId && !message.isRead) {
          if (message.id != null) {
            await _dbHelper.markMessageAsRead(message.id!);
          }
        }
      }

      // Mettre à jour la conversation
      final conversationId = await _dbHelper.getOrCreateSalon(
        _currentUserId!,
        otherUserId,
      );
      await _dbHelper.markConversationAsRead(conversationId);

      // Recharger les conversations pour mettre à jour l'UI
      await loadConversations();
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Envoyer un message
  Future<bool> sendMessage({
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    if (_currentUserId == null) return false;

    final receiverIdInt = int.tryParse(receiverId);
    if (receiverIdInt == null) return false;

    try {
      // Créer un nouveau message
      final message = MarketplaceMessage.create(
        senderId: _currentUserId,
        receiverId: receiverIdInt,
        content: content,
        imageUrl: imageUrl,
      );

      // Insérer le message dans la base de données
      await _dbHelper.insertMessage(message);

      // Mettre à jour ou créer la conversation
      final conversationId = await _dbHelper.getOrCreateSalon(
        _currentUserId!,
        receiverIdInt,
      );
      await _dbHelper.updateConversationLastMessage(
        conversationId,
        content,
        message.timestamp,
        true,
      );

      // Ajouter le message à la liste locale
      _messages.add(message);

      // Recharger les conversations pour mettre à jour l'UI
      await loadConversations();

      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      return false;
    }
  }

  // Supprimer un message
  Future<bool> deleteMessage(String messageIdStr) async {
    final messageId = int.tryParse(messageIdStr);
    if (messageId == null) return false;

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

  // Supprimer une conversation
  Future<bool> deleteConversation(String conversationIdStr) async {
    final conversationId = int.tryParse(conversationIdStr);
    if (conversationId == null) return false;

    try {
      await _dbHelper.deleteConversation(conversationId);
      await loadConversations();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la conversation: $e');
      return false;
    }
  }

  // Obtenir le nombre de messages non lus
  Future<int> getUnreadMessagesCount() async {
    if (_currentUserId == null) return 0;

    try {
      int count = 0;
      for (var conversation in _conversations) {
        if (conversation['hasUnreadMessages'] == 1 &&
            conversation['otherUserId'] != _currentUserId) {
          count++;
        }
      }
      return count;
    } catch (e) {
      print('Erreur lors du comptage des messages non lus: $e');
      return 0;
    }
  }
}
