import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../data/chat_api_service.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatFirestoreService _firestoreService = ChatFirestoreService();

  Map<String, List<ChatSessionModel>> _groupChatHistoryByDate(
    List<ChatSessionModel> items,
  ) {
    final now = DateTime.now();
    final currentYear = now.year;
    final lastYear = currentYear - 1;

    final Map<String, List<ChatSessionModel>> groups = {};

    for (final item in items) {
      final year = item.lastMessageTime.year;
      String label;

      if (year == currentYear) {
        label = 'Recent History';
      } else if (year == lastYear) {
        label = 'Last Year';
      } else {
        label = '$year';
      }

      groups.putIfAbsent(label, () => []).add(item);
    }

    final sortedKeys = <String>[];
    if (groups.containsKey('Recent History')) sortedKeys.add('Recent History');
    if (groups.containsKey('Last Year')) sortedKeys.add('Last Year');

    final olderYears =
        groups.keys
            .where((k) => k != 'Recent History' && k != 'Last Year')
            .map((k) => int.tryParse(k) ?? 0)
            .where((y) => y > 0)
            .toList()
          ..sort((a, b) => b.compareTo(a));

    sortedKeys.addAll(olderYears.map((y) => '$y'));

    return {for (final key in sortedKeys) key: groups[key]!};
  }

  String _formatSubtitle(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months ${months == 1 ? "month" : "months"} ago';
    } else {
      return DateFormat('MMMM yyyy').format(time);
    }
  }

  Future<void> _deleteChat(int chatId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteChatSession(chatId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Chat deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Chat History'),
      body: StreamBuilder<List<ChatSessionModel>>(
        stream: _firestoreService.getChatSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          final grouped = _groupChatHistoryByDate(sessions);

          return ListView.builder(
            padding: EdgeInsets.only(
              top: 20.0.h,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            itemCount: grouped.length,
            itemBuilder: (context, groupIndex) {
              final label = grouped.keys.elementAt(groupIndex);
              final items = grouped[label]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  ...List.generate(items.length, (index) {
                    final isLast = index == items.length - 1;
                    return _buildHistoryCard(items[index], showBorder: !isLast);
                  }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w), // spacing from sides
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () => context.push('/new-chat'), // navigate to new chat
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 24.r, color: Colors.white),
                SizedBox(width: 8.w),

                Text(
                  'New Chat',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ChatSessionModel item, {required bool showBorder}) {
    return GestureDetector(
      onTap: () {
        // Navigate to chat screen with chatId using extra
        context.push('/chat', extra: item.chatId);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 0.w),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: AppColors.textSecondary.withOpacity(0.05),
                    width: 1.w,
                  ),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/gemini-chat.png',
              width: 35.w,
              height: 35.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatSubtitle(item.lastMessageTime),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.textPrimary.withOpacity(0.8),
                size: 20.sp,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteChat(item.chatId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/svg/empty.svg',
              width: 80.w,
              height: 80.w,
            ),
            SizedBox(height: 24.h),
            Text(
              'No chat history yet',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'Your conversations will appear here once you start chatting with your AI Tutor.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
