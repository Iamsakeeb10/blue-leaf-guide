import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;
import '../../../onboarding/presentation/widgets/onboarding_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Reset Password'),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 86.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.center,
                child: const OnboardingTitle(text: 'Reset Password'),
              ),
              SizedBox(height: 2.h),

              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 300.w,
                  ), // set your max width
                  child: Text(
                    'Resetting passwords requires security verification. Verify via registered email.',
                    textAlign: TextAlign.center, // optional: center text
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3, // line-height 130%
                      letterSpacing: -0.01 * 14, // -1% letter spacing
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              CustomTextField.TextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your registered email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIconSvg: 'assets/icons/svg/mail.svg',
              ),
              SizedBox(height: 12.h),

              Button(
                onPressed: () {
                  // Reset password logic here
                  context.push('/otp', extra: {'nextRoute': '/reset-password'});
                },
                text: 'Reset',
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
