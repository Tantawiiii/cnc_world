import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderImage: data['senderImage'],
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'senderImage': senderImage,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': isRead,
      };
}

class ChatConversation {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantImages;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;
  /// User ids who hid this thread for themselves only (not deleted for others).
  final Map<String, bool> hiddenByUser;

  const ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantImages,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.hiddenByUser = const {},
  });

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatConversation(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantImages: Map<String, String?>.from(
          (data['participantImages'] as Map?)
                  ?.map((k, v) => MapEntry(k.toString(), v?.toString())) ??
              {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime:
          (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(
          (data['unreadCount'] as Map?)
                  ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
              {}),
      hiddenByUser: _parseHiddenBy(data['hiddenBy']),
    );
  }

  static Map<String, bool> _parseHiddenBy(dynamic raw) {
    if (raw is! Map) return {};
    final m = <String, bool>{};
    raw.forEach((k, v) {
      if (v == true) m[k.toString()] = true;
    });
    return m;
  }

  bool isHiddenForUser(String userId) => hiddenByUser[userId] == true;

  /// Get the other participant's id (not current user)
  String getOtherUserId(String myId) =>
      participantIds.firstWhere((id) => id != myId, orElse: () => '');

  String getOtherUserName(String myId) =>
      participantNames[getOtherUserId(myId)] ?? '';

  String? getOtherUserImage(String myId) =>
      participantImages[getOtherUserId(myId)];

  int getMyUnread(String myId) => unreadCount[myId] ?? 0;
}
