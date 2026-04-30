import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../cubit/chat_cubit.dart';

import '../data/repositories/chat_repository.dart';
import 'chat_detail_screen.dart';




class ChatButton extends StatefulWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserImage;


  final bool fab;

  const ChatButton({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserImage,
    this.fab = false,
  });

  @override
  State<ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<ChatButton>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _animCtrl;
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _openChat() async {
    if (_loading) return;
    final cubit = context.read<ChatCubit>();
    await cubit.ensureReady();
    if (!mounted) return;

    final myId = cubit.currentUserId;
    if (myId == null || myId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يجب تسجيل الدخول أولاً'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
      return;
    }

    if (myId == widget.targetUserId) return;

    await _animCtrl.reverse();
    _animCtrl.forward();

    setState(() => _loading = true);

    try {
      final convId = await cubit.openConversationWith(
        otherId: widget.targetUserId,
        otherName: widget.targetUserName,
        otherImage: widget.targetUserImage,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => BlocProvider.value(
            value: cubit,
            child: ChatDetailScreen(
              conversationId: convId,
              otherUserId: widget.targetUserId,
              otherUserName: widget.targetUserName,
              otherUserImage: widget.targetUserImage,
            ),
          ),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            );
          },
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: widget.fab ? _buildFab() : _buildIconButton(),
    );
  }

  Widget _buildIconButton() {
    return GestureDetector(
      onTap: _openChat,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _loading
            ? Padding(
                padding: EdgeInsets.all(9.r),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Icon(
                Icons.chat_bubble_rounded,
                size: 17.sp,
                color: AppColors.textOnPrimary,
              ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _openChat,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _loading
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_rounded,
                      size: 16.sp, color: AppColors.textOnPrimary),
                  SizedBox(width: 6.w),
                  Text(
                    'مراسلة',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

}

class StandaloneChatButton extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;
  final String? targetUserImage;
  final bool fab;

  const StandaloneChatButton({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserImage,
    this.fab = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<ChatCubit>();
      return ChatButton(
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        targetUserImage: targetUserImage,
        fab: fab,
      );
    } catch (_) {
      return BlocProvider(
        create: (_) {
          final cubit = ChatCubit(ChatRepository());
          try {
            final userDataMap = di.sl<StorageService>().getUserData();
            if (userDataMap != null) {
              final id = userDataMap['id']?.toString() ?? '';
              final name = userDataMap['name']?.toString() ?? '';
              final imageUrl = userDataMap['imageUrl']?.toString() ?? '';
              cubit.init(
                userId: id,
                userName: name,
                userImage: imageUrl,
              );
            }
          } catch (_) {}
          return cubit;
        },
        child: ChatButton(
          targetUserId: targetUserId,
          targetUserName: targetUserName,
          targetUserImage: targetUserImage,
          fab: fab,
        ),
      );
    }
  }
}