import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_texts.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../data/models/chat_models.dart';
import 'chat_detail_screen.dart';

class ChatConversationsScreen extends StatefulWidget {
  const ChatConversationsScreen({super.key});

  @override
  State<ChatConversationsScreen> createState() =>
      _ChatConversationsScreenState();
}

class _ChatConversationsScreenState extends State<ChatConversationsScreen>
    with AutomaticKeepAliveClientMixin {
  late final ChatCubit _chatCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    _chatCubit.listenToConversations();
  }

  @override
  void dispose() {
    _chatCubit.stopListeningConversations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 110.h,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.backgroundLight],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.chat_rounded,
                        color: AppColors.textOnPrimary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    AppTexts.conversations,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen: (p, c) =>
          c is ConversationsLoading ||
          c is ConversationsLoaded ||
          c is ConversationsError,
      builder: (context, state) {
        if (state is ConversationsLoading) {
          return SizedBox(
            height: 400.h,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is ConversationsError) {
          return SizedBox(
            height: 400.h,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 50.sp, color: AppColors.textTertiary),
                  SizedBox(height: 12.h),
                  Text(state.message,
                      style: TextStyle(
                          fontSize: 14.sp, color: AppColors.textSecondary,)),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<ChatCubit>().listenToConversations(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(AppTexts.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is ConversationsLoaded) {
          if (state.conversations.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: state.conversations
                .map((c) => _buildConversationTile(c))
                .toList(),
          );
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_bubble_outline_rounded,
                  size: 56.sp, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(
              AppTexts.noConversationsYet,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                AppTexts.startConversationHint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ChatConversation conversation) {
    final myId = context.read<ChatCubit>().currentUserId ?? '';
    final otherName = conversation.getOtherUserName(myId);
    final otherImage = conversation.getOtherUserImage(myId);
    final otherId = conversation.getOtherUserId(myId);
    final unread = conversation.getMyUnread(myId);
    final isToday = _isSameDay(conversation.lastMessageTime, DateTime.now());
    final timeStr = isToday
        ? DateFormat('hh:mm a', 'ar').format(conversation.lastMessageTime)
        : DateFormat('dd/MM', 'ar').format(conversation.lastMessageTime);

    return GestureDetector(
      onTap: () => _openChat(
        conversationId: conversation.id,
        otherId: otherId,
        otherName: otherName,
        otherImage: otherImage,
      ),
      onLongPress: () => _confirmHideConversation(context, conversation.id),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAvatar(otherImage, otherName, 50.r),
                if (unread > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.surface, width: 1.5),
                      ),
                      constraints:
                          BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textOnPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: unread > 0
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: unread > 0
                              ? AppColors.primaryDark
                              : AppColors.textTertiary,
                          fontWeight: unread > 0
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    conversation.lastMessage.isEmpty
                        ? AppTexts.startConversationPlaceholder
                        : conversation.lastMessage,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: unread > 0
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      fontWeight: unread > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmHideConversation(
    BuildContext context,
    String conversationId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppTexts.deleteChatTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          AppTexts.deleteChatMessage,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              AppTexts.cancel,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15.sp),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppTexts.deleteChatConfirm,
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<ChatCubit>().hideConversationForMe(conversationId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppTexts.deleteChatError}: $e')),
      );
    }
  }

  void _openChat({
    required String conversationId,
    required String otherId,
    required String otherName,
    String? otherImage,
  }) {
    context.read<ChatCubit>().markAsRead(conversationId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ChatCubit>(),
          child: ChatDetailScreen(
            conversationId: conversationId,
            otherUserId: otherId,
            otherUserName: otherName,
            otherUserImage: otherImage,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, String name, double size) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: CachedNetworkImageProvider(imageUrl),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
