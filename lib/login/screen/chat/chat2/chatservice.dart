
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Envoyer un message
//   Future<void> sendMessage(String chatRoomId, String senderId,
//       String receiverId, String message) async {
//     if (message.isEmpty) return;

//     try {
//       await _firestore
//           .collection('conversations')
//           .doc(chatRoomId)
//           .collection('messages')
//           .add({
//         'senderId': senderId,
//         'receiverId': receiverId,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Mettre à jour la conversation avec le dernier message
//       await _firestore.collection('conversations').doc(chatRoomId).update({
//         'lastMessage': message,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print('Erreur lors de l\'envoi du message : $e');
//     }
//   }

//   // Démarrer une nouvelle conversation
//   Future<void> startConversation(String user1, String user2) async {
//     final chatRoomId = _generateChatRoomId(user1, user2);

//     try {
//       await _firestore.collection('conversations').doc(chatRoomId).set({
//         'users': [user1, user2],
//         'lastMessage': '',
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print('Erreur lors de la création de la conversation : $e');
//     }
//   }

//   // Récupérer les conversations d'un utilisateur
//   Stream<QuerySnapshot> getConversations(String userId) {
//     return _firestore
//         .collection('conversations')
//         .where('users', arrayContains: userId)
//         .orderBy('timestamp', descending: true)
//         .snapshots();
//   }

//   // Récupérer les messages d'une conversation
//   Stream<QuerySnapshot> getMessages(String chatRoomId) {
//     return _firestore
//         .collection('conversations')
//         .doc(chatRoomId)
//         .collection('messages')
//         .orderBy('timestamp', descending: false)
//         .snapshots();
//   }

//   // Générer un ID unique pour la conversation
//   String _generateChatRoomId(String user1, String user2) {
//     List<String> ids = [user1, user2];
//     ids.sort(); // Tri des IDs pour garantir que l'ID de la conversation est cohérent
//     return ids.join('-');
//   }
// }


