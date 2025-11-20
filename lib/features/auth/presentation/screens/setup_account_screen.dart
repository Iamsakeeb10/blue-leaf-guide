// lib/features/auth/presentation/screens/setup_account_screen.dart
import 'package:flutter/material.dart' hide BackButtonIcon;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/back_button_icon.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;
import '../../../onboarding/presentation/widgets/onboarding_widgets.dart';

class SetupAccountScreen extends StatelessWidget {
  const SetupAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final passwordController = TextEditingController();

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
                child: const OnboardingTitle(text: 'Setup Account'),
              ),
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    CustomTextField.TextField(
                      controller: firstNameController,
                      label: 'First Name',
                      hint: 'First Name',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIconSvg: 'assets/icons/svg/user.svg',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField.TextField(
                      controller: lastNameController,
                      label: 'Last Name',
                      hint: 'Last Name',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIconSvg: 'assets/icons/svg/user.svg',
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField.TextField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Password',
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      suffixIconSvg: 'assets/icons/svg/eye-closed.svg',
                      prefixIconSvg: 'assets/icons/svg/lock.svg',
                    ),
                    SizedBox(height: 12.h),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create a password with at least 4 characters',
                        style: TextStyle(
                          fontSize: 12.sp, // Font Size/12
                          fontWeight: FontWeight.w500, // Medium
                          height: 1.4, // line-height: 140%
                          letterSpacing: 0, // 0%
                          color: AppColors.textSecondary.withOpacity(
                            0.7,
                          ), // optional color
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Button(
                      onPressed: () {
                        // Navigate to next screen or dashboard
                        // context.push('/dashboard');
                      },
                      text: 'Done',
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
            ],
          ),
        ),
      ),
    );
  }
}
