import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/core/widgets/app_search_bar.dart';
import 'package:rom_tracker_app/core/widgets/app_user_header.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_store.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_thread.dart';
import 'package:rom_tracker_app/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:rom_tracker_app/features/home/presentation/pages/main_layout.dart';
import 'package:rom_tracker_app/features/notifications/presentation/pages/notifications_page.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_data.dart';
import 'package:rom_tracker_app/features/user_profile/presentation/models/user_profile_store.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({
    super.key,
    required this.userType,
  });

  final String userType;

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ChatStore.ensureSeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ValueListenableBuilder<UserProfileData>(
          valueListenable: UserProfileStore.notifierFor(widget.userType),
          builder: (context, profile, _) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  AppUserHeader(
                    avatarPath: profile.avatarPath,
                    title: profile.fullName,
                    notificationUserType: widget.userType,
                    onProfileTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainLayout(
                            userType: widget.userType,
                            initialIndex: 3,
                          ),
                        ),
                      );
                    },
                    onNotificationTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationsPage(
                            userType: widget.userType,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 18.h),
                  AppSearchBar(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Messages',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: ValueListenableBuilder<List<ChatThread>>(
                      valueListenable: ChatStore.threadsFor(widget.userType),
                      builder: (context, chats, _) {
                        final filtered = _filterChats(chats);
                        if (filtered.isEmpty) {
                          return Center(
                            child: Text(
                              'No conversations found.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: 6.h),
                          itemBuilder: (context, index) {
                            final chat = filtered[index];
                            return ListTile(
                              onTap: () {
                                ChatStore.markRead(widget.userType, chat.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailPage(
                                      userType: widget.userType,
                                      threadId: chat.id,
                                    ),
                                  ),
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: Stack(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      chat.avatarPath,
                                      width: 46.w,
                                      height: 46.w,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (chat.isOnline)
                                    Positioned(
                                      right: 2,
                                      bottom: 2,
                                      child: Container(
                                        width: 12.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF22C55E),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        chat.lastTime,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      chat.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  if (chat.unreadCount > 0)
                                    Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${chat.unreadCount}',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  else if (chat.isRead)
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<ChatThread> _filterChats(List<ChatThread> chats) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return chats;
    return chats.where((chat) {
      return chat.name.toLowerCase().contains(query) ||
          chat.subtitle.toLowerCase().contains(query) ||
          chat.lastMessage.toLowerCase().contains(query);
    }).toList();
  }
}
