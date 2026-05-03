import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/firebase_auth_service.dart';
import '../data/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  final FirebaseAuthService _firebaseAuthService;

  StreamSubscription? _conversationsSub;
  StreamSubscription? _messagesSub;
  StreamSubscription? _unreadSub;

  String? _currentUserId;
  String? _currentUserName;
  String? _currentUserImage;
  int _unreadCount = 0;

  ChatCubit(this._repository)
      : _firebaseAuthService = di.sl<FirebaseAuthService>(),
        super(ChatInitial());

  int get unreadCount => _unreadCount;

  // ─── Initialise with logged-in user ─────────────────────────────────────────

  Future<void> init({
    required String userId,
    required String userName,
    String? userImage,
  }) async {
    _currentUserId = userId;
    _currentUserName = userName;
    _currentUserImage = userImage;
    if (await ensureReady()) {
      _listenToUnread();
      await listenToConversations();
    }
  }

  Future<bool> ensureReady() async {
    final uid = await _firebaseAuthService.ensureSignedIn();
    if (uid == null || uid.isEmpty) return false;
    _currentUserId ??= uid;
    return _currentUserName != null && _currentUserName!.trim().isNotEmpty;
  }

  // ─── Listen to all conversations ─────────────────────────────────────────────

  Future<void> listenToConversations() async {
    if (!await ensureReady() || _currentUserId == null) return;
    _conversationsSub?.cancel();
    emit(ConversationsLoading());
    _conversationsSub =
        _repository.getConversationsStream(_currentUserId!).listen(
      (conversations) {
        if (!isClosed) emit(ConversationsLoaded(conversations));
      },
      onError: (e) {
        if (!isClosed) emit(ConversationsError(e.toString()));
      },
    );
  }

  void stopListeningConversations() {
    _conversationsSub?.cancel();
    _conversationsSub = null;
  }

  // ─── Listen to messages in a conversation ────────────────────────────────────

  Future<void> listenToMessages(String conversationId) async {
    if (!await ensureReady()) return;
    _messagesSub?.cancel();
    emit(MessagesLoading());
    _messagesSub =
        _repository.getMessagesStream(conversationId).listen(
      (messages) {
        if (!isClosed) emit(MessagesLoaded(messages, conversationId));
      },
      onError: (e) {
        if (!isClosed) emit(MessagesError(e.toString()));
      },
    );

    // mark as read
    if (_currentUserId != null) {
      _repository.markAsRead(
          conversationId: conversationId, userId: _currentUserId!);
    }
  }

  void stopListeningMessages() {
    _messagesSub?.cancel();
    _messagesSub = null;
  }

  // ─── Open / create conversation then listen ───────────────────────────────────

  Future<String> openConversationWith({
    required String otherId,
    required String otherName,
    String? otherImage,
  }) async {
    if (_currentUserId == null || !await ensureReady()) return '';
    final convId = await _repository.getOrCreateConversation(
      myId: _currentUserId!,
      myName: _currentUserName!,
      myImage: _currentUserImage,
      otherId: otherId,
      otherName: otherName,
      otherImage: otherImage,
    );
    await listenToMessages(convId);
    return convId;
  }

  // ─── Send message ─────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String otherUserId,
  }) async {
    if (_currentUserId == null || !await ensureReady() || text.trim().isEmpty) {
      return;
    }
    try {
      await _repository.sendMessage(
        conversationId: conversationId,
        senderId: _currentUserId!,
        senderName: _currentUserName!,
        senderImage: _currentUserImage,
        text: text.trim(),
        otherUserId: otherUserId,
      );
    } catch (e) {
      if (!isClosed) emit(MessageSendError(e.toString()));
    }
  }

  // ─── Mark as read ─────────────────────────────────────────────────────────────

  Future<void> markAsRead(String conversationId) async {
    if (_currentUserId == null || !await ensureReady()) return;
    await _repository.markAsRead(
        conversationId: conversationId, userId: _currentUserId!);
  }

  /// Remove conversation from my list only (Firestore `hiddenBy`).
  Future<void> hideConversationForMe(String conversationId) async {
    if (_currentUserId == null || !await ensureReady()) return;
    await _repository.hideConversationForUser(
      conversationId: conversationId,
      userId: _currentUserId!,
    );
  }

  // ─── Unread badge ─────────────────────────────────────────────────────────────

  void _listenToUnread() {
    if (_currentUserId == null) return;
    _unreadSub?.cancel();
    _unreadSub =
        _repository.getTotalUnreadStream(_currentUserId!).listen((count) {
      _unreadCount = count;
      if (!isClosed) emit(UnreadCountUpdated(count));
    });
  }

  String? get currentUserId => _currentUserId;

  @override
  Future<void> close() {
    _conversationsSub?.cancel();
    _messagesSub?.cancel();
    _unreadSub?.cancel();
    return super.close();
  }
}
