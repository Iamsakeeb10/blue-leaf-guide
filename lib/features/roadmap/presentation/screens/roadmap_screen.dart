import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  final List<Map<String, String>> items = const [
    {
      "title": "Planning Phase",
      "buttonLabel": "0-100 hours",
      "subtitle": "Orientation, Confidence, and Professional Foundation.",
    },
    {
      "title": "Design UI/UX",
      "buttonLabel": "101-300 hours",
      "subtitle": "Create wireframes, prototypes and user flows.",
    },
    {
      "title": "Development",
      "buttonLabel": "301-600 hours",
      "subtitle": "Implement features, write tests, integrate backend.",
    },
    {
      "title": "Testing",
      "buttonLabel": "901-1200 hours",
      "subtitle": "Perform unit, integration and E2E tests.",
    },
    {
      "title": "Release",
      "buttonLabel": "1201-1500 hours",
      "subtitle": "Deploy to stores and monitor analytics.",
    },
    {
      "title": "Maintenance",
      "buttonLabel": "1501-1800 hours",
      "subtitle": "Bug fixes, updates, and performance improvements.",
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
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isFirst = index == 0;
          final isLast = index == items.length - 1;

          return TimelineItem(
            isFirst: isFirst,
            isLast: isLast,
            title: item["title"]!,
            subtitle: item["subtitle"]!,
            buttonLabel: item["buttonLabel"]!,
            completed: index == 0, // mark the first item as completed
            index: index,
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

  const TimelineItem({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.index,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotSize = 20.r;
    final lineWidth = 2.w;

    return Stack(
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
                    : Border.all(color: AppColors.timelineBorder, width: 2.w),
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
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
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
    );
  }
}
