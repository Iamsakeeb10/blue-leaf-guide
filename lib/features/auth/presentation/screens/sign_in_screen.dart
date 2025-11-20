import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/utils/sizes.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;
import '../../../onboarding/presentation/widgets/onboarding_widgets.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      const OnboardingTitle(text: 'Sign In'),
                      SizedBox(height: 32.h),

                      // Email Field
                      CustomTextField.TextField(
                        controller: emailController,
                        label: 'Email',
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIconSvg: 'assets/icons/svg/mail.svg',
                      ),
                      SizedBox(height: 16.h),

                      // Password Field
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

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 24.h),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: AppFontSize.s14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Sign In Button
                      Button(
                        onPressed: () {},
                        text: 'Sign In',
                        height: 52.h,
                        borderRadius: BorderRadius.circular(12.r),
                        fontSize: AppFontSize.s16,
                      ),
                      SizedBox(height: 24.h),

                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.tint.withOpacity(0.4),
                              thickness: 1.w,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: AppFontSize.s14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.tint.withOpacity(0.4),
                              thickness: 1.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Social Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Button(
                              onPressed: () {},
                              text: 'Google',
                              height: 48.h,
                              borderRadius: BorderRadius.circular(12.r),
                              fontSize: AppFontSize.s14,
                              gradientColors: [
                                Colors.red[400]!,
                                Colors.red[600]!,
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Button(
                              onPressed: () {},
                              text: 'Apple',
                              height: 48.h,
                              borderRadius: BorderRadius.circular(12.r),
                              fontSize: AppFontSize.s14,
                              gradientColors: [
                                Colors.grey[600]!,
                                Colors.grey[800]!,
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Sign Up Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontSize: AppFontSize.s14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create one',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
