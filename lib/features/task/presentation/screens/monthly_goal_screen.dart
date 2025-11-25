import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;

class MonthlyGoalScreen extends StatefulWidget {
  const MonthlyGoalScreen({super.key});

  @override
  State<MonthlyGoalScreen> createState() => _MonthlyGoalScreenState();
}

class _MonthlyGoalScreenState extends State<MonthlyGoalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _goalTemplates = [];
  bool _isLoadingTemplates = true;

  @override
  void initState() {
    super.initState();
    _loadGoalTemplates();
  }

  String _getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  Future<void> _loadGoalTemplates() async {
    try {
      final templatesSnapshot = await _firestore
          .collection('goal_templates')
          .orderBy('order')
          .get();

      _goalTemplates = templatesSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'fullTitle': doc.data()['fullTitle'] ?? '',
          'shortTitle': doc.data()['shortTitle'] ?? '',
        };
      }).toList();

      setState(() => _isLoadingTemplates = false);
    } catch (e) {
      print('Error loading goal templates: $e');
      setState(() => _isLoadingTemplates = false);
    }
  }

  Future<void> _showAddGoalDialog() async {
    if (_isLoadingTemplates) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading goal templates...')),
      );
      return;
    }

    String? selectedTemplateId;
    final targetController = TextEditingController();

    await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36.r),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Text(
                  'Add New Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 20.h),

                /// Goal Name Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Goal Name',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                /// Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.neutral50.withOpacity(0.05),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedTemplateId,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Text(
                          'Select a goal',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary.withOpacity(0.3),
                          ),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      borderRadius: BorderRadius.circular(16.r),
                      items: _goalTemplates.map((template) {
                        return DropdownMenuItem<String>(
                          value: template['id'],
                          child: Text(
                            template['fullTitle'],
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedTemplateId = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                /// Target Number Field
                CustomTextField.TextField(
                  controller: targetController,
                  label: 'Target Number',
                  hint: 'Enter target',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20.h),

                /// Save Button
                Button(
                  onPressed: () async {
                    if (selectedTemplateId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a goal')),
                      );
                      return;
                    }

                    final target = int.tryParse(targetController.text);
                    if (target == null || target <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid target number'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context, true);
                    await _addGoal(selectedTemplateId!, target);
                  },
                  text: 'Save',
                  height: 54.h,
                  borderRadius: BorderRadius.circular(32.r),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                  backgroundColor: AppColors.brand500,
                ),
                SizedBox(height: 12.h),

                /// Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
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
        ),
      ),
    );
  }

  Future<void> _addGoal(String templateId, int target) async {
    if (_auth.currentUser == null) return;

    try {
      final userId = _auth.currentUser!.uid;
      final monthKey = _getMonthKey(_selectedDate);

      final template = _goalTemplates.firstWhere((t) => t['id'] == templateId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_goals')
          .add({
            'templateId': templateId,
            'fullTitle': template['fullTitle'],
            'shortTitle': template['shortTitle'],
            'targetNumber': target,
            'currentProgress': 0,
            'month': monthKey,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Goal added successfully!')));
    } catch (e) {
      print('Error adding goal: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add goal: $e')));
    }
  }

  Future<void> _showEditGoalDialog(
    String goalId,
    String currentTitle,
    int currentTarget,
  ) async {
    final targetController = TextEditingController(
      text: currentTarget.toString(),
    );

    await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36.r),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Title
              Text(
                'Edit Goal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),

              /// Subtitle (Goal Name)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: Text(
                  'Goal: $currentTitle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Target Number Field
              CustomTextField.TextField(
                controller: targetController,
                label: 'Target Number',
                hint: 'Enter target',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.h),

              /// Save Button
              Button(
                onPressed: () async {
                  final target = int.tryParse(targetController.text);
                  if (target == null || target <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid target number'),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, true);
                  await _updateGoal(goalId, target);
                },
                text: 'Save',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
                backgroundColor: AppColors.brand500,
              ),
              SizedBox(height: 12.h),

              /// Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
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
      ),
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
        const SnackBar(content: Text('Goal updated successfully!')),
      );
    } catch (e) {
      print('Error updating goal: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update goal: $e')));
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
        const SnackBar(content: Text('Goal deleted successfully!')),
      );
    } catch (e) {
      print('Error deleting goal: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete goal: $e')));
    }
  }

  void _showMonthYearPicker() async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => _MonthYearPickerDialog(initialDate: _selectedDate),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      return const Center(child: Text('Please log in to view goals'));
    }

    final userId = _auth.currentUser!.uid;
    final monthKey = _getMonthKey(_selectedDate);

    return Column(
      children: [
        // Header with date and filter
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Track your monthly goals',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showMonthYearPicker,
                child: Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: Icon(
                    Icons.filter_list,
                    size: 24.w,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Goals list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(userId)
                .collection('monthly_goals')
                .where('month', isEqualTo: monthKey)
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final goals = snapshot.data?.docs ?? [];

              // Sort by createdAt in the app instead of in the query
              goals.sort((a, b) {
                final aCreated = a.data() as Map<String, dynamic>;
                final bCreated = b.data() as Map<String, dynamic>;
                final aTime = aCreated['createdAt'] as Timestamp?;
                final bTime = bCreated['createdAt'] as Timestamp?;

                if (aTime == null || bTime == null) return 0;
                return aTime.compareTo(bTime);
              });

              if (goals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 64.w,
                        color: AppColors.textPrimary.withOpacity(0.2),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No goals yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Add your first monthly goal',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: goals.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final goal = goals[index].data() as Map<String, dynamic>;
                  final goalId = goals[index].id;
                  final fullTitle = goal['fullTitle'] ?? '';
                  final target = goal['targetNumber'] ?? 0;
                  final progress = goal['currentProgress'] ?? 0;
                  final progressPercentage = target > 0
                      ? (progress / target).clamp(0.0, 1.0)
                      : 0.0;

                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.neutral50.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                fullTitle,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                size: 20.w,
                                color: AppColors.textPrimary.withOpacity(0.6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditGoalDialog(
                                    goalId,
                                    fullTitle,
                                    target,
                                  );
                                } else if (value == 'delete') {
                                  _deleteGoal(goalId);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18.w),
                                      SizedBox(width: 8.w),
                                      const Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18.w,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8.w),
                                      const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Text(
                              'Target: ',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              target.toString(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brand500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: LinearProgressIndicator(
                                  value: progressPercentage,
                                  minHeight: 10.h,
                                  backgroundColor: AppColors.neutral50
                                      .withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progressPercentage >= 1.0
                                        ? Colors.green
                                        : AppColors.brand500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '$progress / $target',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Add Goal Button
        Button(
          onPressed: _showAddGoalDialog,
          text: 'Add New Goal',
          height: 54.h,
          borderRadius: BorderRadius.circular(32.r),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          textColor: Colors.white,
          backgroundColor: AppColors.brand500,
        ),
      ],
    );
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _MonthYearPickerDialog({required this.initialDate});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => currentYear - 5 + index);
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        height: 320.h,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Text(
              "Select Month & Year",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// MONTH PICKER
                    SizedBox(
                      width: 120.w,
                      child: CupertinoPicker(
                        itemExtent: 32.h,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth - 1,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedMonth = index + 1;
                          });
                        },
                        children: months.map((month) {
                          return Center(
                            child: Text(
                              month,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Text(
                      ":",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    /// YEAR PICKER
                    SizedBox(
                      width: 80.w,
                      child: CupertinoPicker(
                        itemExtent: 32.h,
                        scrollController: FixedExtentScrollController(
                          initialItem: years.indexOf(selectedYear),
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedYear = years[index];
                          });
                        },
                        children: years.map((year) {
                          return Center(
                            child: Text(
                              year.toString(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h),
              child: Column(
                children: [
                  Button(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        DateTime(selectedYear, selectedMonth),
                      );
                    },
                    text: 'View Month Goal',
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
            ),
          ],
        ),
      ),
    );
  }
}
