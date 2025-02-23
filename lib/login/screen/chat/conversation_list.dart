import 'package:appointy/login/screen/chat/conversations_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationList extends StatelessWidget {
  final String businessId;
  final String userId;

  const ConversationList({
    super.key,
    required this.businessId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('conversations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('An error occurred. Please try again later.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data?.docs ?? [];

          if (conversations.isEmpty) {
            return const Center(child: Text('No conversations found.'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation =
                  conversations[index].data() as Map<String, dynamic>;
              final chatRoomId =
                  conversation['chatRoomId'] ?? 'Unknown ChatRoom';
              final receiverName =
                  conversation['receiverName'] ?? 'Unknown Receiver';
              final receiverId = conversation['receiverId'] ?? '';
              final receiverImage = conversation['receiverImage'] ?? '';

              return ListTile(
                title: Text(receiverName),
                subtitle: Text('Chat Room: $chatRoomId'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                        businessId: businessId,
                        userId: userId,
                        chatRoomId: chatRoomId,
                        receiverId: receiverId,
                        receiverName: receiverName,
                        receiverImage: receiverImage,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
