import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_dialog.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Account',
      ), // shows back button by default
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 12.h),

              // Avatar
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neutral50,
                ),
                child: Icon(
                  Icons.person,
                  size: 50.sp,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 8.h),

              // User Name
              Text(
                'Tomeka Morgan',
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.8),
                  fontSize: 18.sp,
                  height: 1.3,
                  letterSpacing: -0.01 * 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 8.h),

              // Edit Profile Button
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: AppColors.textPrimary.withOpacity(0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    letterSpacing: -0.01 * 10,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Profile Items
              _buildProfileItem(
                svgIconPath: 'assets/icons/svg/profile-user.svg',
                iconBackgroundColor: AppColors.textPrimary.withOpacity(0.05),
                title: 'Personal Information',
                onTap: () {
                  context.push('/profile-information');
                },
              ),
              _buildProfileItem(
                svgIconPath: 'assets/icons/svg/profile-notification.svg',
                iconBackgroundColor: AppColors.textPrimary.withOpacity(0.05),
                title: 'Change Password',
                showDivider: false,
                onTap: () {
                  context.push('/change-password');
                },
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              Button(
                onPressed: () {
                  // delete account logic
                  showDialog(
                    context: context,
                    barrierDismissible:
                        true, // allows dismiss by tapping outside
                    builder: (_) => CustomDialog(
                      title: "Delete Account",
                      subtitle:
                          "Deleting your account will permanently remove all your data and progress.",
                      primaryButtonText: "Yes,Delete",
                      primaryButtonOnPressed: () {
                        // Your delete logic here
                        print("Account deleted");
                        Navigator.of(context).pop(); // close dialog
                      },
                      secondaryButtonText: "Cancel",
                      secondaryButtonOnPressed: () {
                        print("Cancelled");
                        Navigator.of(context).pop(); // close dialog
                      },
                    ),
                  );
                },
                text: 'Delete Account',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
                backgroundColor: AppColors.errorRed,
              ),

              SizedBox(height: 12.h),

              Button(
                onPressed: () {
                  // delete all data logic
                  showDialog(
                    context: context,
                    barrierDismissible:
                        true, // allows dismiss by tapping outside
                    builder: (_) => CustomDialog(
                      title: "Delete All Data",
                      subtitle:
                          "Deleting data will be securely erased and removed from our system upon deletion.",
                      primaryButtonText: "Yes,Delete",
                      primaryButtonOnPressed: () {
                        // Your delete logic here
                        print("Account deleted");
                        Navigator.of(context).pop(); // close dialog
                      },
                      secondaryButtonText: "Cancel",
                      secondaryButtonOnPressed: () {
                        print("Cancelled");
                        Navigator.of(context).pop(); // close dialog
                      },
                    ),
                  );
                },
                text: 'Delete All Data',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: AppColors.textPrimary,
                backgroundColor: AppColors.textPrimary.withOpacity(0.05),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required String svgIconPath,
    required Color iconBackgroundColor,
    required String title,
    bool showDivider = true,
    VoidCallback? onTap, // optional onTap callback
  }) {
    final item = GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(100.r),
              ),
              padding: EdgeInsets.all(10.w),
              child: SvgPicture.asset(svgIconPath, width: 20.sp, height: 20.sp),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary.withOpacity(0.8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: -0.01 * 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18.sp,
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );

    if (showDivider) {
      return Column(
        children: [
          item,
          Divider(color: AppColors.neutral50, thickness: 1.w, height: 1.h),
        ],
      );
    } else {
      return item;
    }
  }
}
