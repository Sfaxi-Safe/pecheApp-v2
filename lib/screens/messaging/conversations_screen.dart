import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import '../../models/marketplace_user.dart';
import '../../utils/app_theme.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMessageService();
    });
  }

  Future<void> _initializeMessageService() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final messageService = Provider.of<MessageService>(
        context,
        listen: false,
      );

      if (authService.currentUser != null) {
        await messageService.init(authService.currentUser!.id.toString());
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<MessageService>(
              builder: (context, messageService, child) {
                if (messageService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Commencez à discuter avec un pêcheur ou un client',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => messageService.refreshConversations(),
                  child: ListView.separated(
                    itemCount: messageService.conversations.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = messageService.conversations[index];
                      final otherUserId = conversation['otherUserId'];
                      final otherUserName = conversation['otherUserName'];
                      final otherUserImageUrl = conversation['otherUserImageUrl'];
                      final otherUserType = conversation['otherUserType'];
                      final lastMessageContent =
                          conversation['lastMessageContent'] ?? 'Nouvelle conversation';
                      final lastMessageTime = DateTime.parse(
                        conversation['lastMessageTime'],
                      );
                      final hasUnreadMessages = conversation['hasUnreadMessages'] == 1;

                      return Dismissible(
                        key: Key(conversation['id'].toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await _showDeleteDialog(context, conversation['id']);
                        },
                        onDismissed: (direction) {
                          messageService.deleteConversation(conversation['id'].toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conversation supprimée'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            backgroundImage:
                                otherUserImageUrl != null
                                    ? NetworkImage(otherUserImageUrl)
                                    : null,
                            child:
                                otherUserImageUrl == null
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
                              fontWeight:
                                  hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            lastMessageContent,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
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
                                  color: hasUnreadMessages ? AppTheme.primaryColor : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (hasUnreadMessages)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('', style: TextStyle(fontSize: 8)),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      otherUserId: otherUserId,
                                      otherUserName: otherUserName,
                                    ),
                              ),
                            ).then((_) {
                              // Rafraîchir les conversations après le retour
                              messageService.refreshConversations();
                            });
                          },
                        ),
                      );
                    },
                  ),
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
        backgroundColor: AppTheme.primaryColor,
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
      return DateFormat.MMMd('fr_FR').format(date);
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context, String conversationId) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la conversation'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    ) ?? false;
  }
}

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({Key? key}) : super(key: key);

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  List<MarketplaceUser> _users = [];
  List<MarketplaceUser> _filteredUsers = [];
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers =
            _users.where((user) {
              final fullName = "${user.prenom} ${user.nom}".toLowerCase();
              return fullName.contains(query.toLowerCase()) ||
                  (user.email?.toLowerCase() ?? "").contains(
                    query.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle conversation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                      itemCount: _filteredUsers.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            backgroundImage:
                                user.photo != null
                                    ? NetworkImage(user.photo!)
                                    : null,
                            child:
                                user.photo == null
                                    ? Icon(
                                      user.isPecheur
                                          ? Icons.sailing
                                          : Icons.person,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                          title: Text("${user.prenom} ${user.nom}"),
                          subtitle: Text(user.isPecheur ? 'Pêcheur' : 'Client'),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      otherUserId: user.id.toString(),
                                      otherUserName:
                                          "${user.prenom} ${user.nom}",
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
