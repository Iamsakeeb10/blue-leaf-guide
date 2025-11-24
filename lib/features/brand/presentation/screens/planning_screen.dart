import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/custom_checkbox.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  List<bool> month1Checkboxes = [false, false, false];
  List<bool> month2Checkboxes = [false, false, false];
  List<bool> month3Checkboxes = [false, false, false, false];

  final month1Items = [
    "Finalize brand strategy, logo, and colors",
    "Create business cards and collateral",
    "Set up social media accounts",
  ];

  final month2Items = [
    "Launch website and implement SEO",
    "Begin consistent content posting",
    "Launch first email campaign",
  ];

  final month3Items = [
    "Partner with influencers",
    "Plan first event or pop-up",
    "Launch charitable initiative",
    "Analyse metrics and plan next 90 days",
  ];

  @override
  void initState() {
    super.initState();
    _loadPlanningData();
  }

  Future<void> _loadPlanningData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('planning')
          .doc('data')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          month1Checkboxes = List<bool>.from(
            data['month1'] ?? [false, false, false],
          );
          month2Checkboxes = List<bool>.from(
            data['month2'] ?? [false, false, false],
          );
          month3Checkboxes = List<bool>.from(
            data['month3'] ?? [false, false, false, false],
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading planning data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePlanningData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to save')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('planning')
          .doc('data')
          .set({
            'month1': month1Checkboxes,
            'month2': month2Checkboxes,
            'month3': month3Checkboxes,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved successfully!')));
    } catch (e) {
      print('Error saving planning data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save. Please try again.')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildCheckboxSection(
    String title,
    List<String> items,
    List<bool> checkboxes,
    Function(int, bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary.withOpacity(0.7),
            height: 1.4,
          ),
        ),
        SizedBox(height: 12.h),
        ...List.generate(items.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                CustomCheckbox(
                  value: checkboxes[index],
                  onChanged: (value) => onChanged(index, value),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Planning',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView(
                children: [
                  _buildCheckboxSection(
                    '1st Month Plan',
                    month1Items,
                    month1Checkboxes,
                    (index, value) {
                      setState(() {
                        month1Checkboxes[index] = value;
                      });
                    },
                  ),
                  _buildCheckboxSection(
                    '2nd Month Plan',
                    month2Items,
                    month2Checkboxes,
                    (index, value) {
                      setState(() {
                        month2Checkboxes[index] = value;
                      });
                    },
                  ),
                  _buildCheckboxSection(
                    '3rd Month Plan',
                    month3Items,
                    month3Checkboxes,
                    (index, value) {
                      setState(() {
                        month3Checkboxes[index] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Button(
              onPressed: _savePlanningData,
              text: _isSaving ? 'Saving...' : 'Save',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: AppColors.brand500,
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
      ),
    );
  }
}
