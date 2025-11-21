import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isNotification1 = true;
  bool _isNotification2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Notifications'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            _buildNotificationItem(
              title: 'Push Notifications',
              subtitle: 'Receive app notification',
              switchValue: _isNotification1,
              onSwitchChanged: (value) {
                setState(() {
                  _isNotification1 = value;
                });
              },
            ),
            Divider(color: AppColors.neutral50, thickness: 1.w, height: 1.h),
            _buildNotificationItem(
              title: 'Goal Reminders',
              subtitle: 'Track monthly goal progress',
              switchValue: _isNotification2,
              onSwitchChanged: (value) {
                setState(() {
                  _isNotification2 = value;
                });
              },
            ),
            Divider(color: AppColors.neutral50, thickness: 1.w, height: 1.h),
            _buildNotificationItem(
              title: 'Everyday',
              subtitle: '',
              isTimeItem: true,
              time: '10:45 AM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    String? subtitle,
    bool? switchValue,
    ValueChanged<bool>? onSwitchChanged,
    bool isTimeItem = false,
    String? time,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: subtitle == null || subtitle.isEmpty
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          isTimeItem
              ? Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/reminder.svg',
                      width: 16.sp,
                      height: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      time ?? '',
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Switch(
                  value: switchValue ?? false,
                  onChanged: onSwitchChanged,
                  activeColor: AppColors.brand500,
                ),
        ],
      ),
    );
  }
}
