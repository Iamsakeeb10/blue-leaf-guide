import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../shared/widgets/text_field.dart' as CustomTextField;

class ConfirmChangePasswordScreen extends StatefulWidget {
  const ConfirmChangePasswordScreen({super.key});

  @override
  State<ConfirmChangePasswordScreen> createState() =>
      _ConfirmChangePasswordScreenState();
}

class _ConfirmChangePasswordScreenState
    extends State<ConfirmChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Confirm Change Password'),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // New Password Field
              CustomTextField.TextField(
                controller: newPasswordController,
                label: 'Create New Password',
                hint: 'Create New Password',
                obscureText: _obscureNewPassword,
                textInputAction: TextInputAction.next,
                prefixIconSvg: 'assets/icons/svg/lock.svg',
                suffixIconSvg: _obscureNewPassword
                    ? 'assets/icons/svg/eye-closed.svg'
                    : 'assets/icons/svg/eye-open.svg',
                onSuffixIconTap: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),

              SizedBox(height: 16.h),

              // Confirm Password Field
              CustomTextField.TextField(
                controller: confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm New Password',
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                prefixIconSvg: 'assets/icons/svg/lock.svg',
                suffixIconSvg: _obscureConfirmPassword
                    ? 'assets/icons/svg/eye-closed.svg'
                    : 'assets/icons/svg/eye-open.svg',
                onSuffixIconTap: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),

              SizedBox(height: 12.h),

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
              SizedBox(height: 32.h),

              // Continue Button
              Button(
                onPressed: () {
                  // Add continue logic: validate both passwords match
                },
                text: 'Continue',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
                backgroundColor: AppColors.brand500,
              ),

              SizedBox(height: 12.h),

              // Cancel Button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  minimumSize: Size(double.infinity, 54.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.8),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
