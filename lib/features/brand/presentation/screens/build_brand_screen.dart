import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/profile_list_item.dart';
import '../../data/marketing_service.dart';
import '../../data/strategy_service.dart';
import '../../data/visual_service.dart';
import '../../models/marketing_item.dart';
import '../../models/strategy_item.dart';
import '../../models/visual_item.dart';
import '../widgets/custom_stepper.dart';

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
  int currentStep = 1;
  final StrategyService _strategyService = StrategyService();
  final MarketingService _marketingService = MarketingService();

  List<StrategyItem> strategyItems = [];
  List<MarketingItem> marketingItems = [];
  final VisualService _visualService = VisualService();
  List<VisualItem> visualItems = [];

  bool _isLoading = true;

  final List<StepData> stepData = [
    StepData(
      title: "Strategy",
      items: [
        "Branding Basics",
        "Vision & Mission",
        "Target Audience",
        "Brand Personality",
        "Brand Story",
      ],
    ),
    StepData(
      title: "Visual",
      items: ["Business Name", "Color Palette", "Logo Design", "Business Card"],
    ),
    StepData(
      title: "Marketing",
      items: [
        "Marketing Collateral",
        "Email Marketing",
        "Social Media Marketing",
        "Website",
        "SEO & Content Strategy",
        "Offline Marketing & Social Impact",
      ],
    ),
    StepData(title: "Planning", items: []),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final strategy = await _strategyService.getUserStrategyItems(userId);
      final marketing = await _marketingService.getUserMarketingItems(userId);
      final visual = await _visualService.getUserVisualItems(userId);

      setState(() {
        strategyItems = strategy;
        marketingItems = marketing;
        visualItems = visual;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToPlanning() {
    context.push('/planning');
  }

  @override
  Widget build(BuildContext context) {
    final List<String> currentItems = stepData[currentStep - 1].items;

    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Build Brand'),
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  if (index == 4) {
                    // Navigate to PlanningScreen when step 4 is tapped
                    context.push('/planning');
                  } else {
                    setState(() {
                      currentStep = index;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: currentStep == 4
                  ? _buildPlanningButton()
                  : ListView.builder(
                      itemCount: currentItems.length,
                      itemBuilder: (context, index) {
                        if (currentStep == 1) {
                          // Strategy items
                          StrategyItem? item;
                          if (index < strategyItems.length) {
                            item = strategyItems[index];
                          }

                          return ProfileListItem(
                            key: ValueKey(item?.id ?? index),
                            title: currentItems[index],
                            showCheckmark: item?.isCompleted ?? false,
                            onTap: () async {
                              if (item != null) {
                                final updatedItem = await context
                                    .push<StrategyItem>(
                                      '/strategy_item/${item.id}',
                                      extra: {
                                        'item': item,
                                        'stepTitle':
                                            stepData[currentStep - 1].title,
                                      },
                                    );

                                if (updatedItem != null) {
                                  setState(() {
                                    final itemIndex = strategyItems.indexWhere(
                                      (e) => e.id == updatedItem.id,
                                    );
                                    if (itemIndex != -1) {
                                      strategyItems[itemIndex] = updatedItem;
                                    }
                                  });
                                }
                              }
                            },
                          );
                          // In BuildBrandScreen, update the Visual items section (around line 173)
                        } else if (currentStep == 2) {
                          // Visual items
                          VisualItem? item;
                          if (index < visualItems.length) {
                            item = visualItems[index];
                          }

                          return ProfileListItem(
                            key: ValueKey(item?.id ?? index),
                            title: currentItems[index],
                            showCheckmark: item?.isCompleted ?? false,
                            onTap: () async {
                              if (item != null) {
                                final updatedItem = await context
                                    .push<VisualItem>(
                                      '/visual_item/${item.id}',
                                      extra: {
                                        'item': item,
                                        'stepTitle':
                                            stepData[currentStep - 1].title,
                                      },
                                    );

                                // Reload data from Firestore to get fresh state
                                if (updatedItem != null || mounted) {
                                  await _loadData(); // Reload all data to ensure consistency
                                }
                              }
                            },
                          );
                        } else if (currentStep == 3) {
                          // Marketing items
                          MarketingItem? item;
                          if (index < marketingItems.length) {
                            item = marketingItems[index];
                          }

                          return ProfileListItem(
                            key: ValueKey(item?.id ?? index),
                            title: currentItems[index],
                            showCheckmark: item?.isCompleted ?? false,
                            onTap: () async {
                              if (item != null) {
                                final updatedItem = await context
                                    .push<MarketingItem>(
                                      '/marketing_item/${item.id}',
                                      extra: {
                                        'item': item,
                                        'stepTitle':
                                            stepData[currentStep - 1].title,
                                      },
                                    );

                                if (updatedItem != null) {
                                  setState(() {
                                    final itemIndex = marketingItems.indexWhere(
                                      (e) => e.id == updatedItem.id,
                                    );
                                    if (itemIndex != -1) {
                                      marketingItems[itemIndex] = updatedItem;
                                    }
                                  });
                                }
                              }
                            },
                          );
                        } else {
                          // Placeholder for other steps
                          return ProfileListItem(
                            key: ValueKey(index),
                            title: currentItems[index],
                            showCheckmark: false,
                            onTap: () {},
                          );
                        }
                      },
                    ),
            ),
            Column(
              children: [
                Button(
                  onPressed: () {
                    if (currentStep < stepData.length) {
                      if (currentStep == 3) {
                        // Navigate to planning when moving from step 3 to step 4
                        context.push('/planning');
                      } else {
                        setState(() {
                          currentStep++;
                        });
                      }
                    }
                  },
                  text: currentStep == stepData.length
                      ? 'Complete'
                      : 'Next ${stepData[currentStep].title}',
                  height: 54.h,
                  borderRadius: BorderRadius.circular(32.r),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                  backgroundColor: currentStep == stepData.length
                      ? AppColors.brand500
                      : AppColors.brand500.withOpacity(0.1),
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

  Widget _buildPlanningButton() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 64.sp,
              color: AppColors.brand500.withOpacity(0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              'Create Your 90-Day Plan',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Plan your brand launch journey',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 32.h),
            Button(
              onPressed: _navigateToPlanning,
              text: 'Start Planning',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: AppColors.brand500,
            ),
          ],
        ),
      ),
    );
  }
}
