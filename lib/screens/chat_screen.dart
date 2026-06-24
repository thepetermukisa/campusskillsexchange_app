import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _chatService.sendMessage(
      _currentUserId,
      widget.receiverId,
      _messageController.text.trim(),
    );
    _messageController.clear();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: widget.receiverId),
              ),
            );
          },
          child: Row(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(widget.receiverId).get(),
                builder: (context, snapshot) {
                  String? profileImageUrl;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    profileImageUrl = data['profileImageUrl'];
                  }
                  return CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFFF6B6B),
                    backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: (profileImageUrl == null || profileImageUrl.isEmpty)
                        ? Text(
                            widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : '?',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        : null,
                  );
                },
              ),
              SizedBox(width: 12),
              Text(widget.receiverName),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(_currentUserId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
                }
                
                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return Center(child: Text('No messages yet. Say hi!'));
                }

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 4, bottom: 2),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFFFF6B6B) : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
                            child: Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color!.withValues(alpha: 0.54), fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFFFF6B6B),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
