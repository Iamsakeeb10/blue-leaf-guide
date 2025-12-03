import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;
import '../../../auth/providers/auth_provider.dart';

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
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;

    if (userData != null) {
      firstNameController.text = userData['firstName'] ?? '';
      lastNameController.text = userData['lastName'] ?? '';
    }
  }

  Future<void> _handleSave() async {
    if (firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      _showError('Please enter your last name');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.updateProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      _showError(authProvider.errorMessage ?? 'Failed to update profile');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;
    final firstName = userData?['firstName'] ?? '';
    final photoURL = userData?['photoURL'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Personal Information'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 12.h),

              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF24AC69), // fallback background color
                  image: (photoURL != null && photoURL.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(photoURL),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (photoURL == null || photoURL.isEmpty)
                    ? Center(
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : '',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),

              SizedBox(height: 8.h),

              // // Edit Profile Button
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              //   decoration: BoxDecoration(
              //     color: AppColors.lightGrey,
              //     borderRadius: BorderRadius.circular(100.r),
              //   ),
              //   child: Text(
              //     'Edit Profile',
              //     style: TextStyle(
              //       color: AppColors.textPrimary.withOpacity(0.8),
              //       fontSize: 10.sp,
              //       fontWeight: FontWeight.w600,
              //       height: 1.3,
              //       letterSpacing: -0.01 * 10,
              //     ),
              //   ),
              // ),
              SizedBox(height: 32.h),

              // First Name
              CustomTextField.TextField(
                controller: firstNameController,
                label: '',
                hint: 'First Name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIconSvg: 'assets/icons/svg/user.svg',
              ),
              SizedBox(height: 12.h),

              // Last Name
              CustomTextField.TextField(
                controller: lastNameController,
                label: '',
                hint: 'Last Name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                prefixIconSvg: 'assets/icons/svg/user.svg',
              ),

              SizedBox(height: 32.h),

              // Save Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Button(
                    onPressed: _handleSave,
                    text: authProvider.isLoading ? 'Saving...' : 'Save',
                    height: 54.h,
                    borderRadius: BorderRadius.circular(32.r),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    textColor: Colors.white,
                    backgroundColor: AppColors.brand500,
                    isLoading: authProvider.isLoading,
                  );
                },
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
