import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final ChatService chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Messages'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUserChats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text('No conversations yet.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54))),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(chat['participants'] ?? []);
              final String otherUserId = participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox.shrink();
                  
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                  final String otherUserName = userData['name'] ?? 'User';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                      child: Text(otherUserName[0].toUpperCase(), style: TextStyle(color: Color(0xFFFF6B6B))),
                    ),
                    title: Text(otherUserName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      chat['lastMessage'] ?? '...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xFF999999)),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: otherUserId,
                            receiverName: otherUserName,
                          ),
                        ),
                      );
                    },
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
