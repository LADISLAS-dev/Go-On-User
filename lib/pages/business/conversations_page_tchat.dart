import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rxdart/rxdart.dart';

class ConversationScreen2 extends StatefulWidget {
  final String businessId;
  final String userId;

  const ConversationScreen2({
    super.key,
    required this.businessId,
    required this.userId, required String chatRoomId, required String receiverId, required String receiverName, required String receiverImage,
  });

  @override
  State<ConversationScreen2> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen2> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendMessage({String? text, String? fileUrl, String? fileType}) async {
    if ((text?.isEmpty ?? true) && fileUrl == null) return;

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': text ?? '',
        'fileUrl': fileUrl,
        'fileType': fileType,
        'businessId': widget.businessId,
        'userId': widget.userId,
        'timestamp': FieldValue.serverTimestamp(),
        'isBusinessMessage': widget.userId == widget.businessId,
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Erreur envoi message: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final file = File(image.path);
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final Reference ref =
            FirebaseStorage.instance.ref().child('chat_images').child('$fileName.jpg');

        await ref.putFile(file);
        final String downloadUrl = await ref.getDownloadURL();
        await _sendMessage(fileUrl: downloadUrl, fileType: 'image');
      }
    } catch (e) {
      print('Erreur sélection image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final String fileName = result.files.single.name;
        final Reference ref = FirebaseStorage.instance.ref().child('chat_files').child(fileName);

        await ref.putFile(file);
        final String downloadUrl = await ref.getDownloadURL();
        await _sendMessage(fileUrl: downloadUrl, fileType: 'file', text: fileName);
      }
    } catch (e) {
      print('Erreur sélection fichier: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Stream<List<QuerySnapshot>> _getMessagesStream() {
    final userMessages = FirebaseFirestore.instance
        .collection('messages')
        .where('businessId', isEqualTo: widget.businessId)
        .where('userId', isEqualTo: widget.userId)
        .orderBy('timestamp', descending: false)
        .snapshots();

    final globalMessages = FirebaseFirestore.instance
        .collection('messages')
        .where('businessId', isEqualTo: widget.businessId)
        .where('userId', isNull: true)
        .orderBy('timestamp', descending: false)
        .snapshots();

    return Rx.combineLatest2(
      userMessages,
      globalMessages,
      (QuerySnapshot userSnapshot, QuerySnapshot globalSnapshot) =>
          [userSnapshot, globalSnapshot],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QuerySnapshot>>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userMessages = snapshot.data?[0].docs ?? [];
                final globalMessages = snapshot.data?[1].docs ?? [];
                final allMessages = [...userMessages, ...globalMessages]
                  ..sort((a, b) {
                    final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                    final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                    return aTime.compareTo(bTime);
                  });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: allMessages.length,
                  itemBuilder: (context, index) {
                    final message = allMessages[index].data() as Map<String, dynamic>? ?? {};
                    final isBusinessMessage = message['isBusinessMessage'] ?? false;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? DateFormat('HH:mm').format(timestamp.toDate())
                        : '';

                    return Align(
                      alignment:
                          isBusinessMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: isBusinessMessage ? 50 : 8,
                          right: isBusinessMessage ? 8 : 50,
                          bottom: 4,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isBusinessMessage ? Colors.green[100] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isBusinessMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(message['text'] ?? ''),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(text: _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
