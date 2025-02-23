// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:video_player/video_player.dart';
// import 'package:file_picker/file_picker.dart';

// class ConversationScreen2 extends StatefulWidget {
//   final String businessId;
//   final String userId;
//   final String chatRoomId;

//   const ConversationScreen2({
//     super.key,
//     required this.businessId,
//     required this.userId,
//     required this.chatRoomId,
//   });

//   @override
//   State<ConversationScreen2> createState() => _ConversationScreenState();
// }

// class _ConversationScreenState extends State<ConversationScreen2> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final ImagePicker _picker = ImagePicker();
//   final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isRecording = false;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAudioRecorder();
//   }

//   @override
//   void dispose() {
//     _audioRecorder.closeRecorder();
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   void _initializeAudioRecorder() async {
//     try {
//       await _audioRecorder.openRecorder();
//     } catch (e) {
//       debugPrint("Audio recorder initialization error: $e");
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile != null) {
//         final downloadUrl =
//             await _uploadFile(File(pickedFile.path), 'chat_images');
//         _sendMessage(fileUrl: downloadUrl, fileType: 'image');
//       }
//     } catch (e) {
//       debugPrint("Image selection error: $e");
//     }
//   }

//   Future<void> _pickFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles();
//       if (result != null && result.files.single.path != null) {
//         final downloadUrl =
//             await _uploadFile(File(result.files.single.path!), 'chat_files');
//         _sendMessage(fileUrl: downloadUrl, fileType: 'file');
//       }
//     } catch (e) {
//       debugPrint("File selection error: $e");
//     }
//   }

//   Future<String> _uploadFile(File file, String folder) async {
//     final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     final Reference ref =
//         FirebaseStorage.instance.ref().child(folder).child(fileName);
//     await ref.putFile(file);
//     return await ref.getDownloadURL();
//   }

//   void _startRecording() async {
//     try {
//       final filePath = '${DateTime.now().millisecondsSinceEpoch}.aac';
//       await _audioRecorder.startRecorder(toFile: filePath);
//       setState(() => _isRecording = true);
//     } catch (e) {
//       debugPrint("Start recording error: $e");
//     }
//   }

//   void _stopRecording() async {
//     try {
//       final filePath = await _audioRecorder.stopRecorder();
//       setState(() => _isRecording = false);
//       if (filePath != null) {
//         final downloadUrl = await _uploadFile(File(filePath), 'chat_audio');
//         _sendMessage(fileUrl: downloadUrl, fileType: 'audio');
//       }
//     } catch (e) {
//       debugPrint("Stop recording error: $e");
//     }
//   }

//   void _sendMessage({String? text, String? fileUrl, String? fileType}) async {
//     if ((text?.isEmpty ?? true) && fileUrl == null) return;

//     try {
//       await _firestore.collection('messages').add({
//         'text': text ?? '',
//         'fileUrl': fileUrl,
//         'fileType': fileType,
//         'businessId': widget.businessId,
//         'userId': widget.userId,
//         'chatRoomId': widget.chatRoomId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       _messageController.clear();
//       _scrollToBottom();
//     } catch (e) {
//       debugPrint("Send message error: $e");
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Widget _buildMessageBubble(Map<String, dynamic> message, bool isCurrentUser) {
//     return Align(
//       alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: isCurrentUser ? Colors.blueAccent : Colors.grey[200],
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(isCurrentUser ? 12 : 0),
//             topRight: Radius.circular(isCurrentUser ? 0 : 12),
//             bottomLeft: const Radius.circular(12),
//             bottomRight: const Radius.circular(12),
//           ),
//         ),
//         child: message['fileUrl'] != null
//             ? _buildMediaContent(message)
//             : Text(
//                 message['text'] ?? '',
//                 style: TextStyle(
//                   color: isCurrentUser ? Colors.white : Colors.black,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildMediaContent(Map<String, dynamic> message) {
//     switch (message['fileType']) {
//       case 'image':
//         return Image.network(
//           message['fileUrl'],
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) =>
//               const Icon(Icons.broken_image),
//         );
//       case 'audio':
//         return GestureDetector(
//           onTap: () async {
//             try {
//               await _audioPlayer.setUrl(message['fileUrl']);
//               await _audioPlayer.play();
//             } catch (e) {
//               debugPrint("Audio playback error: $e");
//             }
//           },
//           child: Row(
//             children: [
//               const Icon(Icons.play_arrow),
//               const SizedBox(width: 8),
//               Text('Audio message'),
//             ],
//           ),
//         );
//       default:
//         return Text('Unsupported file type');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text('Chat Room'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection('messages')
//                   .where('chatRoomId', isEqualTo: widget.chatRoomId)
//                   .orderBy('timestamp', descending: false)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final messages = snapshot.data?.docs ?? [];
//                 return ListView.builder(
//                   controller: _scrollController,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message =
//                         messages[index].data() as Map<String, dynamic>;
//                     final isCurrentUser = message['userId'] == widget.userId;
//                     return _buildMessageBubble(message, isCurrentUser);
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.photo),
//                   onPressed: () {
//                     _pickImage(ImageSource.gallery);
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   onPressed: _pickFile,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     final message = _messageController.text.trim();
//                     if (message.isNotEmpty) {
//                       _sendMessage(text: message);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
