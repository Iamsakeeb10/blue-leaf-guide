import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 86.h), // spacing below AppBar
              // Title
              Center(
                child: Text(
                  'Create New Password',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              CustomTextField.TextField(
                controller: passwordController,
                label: 'Create New Password',
                hint: 'Create New Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                suffixIconSvg: 'assets/icons/svg/eye-closed.svg',
                prefixIconSvg: 'assets/icons/svg/lock.svg',
              ),
              SizedBox(height: 12.h),
              // Instruction Text
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create a password with at least 4 characters',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.4, // 140% line-height
                    letterSpacing: 0, // 0%
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Done Button
              Button(
                onPressed: () {
                  // Navigate to next screen, e.g., dashboard
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
      ),
    );
  }
}
