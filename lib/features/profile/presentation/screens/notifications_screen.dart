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
              : CustomSwitch(value: switchValue!, onChanged: onSwitchChanged!),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44.w,
        height: 26.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: value
              ? AppColors.brand500
              : AppColors.textPrimary.withOpacity(
                  0.05,
                ), // track color with 5% opacity
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.white, // circle color
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0x16330014,
                      ), // same as #16330014 in Flutter
                      offset: const Offset(0, 1), // x=0, y=1 (vertical)
                      blurRadius: 2, // blur radius
                      spreadRadius: 0, // spread radius
                    ),
                  ],
                ),
                child: value
                    ? Center(
                        child: Icon(
                          Icons.check,
                          color: AppColors.brand500,
                          size: 16.sp,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
