import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 32.h,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const OnboardingTitle(text: 'Sign In'),
                        SizedBox(height: 32.h),

                        CustomTextField.TextField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIconSvg: 'assets/icons/svg/mail.svg',
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

                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 24.h),
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.7),
                                fontSize: 14.sp, // Font Size/14
                                height: 1.40, // line-height: 140%
                                letterSpacing: -0.01 * 14, // -1% of font size
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.solid,
                                decorationThickness:
                                    0.07 * 14, // 7% of font-size
                                decorationColor: AppColors
                                    .textPrimary, // optional: matches text color
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Button(
                          onPressed: () {},
                          text: 'Sign In',
                          height: 54.h,
                          borderRadius: BorderRadius.circular(32.r),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.white,
                          backgroundColor: AppColors.textPrimary.withOpacity(
                            0.8,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.textPrimary.withOpacity(0.05),
                                thickness: 1.w,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textPrimary.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.textPrimary.withOpacity(0.05),
                                thickness: 1.w,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        SocialButton(
                          icon: 'assets/icons/svg/google.svg',
                          text: 'Continue with Google',
                          onTap: () {},
                        ),

                        SizedBox(height: 12.h),

                        SocialButton(
                          icon: 'assets/icons/svg/apple.svg',
                          text: 'Continue with Apple',
                          backgroundColor: AppColors.brand500,
                          textColor: Colors.white,
                          onTap: () {},
                        ),
                        SizedBox(height: 12.h),

                        AlreadyHaveAccountText(
                          firstText: "Need an account? ",
                          secondText: "Sign up",
                          onSecondTextTap: () {
                            // Custom navigation
                          },
                        ),
                      ],
                    ),
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
