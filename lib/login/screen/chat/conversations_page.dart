import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ConversationScreen extends StatefulWidget {
  final String businessId;
  final String userId;
  final String chatRoomId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  const ConversationScreen({
    super.key,
    required this.businessId,
    required this.userId,
    required this.chatRoomId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendMessage(
      {String? text, String? fileUrl, String? fileType}) async {
    if ((text?.isEmpty ?? true) && fileUrl == null) return;

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': text ?? '',
        'fileUrl': fileUrl,
        'fileType': fileType,
        'businessId': widget.businessId,
        'userId': widget.userId,
        'chatRoomId': widget.chatRoomId,
        'timestamp': FieldValue.serverTimestamp(),
        'isBusinessMessage': widget.userId == widget.businessId,
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        final file = File(image.path);
        final String fileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child('$fileName.jpg');

        await ref.putFile(file);
        final String downloadUrl = await ref.getDownloadURL();
        await _sendMessage(fileUrl: downloadUrl, fileType: 'image');
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final String fileName = result.files.single.name;
        final Reference ref =
            FirebaseStorage.instance.ref().child('chat_files').child(fileName);

        await ref.putFile(file);
        final String downloadUrl = await ref.getDownloadURL();
        await _sendMessage(
            fileUrl: downloadUrl, fileType: 'file', text: fileName);
      }
    } catch (e) {
      print('Error selecting file: $e');
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

  Stream<QuerySnapshot> _getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('chatRoomId', isEqualTo: widget.chatRoomId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isBusinessMessage =
                        message['isBusinessMessage'] ?? false;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? DateFormat('HH:mm').format(timestamp.toDate())
                        : '';

                    return Align(
                      alignment: isBusinessMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: isBusinessMessage ? 50 : 8,
                          right: isBusinessMessage ? 8 : 50,
                          bottom: 4,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isBusinessMessage
                              ? Colors.green[100]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: isBusinessMessage
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (message['fileType'] == 'image')
                              Image.network(message['fileUrl']),
                            if (message['text'] != null) Text(message['text']),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
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
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Write a message...',
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
