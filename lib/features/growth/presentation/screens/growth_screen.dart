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
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _buildGrowthCard(
                    title: 'Brand Builder',
                    subtitle: 'Create your professional identity',
                    progress: 0.5,
                    showProgress: true,
                    backgroundColor: AppColors.lightGrey,
                    svgPath: 'assets/icons/svg/building.svg',
                  ),

                  SizedBox(height: 12.h),
                  // Progress & Rewards Card
                  _buildGrowthCard(
                    title: 'Progress & Rewards',
                    subtitle: 'Track achievement & celebrate wins',
                    backgroundColor: AppColors.bgLight,
                    svgPath: 'assets/icons/svg/cup.svg',
                  ),
                  SizedBox(height: 12.h),
                  // Learning Guides Card
                  _buildGrowthCard(
                    title: 'Learning Guides',
                    subtitle: 'Tutorials, tips, and industry insights',
                    badge: 'Coming Soon',
                    backgroundColor: AppColors.lightGrey,
                    showChevron: false,
                    svgPath: 'assets/icons/svg/book.svg',
                  ),
                  SizedBox(height: 12.h),
                  // Interview Practices Card
                  _buildGrowthCard(
                    title: 'Interview Practices',
                    subtitle: 'Get ready for salon interviews',
                    badge: 'Coming Soon',
                    backgroundColor: AppColors.bgLight,
                    showChevron: false,
                    svgPath: 'assets/icons/svg/user-black.svg',
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCard({
    required String svgPath,
    required String title,
    required String subtitle,
    double? progress,
    bool showProgress = false,
    String? badge,
    required Color backgroundColor,
    bool showChevron = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SVG Icon - vertically centered using FittedBox + Center
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: SvgPicture.asset(
                        svgPath,
                        width: 20.sp,
                        height: 20.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
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
                                  color: AppColors.amber,
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
                            if (showChevron) ...[
                              Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.textPrimary.withOpacity(0.8),
                                size: 24.sp,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showProgress && progress != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  SizedBox(width: 56.w),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.7),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                color: AppColors.brand500,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.brand100,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.brand500,
                            ),
                            minHeight: 6.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showChevron) SizedBox(width: 12.w),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
