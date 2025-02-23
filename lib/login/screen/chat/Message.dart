// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/services.dart';

// class MessagingPage extends StatefulWidget {
//   const MessagingPage({Key? key}) : super(key: key);

//   @override
//   _MessagingPageState createState() => _MessagingPageState();
// }

// class _MessagingPageState extends State<MessagingPage> {
//   final TextEditingController _messageController = TextEditingController();
//   String? _replyingToMessageId;
//   Map<String, dynamic>? _replyingToMessage;
//   String? _editingMessageId;
//   PlatformFile? _pickedFile;

//   Future<void> _sendMessage() async {
//     final message = _messageController.text;
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if ((message.isNotEmpty || _pickedFile != null) && currentUser != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUser.uid)
//             .get();

//         final userName = userDoc.data()?['name'] ??
//             currentUser.displayName ??
//             'Utilisateur Anonyme';
//         final userProfileImage = userDoc.data()?['profileImage'] ??
//             currentUser.photoURL ??
//             'https://via.placeholder.com/150';

//         String? fileUrl;
//         if (_pickedFile != null) {
//           // Téléverser le fichier ou la photo dans Firebase Storage
//           final storageRef = FirebaseStorage.instance
//               .ref()
//               .child('messages/${_pickedFile!.name}');
//           await storageRef.putData(_pickedFile!.bytes!);
//           fileUrl = await storageRef.getDownloadURL();
//         }

//         if (_editingMessageId != null) {
//           // Mettre à jour le message existant
//           await FirebaseFirestore.instance
//               .collection('messages')
//               .doc(_editingMessageId)
//               .update({
//             'text': message,
//             'fileUrl': fileUrl,
//             'updatedAt': FieldValue.serverTimestamp(),
//             'isEdited': true,
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Message modifié')),
//           );
//           setState(() {
//             _editingMessageId = null;
//           });
//         } else {
//           // Envoyer un nouveau message
//           await FirebaseFirestore.instance.collection('messages').add({
//             'text': message,
//             'fileUrl': fileUrl,
//             'createdAt': FieldValue.serverTimestamp(),
//             'updatedAt': FieldValue.serverTimestamp(),
//             'userId': currentUser.uid,
//             'userName': userName,
//             'userProfileImage': userProfileImage,
//             'parentMessageId': _replyingToMessageId,
//             'parentMessageText': _replyingToMessage?['text'],
//             'receiverName': _replyingToMessage?[
//                 'userName'], // Nom de l'utilisateur à qui on répond
//             'isEdited': false,
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Message envoyé')),
//           );
//         }
//         _messageController.clear();
//         setState(() {
//           _replyingToMessageId = null;
//           _replyingToMessage = null;
//           _pickedFile = null;
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur : $e')),
//         );
//       }
//     }
//   }

//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
//     );
//     if (result != null) {
//       setState(() {
//         _pickedFile = result.files.first;
//       });
//     }
//   }

//   void _startReply(Map<String, dynamic> message) {
//     setState(() {
//       _replyingToMessageId = message['id'];
//       _replyingToMessage = message;
//     });
//   }

//   void _cancelReply() {
//     setState(() {
//       _replyingToMessageId = null;
//       _replyingToMessage = null;
//     });
//   }

//   void _startEdit(Map<String, dynamic> message) {
//     setState(() {
//       _editingMessageId = message['id'];
//       _messageController.text = message['text'];
//     });
//   }

//   void _cancelEdit() {
//     setState(() {
//       _editingMessageId = null;
//       _messageController.clear();
//     });
//   }

//   Future<void> _deleteMessage(String messageId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('messages')
//           .doc(messageId)
//           .delete();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Message supprimé')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Erreur : $e')),
//       );
//     }
//   }

//   void _copyMessage(String text) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Message copié')),
//     );
//   }

//   Future<void> _openFile(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
//       );
//     }
//   }

//   void _showImageInFullScreen(String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           child: GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Image.network(
//               imageUrl,
//               fit: BoxFit.cover,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Message',
//           style: TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF9C27B0),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('messages')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Erreur : ${snapshot.error}'));
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final messages = snapshot.data?.docs ?? [];
//                 final currentUser = FirebaseAuth.instance.currentUser?.uid;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message =
//                         messages[index].data() as Map<String, dynamic>;
//                     final messageId = messages[index].id;
//                     final text = message['text'] ?? '';
//                     final fileUrl = message['fileUrl'] ?? '';
//                     final userId = message['userId'] ?? '';
//                     final createdAt = message['createdAt'] as Timestamp?;
//                     final updatedAt = message['updatedAt'] as Timestamp?;
//                     final userName = message['userName'] ?? 'Nom inconnu';
//                     final userProfileImage = message['userProfileImage'] ?? '';
//                     final time = createdAt != null
//                         ? '${createdAt.toDate().hour}:${createdAt.toDate().minute}'
//                         : 'Inconnu';
//                     final parentMessageId = message['parentMessageId'];
//                     final parentMessageText =
//                         message['parentMessageText'] ?? '';
//                     final receiverName = message['receiverName'] ?? '';
//                     final isEdited = message['isEdited'] ?? false;

//                     final isCurrentUser = currentUser == userId;

