import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

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

      body: Column(
        children: [
          /// ---------- TOP CENTER SECTION ----------
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// PNG ICON
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

                    /// Subtitle with max width
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 300.w),
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
          ),

          /// ---------- 4 BOXES (2 PER ROW) ----------
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureBox("How do I build my client base?"),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildFeatureBox(
                        "Tips for my first salon interview?",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureBox(
                        "How to improve my cutting technique?",
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildFeatureBox(
                        "Social media tips for cosmetologists?",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          /// ---------- INPUT BAR ----------
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                4.h,
                16.w,
                MediaQuery.of(context).padding.bottom + 16.h,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    width: 1.5,
                    color: AppColors.textPrimary.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // center icons vertically
                  children: [
                    /// Multi-line TextField
                    Flexible(
                      child: TextField(
                        maxLines: null, // allow wrapping
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          hintText: "Ask tutor anything...",
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),

                    // SizedBox(width: 12.w),
                    Container(
                      width: 40.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/icons/svg/file.svg",
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),

                    SizedBox(width: 10.w),

                    /// Send button
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.brand500,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/icons/svg/send.svg",
                          width: 20.w,
                          height: 20.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Single box widget
  Widget _buildFeatureBox(String title) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
