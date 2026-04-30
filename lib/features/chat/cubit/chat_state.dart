import 'package:equatable/equatable.dart';
import '../data/models/chat_models.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

// ─── Conversations List States ───────────────────────────────────────────────

class ConversationsLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ChatConversation> conversations;
  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationsError extends ChatState {
  final String message;
  const ConversationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Messages States ─────────────────────────────────────────────────────────

class MessagesLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String conversationId;
  const MessagesLoaded(this.messages, this.conversationId);

  @override
  List<Object?> get props => [messages, conversationId];
}

class MessagesError extends ChatState {
  final String message;
  const MessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Sending State ────────────────────────────────────────────────────────────

class MessageSending extends ChatState {}

class MessageSent extends ChatState {}

class MessageSendError extends ChatState {
  final String message;
  const MessageSendError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Unread Badge ─────────────────────────────────────────────────────────────

class UnreadCountUpdated extends ChatState {
  final int count;
  const UnreadCountUpdated(this.count);

  @override
  List<Object?> get props => [count];
}
