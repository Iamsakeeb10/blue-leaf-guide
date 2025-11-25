import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/custom_date_picker_dialog.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // Date
  DateTime _selectedDate = DateTime.now();

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  // Reflection controllers (for 3 sections)
  final Map<String, TextEditingController> reflectionControllers = {
    'Today’s win': TextEditingController(),
    'Challenges and lessons': TextEditingController(),
    'Additional notes': TextEditingController(),
  };

  final Map<String, String> reflectionHints = {
    'Today’s win': 'What went well today? What are you proud of?',
    'Challenges and lessons': 'What didn’t go as planned? What did you learn?',
    'Additional notes': 'Any other thoughts or reminders?',
  };

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    for (var controller in reflectionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today’s activity',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final todayNormalized = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );

                  final selected = await showDialog<DateTime>(
                    context: context,
                    builder: (_) => CustomDatePickerDialog(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: todayNormalized,
                    ),
                  );

                  if (selected != null && selected != _selectedDate) {
                    setState(() {
                      _selectedDate = selected;
                    });
                  }
                },
                child: Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: SvgPicture.asset(
                    'assets/icons/svg/calendar.svg',
                    fit: BoxFit.contain,
                    width: 24.w,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: CustomTextField.TextField(
                  controller: firstNameController,
                  label: 'Client Serve',
                  hint: '0',
                  prefixIconSvg: 'assets/icons/svg/user.svg',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField.TextField(
                  controller: lastNameController,
                  label: 'Money Earned',
                  hint: '0',
                  prefixIconSvg: 'assets/icons/svg/dollar-grey.svg',
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          CustomTextField.TextField(
            controller: emailController,
            label: 'Cards passed out',
            hint: '0',
            prefixIconSvg: 'assets/icons/svg/card.svg',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 12.h),

          for (var entry in reflectionControllers.entries)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: entry.value,
                  maxLines: 5,
                  minLines: 4,
                  decoration: InputDecoration(
                    hintText: reflectionHints[entry.key], // ✅ Dynamic hint
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary.withOpacity(0.3),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(14.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.neutral50.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.brand500,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          SizedBox(height: 12.h),

          Button(
            onPressed: () {},
            text: 'Save',
            height: 54.h,
            borderRadius: BorderRadius.circular(32.r),
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            textColor: Colors.white,
            backgroundColor: AppColors.brand500,
            // isLoading: authProvider.isLoading,
          ),
        ],
      ),
    );
  }
}
