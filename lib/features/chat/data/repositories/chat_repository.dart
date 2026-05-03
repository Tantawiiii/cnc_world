import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _conversationsCollection = 'conversations';
  static const String _messagesCollection = 'messages';

  /// Generate a deterministic conversation ID between two users
  String _getConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Get or create a conversation between two users
  Future<String> getOrCreateConversation({
    required String myId,
    required String myName,
    String? myImage,
    required String otherId,
    required String otherName,
    String? otherImage,
  }) async {
    final convId = _getConversationId(myId, otherId);
    final docRef = _firestore.collection(_conversationsCollection).doc(convId);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'participantIds': [myId, otherId],
        'participantNames': {myId: myName, otherId: otherName},
        'participantImages': {myId: myImage, otherId: otherImage},
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': {myId: 0, otherId: 0},
        'hiddenBy': <String, dynamic>{},
      });
    } else {
      // Update names/images; clear my hide flag so the thread shows again for me
      await docRef.update({
        'participantNames.$myId': myName,
        'participantNames.$otherId': otherName,
        'participantImages.$myId': myImage,
        'participantImages.$otherId': otherImage,
        'hiddenBy.$myId': FieldValue.delete(),
      });
    }
    return convId;
  }

  Stream<List<ChatConversation>> getConversationsStream(String userId) {
    return _firestore
        .collection(_conversationsCollection)
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ChatConversation.fromFirestore(doc))
              .where((c) => !c.isHiddenForUser(userId))
              .toList();
          list.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return list;
        });
  }

  /// Hide conversation from this user's list only (other participant unchanged).
  Future<void> hideConversationForUser({
    required String conversationId,
    required String userId,
  }) async {
    await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .update({'hiddenBy.$userId': true});
  }

  /// Stream of messages in a conversation - realtime
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderImage,
    required String text,
    required String otherUserId,
  }) async {
    final batch = _firestore.batch();

    // Add message to subcollection
    final msgRef = _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .collection(_messagesCollection)
        .doc();

    batch.set(msgRef, {
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update conversation metadata
    final convRef = _firestore
        .collection(_conversationsCollection)
        .doc(conversationId);

    batch.update(convRef, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount.$otherUserId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Mark messages as read
  Future<void> markAsRead({
    required String conversationId,
    required String userId,
  }) async {
    await _firestore
        .collection(_conversationsCollection)
        .doc(conversationId)
        .update({'unreadCount.$userId': 0});
  }

  /// Get total unread count for a user (for badge)
  Stream<int> getTotalUnreadStream(String userId) {
    return _firestore
        .collection(_conversationsCollection)
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final hidden = data['hiddenBy'] as Map?;
            if (hidden?[userId] == true) continue;
            final unread = data['unreadCount'] as Map?;
            total += (unread?[userId] as num? ?? 0).toInt();
          }
          return total;
        });
  }
}
