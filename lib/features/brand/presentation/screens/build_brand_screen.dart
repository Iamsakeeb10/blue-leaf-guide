import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/profile_list_item.dart';
// 👇 Import the new stepper
import '../widgets/custom_stepper.dart'; // Adjust path as per your folder structure

// Data model for each step
class StepData {
  final String title;
  final List<String> items;

  StepData({required this.title, required this.items});
}

class BuildBrandScreen extends StatefulWidget {
  const BuildBrandScreen({super.key});

  @override
  State<BuildBrandScreen> createState() => _BuildBrandScreenState();
}

class _BuildBrandScreenState extends State<BuildBrandScreen> {
  int currentStep = 2;

  final List<StepData> stepData = [
    StepData(
      title: "Strategy",
      items: [
        "Define your brand purpose",
        "Identify target audience",
        "Analyze competitors",
        "Set brand goals",
      ],
    ),
    StepData(
      title: "Visual",
      items: [
        "Choose brand colors",
        "Design logo",
        "Select typography",
        "Create brand guidelines",
      ],
    ),
    StepData(
      title: "Marketing",
      items: [
        "Build social media presence",
        "Create content calendar",
        "Plan launch campaign",
        "Engage early customers",
      ],
    ),
    StepData(
      title: "Planning",
      items: [
        "Set growth KPIs",
        "Build customer feedback loop",
        "Plan product iterations",
        "Schedule brand audits",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> currentItems = stepData[currentStep - 1].items;

    return Scaffold(
      appBar: CustomAppBar(title: 'Build Brand'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          left: 18.w,
          right: 16.w,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            Padding(
              padding: EdgeInsets.only(left: 12.w, right: 20.w),
              child: CustomStepper(
                currentStep: currentStep,
                totalSteps: stepData.length,
                titles: stepData.map((d) => d.title).toList(),
                onStepTap: (index) {
                  setState(() {
                    currentStep = index;
                  });
                },
                // 👇 Pass completedSteps later like:
                // completedSteps: [true, true, false, false],
              ),
            ),

            SizedBox(height: 32.h),

            Expanded(
              child: ListView.builder(
                itemCount: currentItems.length,
                itemBuilder: (context, index) {
                  return ProfileListItem(
                    title: currentItems[index],
                    showCheckmark: false,
                    onTap: () => debugPrint("Tapped: ${currentItems[index]}"),
                  );
                },
              ),
            ),

            Column(
              children: [
                Button(
                  onPressed: () {},
                  text: 'Next Visual',
                  height: 54.h,
                  borderRadius: BorderRadius.circular(32.r),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                  backgroundColor: AppColors.brand500.withOpacity(0.1),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
