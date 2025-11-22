import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';

class RoadmapScreen extends StatelessWidget {
  RoadmapScreen({super.key});

  final List<Map<String, dynamic>> roadmaps = [
    {
      "title": "Plant Your Roots",
      "buttonLabel": "0-100 hours",
      "subtitle": "Orientation, Confidence, and Professional Foundation.",

      // Section 1: Description text
      "description":
          "Every professional was once a beginner who dared to take the first step. This is where your habits of excellence begin.",

      // Section 2: Focus Goals (list of strings)
      "focusGoals": [
        "Learn your school systems and routines",
        "Build your mindset and time management skills",
        "Organize your tools and create your personal brand vision",
      ],

      // Section 3: Action Checklist (list of strings)
      "actionChecklist": [
        "Set up your Blue Leaf binder or digital folder",
        "Write your mission statement and define your why",
        "Create professional social handles such as @TomekaStyles",
        "Take your first professional photo for social media",
        "Follow 5 inspiring local salons or barbers",
        "Practice sanitation, draping, and basic client setup",
        "Take at least 100 photos of your mannequin work",
        "Arrive 15 minutes early each day for 2 weeks",
        "Keep your workstation clean and organized daily",
        "Record short daily learning reflections",
      ],

      // Section 4: Milestone Reflection (two fields with labels)
      "milestoneReflection": [
        {
          "label":
              "What skill or mindset has grown the most in me since Day One?",
          "value": "",
        },
        {
          "label":
              "What would my future professional self thank me for learning early?",
          "value": "",
        },
      ],
    },

    // Dummy placeholder for other roadmap items
    {
      "title": "Design UI/UX",
      "buttonLabel": "101-300 hours",
      "subtitle": "Create wireframes, prototypes and user flows.",
      "description": "Dummy description",
      "focusGoals": ["Dummy goal 1", "Dummy goal 2"],
      "actionChecklist": ["Dummy checklist item 1", "Dummy checklist item 2"],
      "milestoneReflection": [
        {"label": "Reflection Field 1", "value": ""},
        {"label": "Reflection Field 2", "value": ""},
      ],
    },

    {
      "title": "Development",
      "buttonLabel": "301-600 hours",
      "subtitle": "Implement features, write tests, integrate backend.",
      "description": "Dummy description",
      "focusGoals": ["Dummy goal 1", "Dummy goal 2"],
      "actionChecklist": ["Dummy checklist item 1", "Dummy checklist item 2"],
      "milestoneReflection": [
        {"label": "Reflection Field 1", "value": ""},
        {"label": "Reflection Field 2", "value": ""},
      ],
    },

    {
      "title": "Testing",
      "buttonLabel": "901-1200 hours",
      "subtitle": "Perform unit, integration and E2E tests.",
      "description": "Dummy description",
      "focusGoals": ["Dummy goal 1", "Dummy goal 2"],
      "actionChecklist": ["Dummy checklist item 1", "Dummy checklist item 2"],
      "milestoneReflection": [
        {"label": "Reflection Field 1", "value": ""},
        {"label": "Reflection Field 2", "value": ""},
      ],
    },

    {
      "title": "Release",
      "buttonLabel": "1201-1500 hours",
      "subtitle": "Deploy to stores and monitor analytics.",
      "description": "Dummy description",
      "focusGoals": ["Dummy goal 1", "Dummy goal 2"],
      "actionChecklist": ["Dummy checklist item 1", "Dummy checklist item 2"],
      "milestoneReflection": [
        {"label": "Reflection Field 1", "value": ""},
        {"label": "Reflection Field 2", "value": ""},
      ],
    },

    {
      "title": "Maintenance",
      "buttonLabel": "1501-1800 hours",
      "subtitle": "Bug fixes, updates, and performance improvements.",
      "description": "Dummy description",
      "focusGoals": ["Dummy goal 1", "Dummy goal 2"],
      "actionChecklist": ["Dummy checklist item 1", "Dummy checklist item 2"],
      "milestoneReflection": [
        {"label": "Reflection Field 1", "value": ""},
        {"label": "Reflection Field 2", "value": ""},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleSubtitleAppbar(
        title: "Roadmap",
        subtitle: "Plan your project phases",
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
        ),
        itemCount: roadmaps.length,
        itemBuilder: (context, index) {
          final item = roadmaps[index];
          final isFirst = index == 0;
          final isLast = index == roadmaps.length - 1;

          return TimelineItem(
            isFirst: isFirst,
            isLast: isLast,
            title: item["title"]!,
            subtitle: item["subtitle"]!,
            buttonLabel: item["buttonLabel"]!,
            completed: index == 0, // mark the first item as completed
            index: index,
            roadmap: item,
          );
        },
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool completed;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final int index;
  final Map<String, dynamic> roadmap;

  const TimelineItem({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.index,
    required this.roadmap,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotSize = 20.r;
    final lineWidth = 2.w;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          context.push('/roadmapDetails', extra: roadmap);
        },
        child: Stack(
          children: [
            // Connector line
            if (!isLast)
              Positioned(
                left: (dotSize - lineWidth) / 2,
                top: dotSize,
                bottom: 0,
                child: Container(
                  width: lineWidth,
                  color: completed
                      ? AppColors.timelinePrimary
                      : AppColors.timelineBorder,
                ),
              ),

            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot indicator
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.timelinePrimary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: completed
                        ? null // no border if completed
                        : Border.all(
                            color: AppColors.timelineBorder,
                            width: 2.w,
                          ),
                  ),
                  child: completed
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : null,
                ),

                SizedBox(width: 16.w),

                // Content area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 32.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.sp,
                              color: AppColors.textPrimary.withOpacity(0.8),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? Color(0xFFEFE5FA) // odd items color
                                : AppColors
                                      .lightGrey, // default color for even items
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            buttonLabel,
                            style: TextStyle(
                              color: AppColors.textPrimary.withOpacity(0.8),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.3, // line-height: 130%
                              letterSpacing: -0.01 * 10, // letter-spacing: -1%
                            ),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Subtitle
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 200.w,
                          ), // set your max width
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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
