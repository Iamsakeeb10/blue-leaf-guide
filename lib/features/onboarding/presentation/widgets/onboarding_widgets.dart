import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';

// Shared Title Widget
class OnboardingTitle extends StatelessWidget {
  final String text;

  const OnboardingTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 24.sp,
        height: 1.3,
        letterSpacing: 24.sp * -0.01,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class OnboardingSubtitle extends StatelessWidget {
  final String text;

  const OnboardingSubtitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final double fontSize = 14.sp;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 300.w),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: fontSize * -0.01,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// Page Indicator Widget
class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: index == currentIndex ? 70.w : 70.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.brand500
                : AppColors.brand50,
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
      ),
    );
  }
}

// Social Button Widget
class SocialButton extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? backgroundColor;

  const SocialButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32.r),
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.neutral50,
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: 24.w, height: 24.h),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
                height: 1.3,
                letterSpacing: 15.sp * -0.01, // Letter spacing -1%
                color: textColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Already Have Account Text Widget
class AlreadyHaveAccountText extends StatelessWidget {
  const AlreadyHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            height: 1.5, // Line height 150%
            letterSpacing: 14.sp * -0.015, // Letter spacing -1.5%
            color: AppColors.textPrimary.withOpacity(0.8),
          ),
        ),
        InkWell(
          onTap: () {
            // Navigate to sign in
            context.go('/sign-in');
          },
          child: Text(
            'Sign in',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.3, // Line height 150%
              letterSpacing: 14.sp * -0.01, // Letter spacing -1.5%
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
