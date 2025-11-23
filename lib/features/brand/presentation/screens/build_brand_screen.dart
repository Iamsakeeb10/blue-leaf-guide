import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/profile_list_item.dart';

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
  // Current step is 1-based: 1 = first, 4 = last
  int currentStep = 2;

  // Step content data
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

            // Custom Stepper
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
              ),
            ),

            SizedBox(height: 32.h),

            // Dynamic list based on current step
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

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> titles;
  final Function(int)? onStepTap;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double stepSize = 20.r;
        final double lineHeight = 2.w;
        final double availableWidth = constraints.maxWidth;
        final double totalStepWidth = stepSize * totalSteps;
        final double totalLineWidth = availableWidth - totalStepWidth;
        final double lineWidth = totalLineWidth / (totalSteps - 1);

        final List<double> labelOffsets = [
          -(lineWidth * 0.17),
          lineWidth * 0.01,
          lineWidth * 0.22,
          lineWidth * 0.26,
        ];

        return Column(
          children: [
            // Stepper: Dots + Lines
            SizedBox(
              height: stepSize,
              child: Stack(
                children: [
                  // Connector lines (only show base color — no completion logic)
                  Positioned.fill(
                    child: Row(
                      children: List.generate(totalSteps * 2 - 1, (index) {
                        if (index.isOdd) {
                          return Container(
                            width: lineWidth,
                            height: lineHeight,
                            margin: EdgeInsets.symmetric(
                              vertical: (stepSize - lineHeight) / 2,
                            ),
                            color: AppColors.timelineBorder,
                          );
                        } else {
                          return SizedBox(width: stepSize);
                        }
                      }),
                    ),
                  ),
                  // Step indicators (dots)
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(totalSteps, (index) {
                        final stepNumber = index + 1;
                        final isSelected = currentStep == stepNumber;

                        return GestureDetector(
                          onTap: () => onStepTap?.call(stepNumber),
                          child: Container(
                            width: stepSize,
                            height: stepSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.timelinePrimary
                                    : AppColors.timelineBorder,
                                width: isSelected
                                    ? 4.w
                                    : 2.w, // thicker when selected
                              ),
                              color: Colors.transparent,
                            ),
                            // ✅ No checkmark — hidden as requested
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Labels (also tappable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final stepNumber = index + 1;
                final isSelected = currentStep == stepNumber;

                return GestureDetector(
                  onTap: () => onStepTap?.call(stepNumber),
                  child: Transform.translate(
                    offset: Offset(labelOffsets[index], 0),
                    child: Text(
                      titles[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.textPrimary.withOpacity(0.8)
                            : AppColors.textPrimary.withOpacity(0.3),
                        height: 1.3,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
