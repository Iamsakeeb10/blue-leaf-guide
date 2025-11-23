import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';

class BuildBrandScreen extends StatefulWidget {
  const BuildBrandScreen({super.key});

  @override
  State<BuildBrandScreen> createState() => _BuildBrandScreenState();
}

class _BuildBrandScreenState extends State<BuildBrandScreen> {
  int currentStep = 2; // Set to 2 to show first step as completed
  final int totalSteps = 4;
  final List<String> titles = ["Brand", "Identity", "Content", "Launch"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleSubtitleAppbar(
        title: "Build Your Brand",
        subtitle: "Follow these key steps",
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
          top: 0.h,
        ),
        child: Column(
          children: [
            // Custom Stepper
            CustomStepper(
              currentStep: currentStep,
              totalSteps: totalSteps,
              titles: titles,
              onStepTap: (index) {
                setState(() {
                  currentStep = index;
                });
              },
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

        // Calculate offsets as percentages of line width for consistency
        final double firstLabelOffset = -(lineWidth * 0.08); // ~8% left
        final double secondLabelOffset =
            (lineWidth * 0.05); // ~4% left (slight)
        final double thirdLabelOffset = lineWidth * 0.10; // ~10% right
        final double lastLabelOffset = lineWidth * 0.18; // ~18% right

        return Column(
          children: [
            // Stepper
            SizedBox(
              height: stepSize,
              child: Stack(
                children: [
                  // Background lines
                  Positioned.fill(
                    child: Row(
                      children: List.generate(totalSteps * 2 - 1, (index) {
                        if (index.isOdd) {
                          // Line
                          final lineIndex = index ~/ 2;
                          final isCompleted = currentStep > lineIndex + 1;
                          return Container(
                            width: lineWidth,
                            height: lineHeight,
                            margin: EdgeInsets.symmetric(
                              vertical: (stepSize - lineHeight) / 2,
                            ),
                            color: isCompleted
                                ? AppColors.timelinePrimary
                                : AppColors.timelineBorder,
                          );
                        } else {
                          // Step placeholder
                          return SizedBox(width: stepSize);
                        }
                      }),
                    ),
                  ),
                  // Steps
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(totalSteps, (index) {
                        final stepNumber = index + 1;
                        final isCompleted = currentStep > stepNumber;

                        return GestureDetector(
                          onTap: () => onStepTap?.call(stepNumber),
                          child: Container(
                            width: stepSize,
                            height: stepSize,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? AppColors.timelinePrimary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isCompleted
                                  ? null
                                  : Border.all(
                                      color: AppColors.timelineBorder,
                                      width: 2.w,
                                    ),
                            ),
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12.sp,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(totalSteps, (index) {
                final stepNumber = index + 1;
                final isCompleted = currentStep > stepNumber;

                // Calculate offset based on position
                double offsetX = 0;
                if (index == 0) {
                  offsetX = firstLabelOffset; // First: push left
                } else if (index == 1) {
                  offsetX = secondLabelOffset; // Second: push slight left
                } else if (index == 2) {
                  offsetX = thirdLabelOffset; // Third: push right
                } else if (index == 3) {
                  offsetX = lastLabelOffset; // Last: push more right
                }

                return Transform.translate(
                  offset: Offset(offsetX, 0),
                  child: Text(
                    titles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? AppColors.timelinePrimary
                          : AppColors.textSecondary,
                      height: 1.3,
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
