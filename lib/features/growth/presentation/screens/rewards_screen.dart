import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Progress & Rewards'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // Stats Cards Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: '🔥',
                      title: 'Current Streak',
                      value: '5 days',
                      backgroundColor: AppColors.backgroundLight,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: '🎯',
                      title: 'Goal Completed',
                      value: '3 months',
                      backgroundColor: AppColors.brand50,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: '✓',
                      title: 'Brand Build',
                      value: 'Completed',
                      backgroundColor: AppColors.backgroundGreenLight,
                      iconColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: '👥',
                      title: 'Client Served',
                      value: '15',
                      backgroundColor: AppColors.backgroundPurpleLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            // Goal Completion Rate Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(0.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Goal completion rate',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.textPrimary.withOpacity(0.05),
                          ),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Monthly',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16.sp,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Average goal completion rate',
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '58.3%',
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.8),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildBarChart(),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            // Task Completion Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task completion',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      _buildDropdown('November'),
                      SizedBox(width: 8.w),
                      _buildDropdown('2025'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Task Items
            _buildTaskItem(
              title: 'Distribute business cards',
              progress: 0.4,
              completed: 20,
              target: 50,
              targetColor: const Color(0xFFFF6B35),
            ),
            SizedBox(height: 12.h),
            _buildTaskItem(
              title: 'Total client served',
              progress: 0.5,
              completed: 5,
              target: 10,
              targetColor: const Color(0xFF10B981),
              subtitle: 'Acquired',
            ),
            SizedBox(height: 12.h),
            _buildTaskItem(
              title: 'Post on social media',
              progress: 0.5,
              completed: 5,
              target: 10,
              targetColor: const Color(0xFFFF6B35),
              subtitle: 'Posted',
            ),
            SizedBox(height: 12.h),
            _buildTaskItem(
              title: 'Attend hair show or class',
              progress: 0.0,
              completed: 0,
              target: 5,
              targetColor: const Color(0xFF10B981),
              subtitle: 'Attended',
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          if (iconColor != null)
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 24.sp),
            )
          else
            Text(icon, style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final values = [0.75, 0.0, 0.42, 1.0, 0.0, 0.32, 0.65];

    return SizedBox(
      height: 180.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAxisLabel('100%'),
              _buildAxisLabel('75%'),
              _buildAxisLabel('50%'),
              _buildAxisLabel('25%'),
              _buildAxisLabel('0%'),
            ],
          ),
          SizedBox(width: 12.w),
          // Bars
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 16.w,
                          height: 150.h * values[index],
                          decoration: BoxDecoration(color: AppColors.brand500),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          months[index],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDropdown(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.textPrimary.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down, size: 16.sp, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required double progress,
    required int completed,
    required int target,
    required Color targetColor,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: targetColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Target $target',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.more_vert, color: Colors.grey[600], size: 20.sp),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2B6EF6),
              ),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$completed ${subtitle ?? "distributed"}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
