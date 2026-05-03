import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constant/app_colors.dart';
import '../../shared/widgets/curved_bottom_nav_bar.dart';
import '../chat/cubit/chat_cubit.dart';
import '../chat/cubit/chat_state.dart';
import '../chat/data/repositories/chat_repository.dart';
import '../chat/ui/chat_conversations_screen.dart';
import '../contact/cubit/contact_cubit.dart';
import '../contact/data/repositories/contact_repository.dart';
import '../profile/cubit/profile_cubit.dart';
import '../profile/cubit/profile_state.dart';
import '../profile/data/repositories/profile_repository.dart';
import 'cubit/home_cubit.dart';
import 'ui/widgets/home_content_widget.dart';
import 'ui/widgets/contact_us_content_widget.dart';
import 'ui/widgets/complaint_content_widget.dart';
import 'ui/widgets/settings_content_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;
  late final HomeCubit _homeCubit;
  late final ContactCubit _contactCubit;
  late final ContactCubit _complaintCubit;
  late final ProfileCubit _profileCubit;
  late final ChatCubit _chatCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit()..loadSliders();
    _contactCubit = ContactCubit(ContactRepository());
    _complaintCubit = ContactCubit(ContactRepository());
    _profileCubit = ProfileCubit(ProfileRepository())..checkAuth();
    _chatCubit = ChatCubit(ChatRepository());

    // Initialise chat after profile loads
    _profileCubit.stream.listen((state) {
      if (state is ProfileLoaded) {
        _chatCubit.init(
          userId: state.profile.id.toString(),
          userName: state.profile.name,
          userImage: state.profile.imageUrl,
        );
      }
    });
  }

  @override
  void dispose() {
    _homeCubit.close();
    _contactCubit.close();
    _complaintCubit.close();
    _profileCubit.close();
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final textDirection =
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _chatCubit),
      ],
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.background, AppColors.backgroundLight],
              ),
            ),
            child: IndexedStack(
              index: _currentBottomNavIndex,
              children: [
                _buildHomeContent(),
                _buildChatContent(),
                _buildContactUsContent(),
                _buildComplaintContent(),
                _buildSettingsContent(),
              ],
            ),
          ),
          bottomNavigationBar: BlocBuilder<ChatCubit, ChatState>(
            bloc: _chatCubit,
            buildWhen: (p, c) => c is UnreadCountUpdated,
            builder: (context, state) {
              final unread = _chatCubit.unreadCount;
              return CurvedBottomNavBar(
                currentIndex: _currentBottomNavIndex,
                chatUnreadCount: unread,
                onTap: (index) {
                  setState(() => _currentBottomNavIndex = index);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return BlocProvider.value(
      value: _homeCubit,
      child: const HomeContentWidget(),
    );
  }

  Widget _buildChatContent() {
    return BlocProvider.value(
      value: _chatCubit,
      child: const ChatConversationsScreen(),
    );
  }

  Widget _buildContactUsContent() {
    return BlocProvider.value(
      value: _contactCubit,
      child: const ContactUsContentWidget(),
    );
  }

  Widget _buildComplaintContent() {
    return BlocProvider.value(
      value: _complaintCubit,
      child: const ComplaintContentWidget(),
    );
  }

  Widget _buildSettingsContent() {
    return BlocProvider.value(
      value: _profileCubit,
      child: const SettingsContentWidget(),
    );
  }
}
