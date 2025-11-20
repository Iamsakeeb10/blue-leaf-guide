import 'package:flutter/material.dart' hide BackButtonIcon;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/back_button_icon.dart';
import '../../../../shared/widgets/button.dart';
import '../../../onboarding/presentation/widgets/onboarding_widgets.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 45.w, // your box size
      height: 45.w,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.05),
          width: 1.25,
        ),
        borderRadius: BorderRadius.circular(22.5.r),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButtonIcon(onTap: () => context.pop()),

              SizedBox(height: 32.h),
              Align(
                alignment: Alignment.center,
                child: const OnboardingTitle(text: 'Enter Code'),
              ),
              SizedBox(height: 2.h),
              Center(
                child: Text(
                  'Enter the security code we sent on shakib@gmail.com',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.8),
                    height: 1.3, // 130% line height
                    letterSpacing: -0.01 * 14, // -1% of font size
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32.h),

              Center(
                child: Pinput(
                  length: 4,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme,
                  submittedPinTheme: defaultPinTheme,
                  onCompleted: (pin) {
                    print("OTP entered: $pin");
                  },
                ),
              ),

              SizedBox(height: 12.h),

              // Timer
              Center(
                child: Text(
                  '04:59',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.3, // 130% line height
                    letterSpacing: -0.01 * 14, // -1% of font size
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Didn't receive code
              Center(
                child: Text(
                  "Didn't receive a code?",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.4, // 130% line height
                    letterSpacing: -0.01 * 14, // -1% of font size
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Continue Button
              Button(
                onPressed: () {
                  // Add next navigation
                },
                text: 'Continue',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
                backgroundColor: AppColors.brand500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
