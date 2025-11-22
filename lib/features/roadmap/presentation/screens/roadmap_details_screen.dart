import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_checkbox.dart';

class RoadmapDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> roadmap;

  const RoadmapDetailsScreen({super.key, required this.roadmap});

  @override
  State<RoadmapDetailsScreen> createState() => _RoadmapDetailsScreenState();
}

class _RoadmapDetailsScreenState extends State<RoadmapDetailsScreen> {
  List<bool> checklistStates = [];

  @override
  void initState() {
    super.initState();

    final actionChecklist = List<String>.from(
      widget.roadmap["actionChecklist"] ?? [],
    );

    checklistStates = List<bool>.filled(actionChecklist.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.roadmap["description"] as String? ?? "";
    final focusGoals = List<String>.from(widget.roadmap["focusGoals"] ?? []);
    final actionChecklist = List<String>.from(
      widget.roadmap["actionChecklist"] ?? [],
    );
    final milestoneReflection = List<Map<String, String>>.from(
      widget.roadmap["milestoneReflection"] ?? [],
    );

    final roadmapTitle = widget.roadmap['title'] as String? ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: roadmapTitle),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Section 1: Description
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TOP QUOTE ICON
                SvgPicture.asset(
                  "assets/icons/svg/quotes-right.svg",
                  width: 20.w,
                ),
                SizedBox(height: 12.h),

                /// CENTERED TEXT
                Text(
                  description,
                  textAlign: TextAlign.center, // 👉 Center text
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withOpacity(0.8),
                  ),
                ),

                SizedBox(height: 12.h),

                /// BOTTOM QUOTE ICON
                SvgPicture.asset(
                  "assets/icons/svg/quotes-left.svg",
                  width: 20.w,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Section 2: Focus Goals
          Text(
            "Focus Goals",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: focusGoals.asMap().entries.map((entry) {
                final index = entry.key;
                final goal = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == focusGoals.length - 1 ? 0 : 10.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "•",
                        style: TextStyle(
                          fontSize: 18.sp,
                          height: 1.2,
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          goal,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.h),

          // Section 3: Action Checklist (checkboxes)
          Text(
            "Action Checklist",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...actionChecklist.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == actionChecklist.length - 1 ? 0 : 12.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCheckbox(
                    value: checklistStates[index],
                    onChanged: (val) {
                      setState(() {
                        checklistStates[index] = val;
                      });
                    },
                    size: 20,
                    activeColor: AppColors.brand500,
                    borderColor: AppColors.iceBlue,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 20.h),

          // Section 4: Milestone Reflection
          Text(
            "Milestone Reflection",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          ...milestoneReflection.map(
            (field) => Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Dynamic label from roadmap item
                  Text(
                    field["label"] ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 🔹 Multiline textarea with static hint text
                  TextField(
                    maxLines: 5,
                    minLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your reflection here...",
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary.withOpacity(0.3),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      alignLabelWithHint: true,
                      contentPadding: EdgeInsets.all(14.w),
                      // 👉 Updated border as per requirement
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: BorderSide(
                          color: AppColors.neutral50.withOpacity(
                            0.05,
                          ), // #090F050D
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
                ],
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Button(
            onPressed: () {},
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
        ],
      ),
    );
  }
}
