import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/message.dart';

class FirebaseMessageService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  String? _userId;
  List<Map<String, dynamic>> _conversations = [];
  Map<String, List<Message>> _messages = {};
  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get conversations => _conversations;
  Map<String, List<Message>> get messages => _messages;
  bool get isLoading => _isLoading;

  // Initialiser le service avec l'ID de l'utilisateur
  Future<void> init(String userId) async {
    _userId = userId;
    await loadConversations();
  }

  // Charger les conversations depuis Firestore
  Future<void> loadConversations() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Récupérer les conversations où l'utilisateur est impliqué
      final snapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: _userId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      
      List<Map<String, dynamic>> conversationsList = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        
        // Trouver l'ID de l'autre utilisateur
        final otherUserId = participants.firstWhere(
          (id) => id != _userId,
          orElse: () => '',
        );
        
        if (otherUserId.isNotEmpty) {
          // Récupérer les informations de l'autre utilisateur
          final userDoc = await _firestore.collection('users').doc(otherUserId).get();
          
          if (userDoc.exists) {
            final userData = userDoc.data()!;
            
            conversationsList.add({
              'id': doc.id,
              'otherUserId': otherUserId,
              'otherUserName': userData['name'] ?? '',
              'otherUserImageUrl': userData['profileImageUrl'],
              'otherUserType': userData['userType'] ?? '',
              'lastMessageContent': data['lastMessageContent'] ?? '',
              'lastMessageTime': data['lastMessageTime'] != null 
                ? (data['lastMessageTime'] as Timestamp).toDate() 
                : DateTime.now(),
              'hasUnreadMessages': data['hasUnreadMessages'] ?? false,
            });
          }
        }
      }
      
      _conversations = conversationsList;
    } catch (e) {
      print('Erreur lors du chargement des conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les messages d'une conversation
  Future<List<Message>> loadMessages(String conversationId) async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .get();
      
      final messagesList = snapshot.docs.map((doc) {
        final data = doc.data();
        return Message(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          receiverId: data['receiverId'] ?? '',
          content: data['content'] ?? '',
          timestamp: data['timestamp'] != null 
            ? (data['timestamp'] as Timestamp).toDate() 
            : DateTime.now(),
          isRead: data['isRead'] ?? false,
          imageUrl: data['imageUrl'],
        );
      }).toList();
      
      _messages[conversationId] = messagesList;
      notifyListeners();
      
      // Marquer les messages comme lus
      await markConversationAsRead(conversationId);
      
      return messagesList;
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
      return [];
    }
  }

  // Créer ou récupérer une conversation entre deux utilisateurs
  Future<String> getOrCreateConversation(String otherUserId) async {
    if (_userId == null) return '';

    try {
      // Vérifier si une conversation existe déjà
      final snapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: _userId)
          .get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }
      
      // Créer une nouvelle conversation
      final docRef = await _firestore.collection('conversations').add({
        'participants': [_userId, otherUserId],
        'lastMessageTime': Timestamp.now(),
        'lastMessageContent': null,
        'hasUnreadMessages': false,
      });
      
      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création de la conversation: $e');
      return '';
    }
  }

  // Envoyer un message
  Future<bool> sendMessage({
    required String conversationId,
    required String receiverId,
    required String content,
    File? imageFile,
  }) async {
    if (_userId == null) return false;

    try {
      String? imageUrl;
      
      // Si une image est fournie, la télécharger
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final storageRef = _storage.ref().child('message_images/$conversationId/$fileName');
        
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask;
        
        imageUrl = await snapshot.ref.getDownloadURL();
      }
      
      // Créer le message
      final messageData = {
        'senderId': _userId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'imageUrl': imageUrl,
      };
      
      // Ajouter le message à la collection de messages de la conversation
      final messageRef = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(messageData);
      
      // Mettre à jour les informations de la conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessageContent': content,
        'lastMessageTime': Timestamp.now(),
        'hasUnreadMessages': true,
      });
      
      // Mettre à jour la liste locale des messages
      final newMessage = Message(
        id: messageRef.id,
        senderId: _userId!,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
      );
      
      if (_messages.containsKey(conversationId)) {
        _messages[conversationId]!.add(newMessage);
      } else {
        _messages[conversationId] = [newMessage];
      }
      
      // Mettre à jour la liste des conversations
      await loadConversations();
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      return false;
    }
  }

  // Marquer une conversation comme lue
  Future<void> markConversationAsRead(String conversationId) async {
    if (_userId == null) return;

    try {
      // Mettre à jour le statut de la conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'hasUnreadMessages': false,
      });
      
      // Mettre à jour le statut des messages non lus
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: _userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      
      // Mettre à jour la liste locale des conversations
      final index = _conversations.indexWhere((conv) => conv['id'] == conversationId);
      if (index != -1) {
        _conversations[index]['hasUnreadMessages'] = false;
      }
      
      // Mettre à jour la liste locale des messages
      if (_messages.containsKey(conversationId)) {
        for (var i = 0; i < _messages[conversationId]!.length; i++) {
          if (_messages[conversationId]![i].receiverId == _userId && !_messages[conversationId]![i].isRead) {
            _messages[conversationId]![i] = _messages[conversationId]![i].copyWith(isRead: true);
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du marquage de la conversation comme lue: $e');
    }
  }

  // Supprimer une conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      // Supprimer tous les messages de la conversation
      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Supprimer la conversation
      batch.delete(_firestore.collection('conversations').doc(conversationId));
      await batch.commit();
      
      // Mettre à jour les listes locales
      _conversations.removeWhere((conv) => conv['id'] == conversationId);
      _messages.remove(conversationId);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la conversation: $e');
      return false;
    }
  }
}
