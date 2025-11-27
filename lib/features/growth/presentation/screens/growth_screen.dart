import 'package:blue_leaf_guide/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';
import '../../../../shared/widgets/dual_radial_gradient_painter.dart';

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTitleSubtitleAppbar(
        title: 'Growth',
        subtitle: 'Develop your brand and mindset',
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21.5.r),
                child: CustomPaint(
                  painter: DualRadialGradientPainter(),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(21.5.r),
                      border: Border.all(
                        color: AppColors.textPrimary.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/svg/star.svg',
                                width: 16.sp,
                                height: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'AFFIRMATION OF THE DAY',
                                style: TextStyle(
                                  color: AppColors.brand500,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300.w),
                          child: Text(
                            'You are mastering your craft building your future',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Growth Areas Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Growth Areas',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Brand Builder Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: Column(
                children: [
                  _buildGrowthCard(
                    icon: Icons.account_balance,
                    title: 'Brand Builder',
                    subtitle: 'Create your professional identity',
                    progress: 0.5,
                    showProgress: true,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 72.w,
                      ), // 16 (padding) + 44 (icon container) + 12 (spacing)
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '50%',
                                  style: TextStyle(
                                    color: const Color(0xFF2B6EF6),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: LinearProgressIndicator(
                                value: 0.5,
                                backgroundColor: const Color(0xFFE0E0E0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2B6EF6),
                                ),
                                minHeight: 6.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 24.w,
                      ), // 12 (spacing) + 24 (chevron) + 16 (padding)
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Progress & Rewards Card
            _buildGrowthCard(
              icon: Icons.emoji_events,
              title: 'Progress & Rewards',
              subtitle: 'Track achievement & celebrate wins',
            ),
            SizedBox(height: 12.h),
            // Learning Guides Card
            _buildGrowthCard(
              icon: Icons.menu_book,
              title: 'Learning Guides',
              subtitle: 'Tutorials, tips, and industry insights',
              badge: 'Coming Soon',
            ),
            SizedBox(height: 12.h),
            // Interview Practices Card
            _buildGrowthCard(
              icon: Icons.person,
              title: 'Interview Practices',
              subtitle: 'Get ready for salon interviews',
              badge: 'Coming Soon',
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCard({
    required IconData icon,
    required String title,
    required String subtitle,
    double? progress,
    bool showProgress = false,
    String? badge,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Top Section - Icon, Title, Subtitle, Chevron
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 24.sp, color: Colors.black),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (badge != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
            ],
          ),
        ],
      ),
    );
  }
}
