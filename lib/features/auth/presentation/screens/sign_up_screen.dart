import 'package:flutter/material.dart' hide BackButtonIcon;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/utils/sizes.dart';
import '../../../../shared/widgets/back_button_icon.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_checkbox.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;
import '../../../onboarding/presentation/widgets/onboarding_widgets.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    bool isTermsAccepted = false;

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
                child: const OnboardingTitle(text: 'Create Account'),
              ),
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    CustomTextField.TextField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIconSvg: 'assets/icons/svg/mail.svg',
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCheckbox(
                          value: isTermsAccepted,
                          onChanged: (val) {},
                          size: 20,
                          activeColor: AppColors.iceBlue,
                          borderColor: AppColors.iceBlue,
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 300.w, // max width applied
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: AppFontSize.s14,
                                    color: AppColors.textPrimary.withOpacity(
                                      0.7,
                                    ),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'By registering, you accept our ',
                                    ),
                                    TextSpan(
                                      text:
                                          'Terms of\n', // force line break after "Terms of"
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Use',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy.',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Button(
                      onPressed: () {
                        context.push('/otp');
                      },
                      text: 'Continue',
                      height: 54.h,
                      borderRadius: BorderRadius.circular(32.r),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      textColor: Colors.white,
                      backgroundColor: AppColors.brand500,
                    ),
                    SizedBox(height: 16.h),
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
