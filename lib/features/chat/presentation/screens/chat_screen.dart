import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        hideRightIcon: false,
        title: "AI Tutor",
        rightIconPath: "assets/icons/svg/history.svg",
        onRightTap: () => print("Right icon clicked"),
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// SVG icon
              Image.asset(
                "assets/images/gemini-chat.png",
                width: 72.w,
                height: 72.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24.h),

              /// Title
              Text(
                "Welcome to Your AI Tutor",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              SizedBox(height: 8.h),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 300.w, // <-- apply your desired max width
                ),
                child: Text(
                  "Ask me anything about cosmetology, career advice, or building your brand",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withOpacity(0.7),
                    height: 1.5,
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
