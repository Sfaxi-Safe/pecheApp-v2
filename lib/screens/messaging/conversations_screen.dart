import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import 'chat_screen.dart';
import '../../models/user.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final messageService = Provider.of<MessageService>(context, listen: false);
      
      if (authService.currentUser != null) {
        messageService.init(authService.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: Consumer<MessageService>(
        builder: (context, messageService, child) {
          if (messageService.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (messageService.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune conversation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Commencez à discuter avec un pêcheur ou un client',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Naviguer vers la liste des utilisateurs pour démarrer une nouvelle conversation
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewConversationScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Nouvelle conversation'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: messageService.conversations.length,
            itemBuilder: (context, index) {
              final conversation = messageService.conversations[index];
              final otherUserId = conversation['otherUserId'];
              final otherUserName = conversation['otherUserName'];
              final otherUserImageUrl = conversation['otherUserImageUrl'];
              final otherUserType = conversation['otherUserType'];
              final lastMessageContent = conversation['lastMessageContent'] ?? 'Nouvelle conversation';
              final lastMessageTime = DateTime.parse(conversation['lastMessageTime']);
              final hasUnreadMessages = conversation['hasUnreadMessages'] == 1;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: otherUserImageUrl != null
                      ? NetworkImage(otherUserImageUrl)
                      : null,
                  child: otherUserImageUrl == null
                      ? Icon(
                          otherUserType == 'fisherman'
                              ? Icons.sailing
                              : Icons.person,
                          color: Colors.white,
                        )
                      : null,
                ),
                title: Text(
                  otherUserName,
                  style: TextStyle(
                    fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  lastMessageContent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(lastMessageTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: hasUnreadMessages ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasUnreadMessages)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '',
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: otherUserId,
                        otherUserName: otherUserName,
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  _showDeleteDialog(context, conversation['id']);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewConversationScreen(),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return DateFormat.Hm().format(date);
    } else if (dateToCheck == yesterday) {
      return 'Hier';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  void _showDeleteDialog(BuildContext context, String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final messageService = Provider.of<MessageService>(context, listen: false);
              messageService.deleteConversation(conversationId);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({Key? key}) : super(key: key);

  @override
  _NewConversationScreenState createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserId = authService.currentUser!.id;
      
      // Charger tous les utilisateurs sauf l'utilisateur actuel
      final allUsers = await dbHelper.getAllUsers();
      _users = allUsers.where((user) => user.id != currentUserId).toList();
      _filteredUsers = List.from(_users);
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users
            .where((user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle conversation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher un utilisateur',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text('Aucun utilisateur trouvé'),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                              child: user.profileImageUrl == null
                                  ? Icon(
                                      user.userType == 'fisherman'
                                          ? Icons.sailing
                                          : Icons.person,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(user.name),
                            subtitle: Text(
                              user.userType == 'fisherman'
                                  ? 'Pêcheur'
                                  : 'Client',
                            ),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    otherUserId: user.id,
                                    otherUserName: user.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
