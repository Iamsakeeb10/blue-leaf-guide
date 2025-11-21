import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() =>
      _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Personal Information'),
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

              SizedBox(height: 32.h),

              // First Name
              CustomTextField.TextField(
                controller: firstNameController,
                label: 'First Name',
                hint: 'First Name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIconSvg: 'assets/icons/svg/user.svg',
              ),
              SizedBox(height: 12.h),

              // Last Name
              CustomTextField.TextField(
                controller: lastNameController,
                label: 'Last Name',
                hint: 'Last Name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIconSvg: 'assets/icons/svg/user.svg',
              ),

              SizedBox(height: 32.h),

              // Save Button
              Button(
                onPressed: () {
                  // Save logic
                },
                text: 'Save',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
                backgroundColor: AppColors.brand500,
              ),

              SizedBox(height: 12.h),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textPrimary.withOpacity(0.5),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
