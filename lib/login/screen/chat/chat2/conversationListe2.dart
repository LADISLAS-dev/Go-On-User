import 'package:appointy/login/screen/chat/chat2/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ConversationListPage extends StatelessWidget {
  final ChatService _chatService = ChatService();

  ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Non connecté'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Conversations')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getConversations(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(
                'Erreur lors de la récupération des conversations: ${snapshot.error}');
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('Aucune conversation trouvée.');
            return const Center(child: Text('Aucune conversation trouvée.'));
          }

          final conversations = snapshot.data!.docs;
          print('Nombre de conversations trouvées: ${conversations.length}');
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final chatRoomId = conversation.id;

              // Vérifiez que le tableau users contient au moins deux éléments
              final users = conversation['users'] as List;
              if (users.length < 2) {
                print(
                    'Erreur: Le tableau users ne contient pas assez d\'éléments.');
                return const ListTile(
                  title: Text('Conversation invalide'),
                  subtitle: Text('Données corrompues'),
                );
              }

              // Trouvez l'ID de l'autre utilisateur
              final otherUserId = users.firstWhere(
                (id) => id != user.uid,
                orElse: () =>
                    '', // Valeur par défaut si aucun élément ne correspond
              );

              if (otherUserId.isEmpty) {
                print(
                    'Erreur: Aucun autre utilisateur trouvé dans la conversation.');
                return const ListTile(
                  title: Text('Conversation invalide'),
                  subtitle: Text('Données corrompues'),
                );
              }

              // Logs pour déboguer
              print('Conversation ID: ${conversation.id}');
              print('Users: ${conversation['users']}');
              print('Last Message: ${conversation['lastMessage']}');

              return ListTile(
                title: Text('Conversation avec $otherUserId'),
                subtitle: Text(conversation['lastMessage']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: chatRoomId,
                        currentUserId: user.uid,
                        receiverId: otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ouvrir une nouvelle conversation
          _startNewConversation(context, user.uid);
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  void _startNewConversation(BuildContext context, String userId) async {
    final receiverId = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController receiverIdController =
            TextEditingController();
        return AlertDialog(
          title: const Text('Nouvelle conversation'),
          content: TextField(
            controller: receiverIdController,
            decoration:
                const InputDecoration(hintText: 'Entrez l\'ID du destinataire'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                final receiverId = receiverIdController.text;
                if (receiverId.isNotEmpty) {
                  Navigator.pop(context, receiverId);
                }
              },
              child: const Text('Démarrer'),
            ),
          ],
        );
      },
    );

    if (receiverId != null && receiverId.isNotEmpty) {
      final chatRoomId = _chatService._generateChatRoomId(userId, receiverId);
      await _chatService.startConversation(userId, receiverId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            currentUserId: userId,
            receiverId: receiverId,
          ),
        ),
      );
    }
  }
}




class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Envoyer un message
  Future<void> sendMessage(String chatRoomId, String senderId,
      String receiverId, String message) async {
    if (message.isEmpty) return;

    try {
      await _firestore
          .collection('conversations')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mettre à jour la conversation avec le dernier message
      await _firestore.collection('conversations').doc(chatRoomId).update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de l\'envoi du message : $e');
    }
  }

  // Démarrer une nouvelle conversation
  Future<void> startConversation(String user1, String user2) async {
    final chatRoomId = _generateChatRoomId(user1, user2);

    try {
      await _firestore.collection('conversations').doc(chatRoomId).set({
        'users': [user1, user2],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la création de la conversation : $e');
    }
  }

  // Récupérer les conversations d'un utilisateur
  Stream<QuerySnapshot> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('users', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Récupérer les messages d'une conversation
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('conversations')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Générer un ID unique pour la conversation
  String _generateChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort(); // Tri des IDs pour garantir que l'ID de la conversation est cohérent
    return ids.join('-');
  }
}