//                     return GestureDetector(
//                       onLongPress: () {
//                         if (isCurrentUser) {
//                           _startEdit({
//                             'id': messageId,
//                             'text': text,
//                           });
//                         }
//                       },
//                       child: Column(
//                         crossAxisAlignment: isCurrentUser
//                             ? CrossAxisAlignment.end
//                             : CrossAxisAlignment.start,
//                         children: [
//                           if (parentMessageId != null)
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 16.0, right: 16.0, top: 8.0),
//                               child: Container(
//                                 padding: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Réponse à $receiverName',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                     Text(
//                                       parentMessageText,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[800],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16.0, vertical: 4.0),
//                             child: Row(
//                               mainAxisAlignment: isCurrentUser
//                                   ? MainAxisAlignment.end
//                                   : MainAxisAlignment.start,
//                               children: [
//                                 if (!isCurrentUser)
//                                   CircleAvatar(
//                                     backgroundImage: userProfileImage.isNotEmpty
//                                         ? NetworkImage(userProfileImage)
//                                         : null,
//                                     child: userProfileImage.isEmpty
//                                         ? Text(
//                                             userName.isNotEmpty
//                                                 ? userName[0].toUpperCase()
//                                                 : 'U',
//                                             style: const TextStyle(
//                                               fontSize: 20,
//                                             ),
//                                           )
//                                         : null,
//                                   ),
//                                 const SizedBox(width: 8.0),
//                                 Container(
//                                   constraints: BoxConstraints(
//                                     maxWidth:
//                                         MediaQuery.of(context).size.width * 0.7,
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16.0, vertical: 10.0),
//                                   decoration: BoxDecoration(
//                                     color: isCurrentUser
//                                         ? Colors.purple[200]
//                                         : Colors.grey[200],
//                                     borderRadius: BorderRadius.circular(12.0),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       if (!isCurrentUser)
//                                         Text(
//                                           userName,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             color: const Color(0xFF9C27B0),
//                                           ),
//                                         ),
//                                       if (fileUrl.isNotEmpty)
//                                         fileUrl.endsWith('.jpg') ||
//                                                 fileUrl.endsWith('.png') ||
//                                                 fileUrl.endsWith('.jpeg')
//                                             ? GestureDetector(
//                                                 onTap: () =>
//                                                     _showImageInFullScreen(
//                                                         fileUrl),
//                                                 child: Image.network(
//                                                   fileUrl,
//                                                   width: 200,
//                                                   height: 200,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               )
//                                             : GestureDetector(
//                                                 onTap: () => _openFile(fileUrl),
//                                                 child: Container(
//                                                   padding:
//                                                       const EdgeInsets.all(8.0),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.teal[50],
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             8.0),
//                                                   ),
//                                                   child: const Row(
//                                                     children: [
//                                                       Icon(Icons
//                                                           .insert_drive_file),
//                                                       SizedBox(width: 8.0),
//                                                       Text(
//                                                         'Document',
//                                                         style: TextStyle(
//                                                           color:
//                                                               Color(0xFF9C27B0),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                       if (text.isNotEmpty) Text(text),
//                                       const SizedBox(height: 4.0),
//                                       Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Text(
//                                             time,
//                                             style: TextStyle(
//                                               fontSize: 10,
//                                               color: Colors.grey[600],
//                                             ),
//                                           ),
//                                           if (isEdited)
//                                             const Text(
//                                               ' (modifié)',
//                                               style: TextStyle(
//                                                 fontSize: 10,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (!isCurrentUser)
//                                   IconButton(
//                                     icon: const Icon(Icons.reply,
//                                         size: 20, color: Colors.grey),
//                                     onPressed: () => _startReply({
//                                       'id': messageId,
//                                       'text': text,
//                                       'userName': userName,
//                                       'userId': userId,
//                                     }),
//                                     tooltip: 'Répondre',
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           if (_replyingToMessage != null)
//             Container(
//               padding: const EdgeInsets.all(8.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.grey[300]!,
//                     width: 1.0,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, size: 20),
//                     onPressed: _cancelReply,
//                     tooltip: 'Annuler la réponse',
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Réponse à ${_replyingToMessage!['userName']}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         Text(
//                           _replyingToMessage!['text'],
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[800],
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.attach_file, color: Colors.purple),
//                   onPressed: _pickFile,
//                   tooltip: 'Joindre un fichier',
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: _editingMessageId != null
//                           ? 'Modifier le message'
//                           : 'Saisir un message',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24.0),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16.0, vertical: 12.0),
//                     ),
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 8.0),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.purple),
//                   onPressed: _sendMessage,
//                 ),
//                 if (_editingMessageId != null)
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.red),
//                     onPressed: _cancelEdit,
//                     tooltip: 'Annuler la modification',
//                   ),
//               ],
//             ),
//           ),
//           if (_pickedFile != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   const Icon(Icons.attach_file, color: Colors.purple),
//                   const SizedBox(width: 8.0),
//                   Text(
//                     _pickedFile!.name,
//                     style: TextStyle(
//                       color: const Color(0xFF9C27B0),
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.red),
//                     onPressed: () {
//                       setState(() {
//                         _pickedFile = null;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
