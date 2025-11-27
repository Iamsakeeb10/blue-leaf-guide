import 'package:blue_leaf_guide/shared/widgets/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/month_year_picker_dialog.dart';
import '../../../task/presentation/widgets/edit_goal_dialog.dart';
import '../../../task/presentation/widgets/monthly_goals_list.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<int, String> orderSuffixMap = {
    1: 'distributed',
    2: 'acquired',
    3: 'earned',
    4: 'posted',
    5: 'attended',
  };

  DateTime _selectedDate = DateTime.now();

  Future<void> _showEditGoalDialog(
    String goalId,
    String currentTitle,
    int currentTarget,
  ) async {
    await EditGoalDialog.show(
      context: context,
      currentTitle: currentTitle,
      currentTarget: currentTarget,
      onSave: (newTarget) async {
        await _updateGoal(goalId, newTarget);
      },
    );
  }

  Future<void> _updateGoal(String goalId, int newTarget) async {
    if (_auth.currentUser == null) return;

    try {
      final userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_goals')
          .doc(goalId)
          .update({
            'targetNumber': newTarget,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Goal updated successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.timelinePrimary,
        ),
      );
    } catch (e) {
      print('Error updating goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update goal: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    if (_auth.currentUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_goals')
          .doc(goalId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Goal deleted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.timelinePrimary,
        ),
      );
    } catch (e) {
      print('Error deleting goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete goal: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  String _getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  // ignore: unused_element
  void _showMonthYearPicker() async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => MonthYearPickerDialog(initialDate: _selectedDate),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser!.uid;
    final monthKey = _getMonthKey(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Progress & Rewards'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // Stats Cards Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: '🔥',
                      title: 'Current Streak',
                      value: '5 days',
                      backgroundColor: AppColors.backgroundLight,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: '🎯',
                      title: 'Goal Completed',
                      value: '3 months',
                      backgroundColor: AppColors.brand50,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: '✓',
                      title: 'Brand Build',
                      value: 'Completed',
                      backgroundColor: AppColors.backgroundGreenLight,
                      iconColor: Colors.green,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      icon: '👥',
                      title: 'Client Served',
                      value: '15',
                      backgroundColor: AppColors.backgroundPurpleLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            // Goal Completion Rate Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(0.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Goal completion rate',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.textPrimary.withOpacity(0.05),
                          ),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Monthly',
                              style: TextStyle(
                                color: AppColors.textPrimary.withOpacity(0.8),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16.sp,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Average goal completion rate',
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '58.3%',
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.8),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildBarChart(),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            // Task Completion Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task completion',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      _buildDropdown('November'),
                      SizedBox(width: 8.w),
                      _buildDropdown('2025'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: MonthlyGoalsList(
                userId: userId,
                monthKey: monthKey,
                onAddGoal: () {},
                onEditGoal: (goalId, title, target) async {
                  await _showEditGoalDialog(goalId, title, target);
                },
                onDeleteGoal: _deleteGoal,
                orderSuffixMap: orderSuffixMap,
              ),
            ),
            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          if (iconColor != null)
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 24.sp),
            )
          else
            Text(icon, style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final values = [0.75, 0.0, 0.42, 1.0, 0.0, 0.32, 0.65];

    return SizedBox(
      height: 180.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildAxisLabel('100%'),
              _buildAxisLabel('75%'),
              _buildAxisLabel('50%'),
              _buildAxisLabel('25%'),
              _buildAxisLabel('0%'),
            ],
          ),
          SizedBox(width: 12.w),
          // Bars
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 16.w,
                          height: 150.h * values[index],
                          decoration: BoxDecoration(color: AppColors.brand500),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          months[index],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildDropdown(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.textPrimary.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.keyboard_arrow_down, size: 16.sp, color: Colors.black),
        ],
      ),
    );
  }
}
