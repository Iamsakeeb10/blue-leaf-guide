import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/profile_list_item.dart';
import '../../data/marketing_service.dart';
import '../../data/planning_service.dart';
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
  final PlanningService _planningService = PlanningService();

  List<StrategyItem> strategyItems = [];
  List<MarketingItem> marketingItems = [];
  final VisualService _visualService = VisualService();
  List<VisualItem> visualItems = [];

  // Planning data
  List<bool> planningMonth1 = [false, false, false];
  List<bool> planningMonth2 = [false, false, false];
  List<bool> planningMonth3 = [false, false, false, false];

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

  /// Call after updating lists to auto-advance when the current step is fully completed.
  void _maybeAdvanceStep() {
    if (!mounted) return;

    if (currentStep == 1) {
      final allDone =
          strategyItems.isNotEmpty && strategyItems.every((s) => s.isCompleted);
      if (allDone && currentStep < stepData.length) {
        setState(() => currentStep = 2);
      }
    } else if (currentStep == 2) {
      final allDone =
          visualItems.isNotEmpty && visualItems.every((v) => v.isCompleted);
      if (allDone && currentStep < stepData.length) {
        setState(() => currentStep = 3);
      }
    } else if (currentStep == 3) {
      final allDone =
          marketingItems.isNotEmpty &&
          marketingItems.every((m) => m.isCompleted);
      if (allDone) {
        // go to Planning (step 4)
        context.push('/planning');
      }
    }
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
      final planning = await _planningService.getPlanningData(userId);

      setState(() {
        strategyItems = strategy;
        marketingItems = marketing;
        visualItems = visual;
        planningMonth1 = planning['month1'] ?? [false, false, false];
        planningMonth2 = planning['month2'] ?? [false, false, false];
        planningMonth3 = planning['month3'] ?? [false, false, false, false];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _isStepCompleted(int stepNumber) {
    // Step numbers are 1-based
    switch (stepNumber) {
      case 1: // Strategy
        return strategyItems.isNotEmpty &&
            strategyItems.every((item) => item.isCompleted);
      case 2: // Visual
        return visualItems.isNotEmpty &&
            visualItems.every((item) => item.isCompleted);
      case 3: // Marketing
        return marketingItems.isNotEmpty &&
            marketingItems.every((item) => item.isCompleted);
      case 4: // Planning - check if all checkboxes are completed
        return _planningService.isAllCheckboxesCompleted(
          planningMonth1,
          planningMonth2,
          planningMonth3,
        );
      default:
        return false;
    }
  }

  /// Navigate to planning screen and handle the returned data
  Future<void> _navigateToPlanning() async {
    final result = await context.push<Map<String, List<bool>>>('/planning');

    // If planning data was returned, update local state and refresh stepper
    if (result != null && mounted) {
      setState(() {
        planningMonth1 = result['month1'] ?? planningMonth1;
        planningMonth2 = result['month2'] ?? planningMonth2;
        planningMonth3 = result['month3'] ?? planningMonth3;
      });
    }
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
                completedSteps: [
                  _isStepCompleted(1),
                  _isStepCompleted(2),
                  _isStepCompleted(3),
                  _isStepCompleted(4),
                ],
                onStepTap: (stepNumber) {
                  // Allow going back to any previous step
                  if (stepNumber < currentStep) {
                    setState(() {
                      currentStep = stepNumber;
                    });
                  } else if (stepNumber == currentStep) {
                    // Already on this step, do nothing
                    return;
                  } else {
                    // Going forward: check if current step is completed
                    if (_isStepCompleted(currentStep)) {
                      if (stepNumber == 4) {
                        _navigateToPlanning();
                      } else {
                        setState(() {
                          currentStep = stepNumber;
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete all items in the current step first.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: ListView.builder(
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
                        if (item == null) return;

                        final updatedItem = await context.push<StrategyItem>(
                          '/strategy_item/${item.id}',
                          extra: {
                            'item': item,
                            'stepTitle': stepData[currentStep - 1].title,
                          },
                        );

                        // If the detail screen returned an updated item (user saved / popped with updated model)
                        if (updatedItem != null && mounted) {
                          setState(() {
                            final itemIndex = strategyItems.indexWhere(
                              (e) => e.id == updatedItem.id,
                            );
                            if (itemIndex != -1) {
                              strategyItems[itemIndex] = updatedItem;
                            }
                          });

                          // Try to advance step if all items are completed now
                          _maybeAdvanceStep();
                        }
                      },
                    );
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
                          final updatedItem = await context.push<VisualItem>(
                            '/visual_item/${item.id}',
                            extra: {
                              'item': item,
                              'stepTitle': stepData[currentStep - 1].title,
                            },
                          );

                          // ✅ Update the item in the list immediately
                          if (updatedItem != null && mounted) {
                            setState(() {
                              final itemIndex = visualItems.indexWhere(
                                (e) => e.id == updatedItem.id,
                              );
                              if (itemIndex != -1) {
                                visualItems[itemIndex] = updatedItem;
                              }
                            });
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
                          final updatedItem = await context.push<MarketingItem>(
                            '/marketing_item/${item.id}',
                            extra: {
                              'item': item,
                              'stepTitle': stepData[currentStep - 1].title,
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
                      if (!_isStepCompleted(currentStep)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please complete all items in the current step first.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      if (currentStep == 3) {
                        _navigateToPlanning();
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
                  backgroundColor: _isStepCompleted(currentStep)
                      ? AppColors.brand500
                      : AppColors.brand500.withOpacity(0.3),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      if (currentStep < stepData.length) {
                        if (currentStep == 3) {
                          // Navigate to planning when moving from step 3 to step 4
                          _navigateToPlanning();
                        } else {
                          setState(() {
                            currentStep++;
                          });
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      'Skip',
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
