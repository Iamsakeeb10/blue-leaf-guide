import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';
import '../../data/roadmap_service.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final RoadmapService _roadmapService = RoadmapService();
  List<Map<String, dynamic>> roadmaps = [];
  Map<String, Map<String, dynamic>> userProgress = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    final fetchedRoadmaps = await _roadmapService.fetchRoadmaps();
    final fetchedProgress = await _roadmapService.fetchUserProgress();

    setState(() {
      roadmaps = fetchedRoadmaps;
      userProgress = fetchedProgress;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleSubtitleAppbar(
        title: "Roadmap",
        subtitle: "Plan your project phases",
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roadmaps.isEmpty
          ? Center(
              child: Text(
                'No roadmaps available',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: MediaQuery.of(context).padding.bottom + 16.h,
              ),
              itemCount: roadmaps.length,
              itemBuilder: (context, index) {
                final item = roadmaps[index];
                final roadmapId = item['id'] as String;
                final isFirst = index == 0;
                final isLast = index == roadmaps.length - 1;

                final progress = userProgress[roadmapId];
                final completed = progress?['completed'] ?? false;

                return TimelineItem(
                  isFirst: isFirst,
                  isLast: isLast,
                  title: item["title"] ?? '',
                  subtitle: item["subtitle"] ?? '',
                  buttonLabel: item["buttonLabel"] ?? '',
                  completed: completed,
                  index: index,
                  roadmapId: roadmapId,
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
  final String roadmapId;

  const TimelineItem({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.index,
    required this.roadmapId,
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
          context.push('/roadmapDetails', extra: roadmapId);
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
                        ? null
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
                                ? const Color(0xFFEFE5FA)
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            buttonLabel,
                            style: TextStyle(
                              color: AppColors.textPrimary.withOpacity(0.8),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              letterSpacing: -0.01 * 10,
                            ),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Subtitle
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200.w),
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
