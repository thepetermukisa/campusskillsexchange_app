import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send Message
  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    final String chatId = getChatId(senderId, receiverId);
    
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in chat document for chat list view
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [senderId, receiverId],
    }, SetOptions(merge: true));
  }

  // Get Messages Stream
  Stream<List<ChatMessage>> getMessages(String senderId, String receiverId) {
    final String chatId = getChatId(senderId, receiverId);
    
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Helper to generate a consistent chat ID between two users
  String getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  // Get User Chats Stream
  Stream<List<Map<String, dynamic>>> getUserChats(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }
}
