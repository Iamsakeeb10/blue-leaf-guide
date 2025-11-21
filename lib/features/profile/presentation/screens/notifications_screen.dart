import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isNotification1 = true;
  bool _isNotification2 = false;

  void _openCustomTimePicker(BuildContext context) {
    int selectedHour = 9;
    int selectedMinute = 0;
    String selectedPeriod = "AM";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            height: 300.h,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              children: [
                Text(
                  "Get Reminder",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 12.h),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),

                    // ⭐ No padding → makes background seamless
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// HOUR PICKER
                        SizedBox(
                          width: 60.w,
                          child: CupertinoPicker(
                            itemExtent: 32.h,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedHour - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              selectedHour = index + 1;
                            },
                            children: List.generate(12, (i) {
                              final hour = i + 1;
                              return Center(
                                child: Text(
                                  hour.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        /// Colon
                        Text(
                          ":",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        /// MINUTE PICKER
                        SizedBox(
                          width: 60.w,
                          child: CupertinoPicker(
                            itemExtent: 32.h,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMinute,
                            ),
                            onSelectedItemChanged: (index) {
                              selectedMinute = index;
                            },
                            children: List.generate(60, (i) {
                              return Center(
                                child: Text(
                                  i.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        /// AM/PM PICKER
                        SizedBox(
                          width: 60.w,
                          child: CupertinoPicker(
                            itemExtent: 32.h,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedPeriod == "AM" ? 0 : 1,
                            ),
                            onSelectedItemChanged: (index) {
                              selectedPeriod = index == 0 ? "AM" : "PM";
                            },
                            children: const [
                              Center(child: Text("AM")),
                              Center(child: Text("PM")),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
                  child: Column(
                    children: [
                      Button(
                        onPressed: () {
                          final formattedTime =
                              "$selectedHour:${selectedMinute.toString().padLeft(2, '0')} $selectedPeriod";

                          setState(() {
                            // _selectedTime = formattedTime;  <-- your logic
                          });

                          Navigator.pop(context);
                        },
                        text: 'Save',
                        height: 54.h,
                        borderRadius: BorderRadius.circular(32.r),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        textColor: Colors.white,
                        backgroundColor: AppColors.brand500,
                      ),

                      SizedBox(height: 12.h),

                      // CANCEL Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textPrimary.withOpacity(0.5),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
              ? GestureDetector(
                  onTap: () {
                    _openCustomTimePicker(context);
                  },
                  child: Row(
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
                  ),
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
