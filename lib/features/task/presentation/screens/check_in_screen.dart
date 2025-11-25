import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/custom_date_picker_dialog.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/text_field.dart' as CustomTextField;

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _dynamicGoals = [];

  // Static reflection controllers
  final Map<String, TextEditingController> reflectionControllers = {
    'todaysWin': TextEditingController(),
    'challengesAndLessons': TextEditingController(),
    'additionalNotes': TextEditingController(),
  };

  final Map<String, String> reflectionKeys = {
    'todaysWin': "Today's win",
    'challengesAndLessons': 'Challenges and lessons',
    'additionalNotes': 'Additional notes',
  };

  final Map<String, String> reflectionHints = {
    'todaysWin': 'What went well today? What are you proud of?',
    'challengesAndLessons': 'What didn\'t go as planned? What did you learn?',
    'additionalNotes': 'Any other thoughts or reminders?',
  };

  // Dynamic goal controllers
  Map<String, TextEditingController> dynamicControllers = {};

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in reflectionControllers.values) {
      controller.dispose();
    }
    for (var controller in dynamicControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  bool _isToday() {
    final today = DateTime.now();
    return _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
  }

  Future<void> _loadData() async {
    if (_auth.currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser!.uid;
      final dateKey = _getDateKey(_selectedDate);

      // Load user's active goals for current month
      final currentMonth = DateFormat('yyyy-MM').format(_selectedDate);
      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_goals')
          .where('month', isEqualTo: currentMonth)
          .where('isActive', isEqualTo: true)
          .get();

      _dynamicGoals = goalsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'shortTitle': doc.data()['shortTitle'] ?? '',
          'fullTitle': doc.data()['fullTitle'] ?? '',
        };
      }).toList();

      // Initialize dynamic controllers
      dynamicControllers.clear();
      for (var goal in _dynamicGoals) {
        dynamicControllers[goal['id']] = TextEditingController();
      }

      // Load check-in data for selected date
      final checkInDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('check_ins')
          .doc(dateKey)
          .get();

      if (checkInDoc.exists) {
        final data = checkInDoc.data()!;

        // Load static fields
        reflectionControllers['todaysWin']?.text = data['todaysWin'] ?? '';
        reflectionControllers['challengesAndLessons']?.text =
            data['challengesAndLessons'] ?? '';
        reflectionControllers['additionalNotes']?.text =
            data['additionalNotes'] ?? '';

        // Load dynamic fields
        final dynamicData =
            data['dynamicFields'] as Map<String, dynamic>? ?? {};
        for (var entry in dynamicData.entries) {
          if (dynamicControllers.containsKey(entry.key)) {
            dynamicControllers[entry.key]?.text = entry.value.toString();
          }
        }
      } else {
        // Clear all fields for new date
        for (var controller in reflectionControllers.values) {
          controller.clear();
        }
        for (var controller in dynamicControllers.values) {
          controller.clear();
        }
      }
    } catch (e) {
      print('Error loading check-in data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCheckIn() async {
    if (_auth.currentUser == null || !_isToday()) return;

    setState(() => _isSaving = true);

    try {
      final userId = _auth.currentUser!.uid;
      final dateKey = _getDateKey(_selectedDate);

      // Prepare dynamic fields data
      Map<String, dynamic> dynamicFieldsData = {};
      for (var entry in dynamicControllers.entries) {
        final value = int.tryParse(entry.value.text) ?? 0;
        dynamicFieldsData[entry.key] = value;
      }

      // Save check-in data
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('check_ins')
          .doc(dateKey)
          .set({
            'todaysWin': reflectionControllers['todaysWin']?.text ?? '',
            'challengesAndLessons':
                reflectionControllers['challengesAndLessons']?.text ?? '',
            'additionalNotes':
                reflectionControllers['additionalNotes']?.text ?? '',
            'dynamicFields': dynamicFieldsData,
            'date': _selectedDate,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Update monthly goal progress
      for (var entry in dynamicFieldsData.entries) {
        final goalId = entry.key;
        final value = entry.value as int;

        if (value > 0) {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('monthly_goals')
              .doc(goalId)
              .update({
                'currentProgress': FieldValue.increment(value),
                'updatedAt': FieldValue.serverTimestamp(),
              });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in saved successfully!')),
      );
    } catch (e) {
      print('Error saving check-in: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildDynamicFields() {
    if (_dynamicGoals.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> rows = [];

    for (int i = 0; i < _dynamicGoals.length; i += 2) {
      if (i + 1 < _dynamicGoals.length) {
        // Two fields in a row
        rows.add(
          Row(
            children: [
              Expanded(
                child: CustomTextField.TextField(
                  controller: dynamicControllers[_dynamicGoals[i]['id']]!,
                  label: _dynamicGoals[i]['shortTitle'],
                  hint: '0',
                  enabled: _isToday(),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomTextField.TextField(
                  controller: dynamicControllers[_dynamicGoals[i + 1]['id']]!,
                  label: _dynamicGoals[i + 1]['shortTitle'],
                  hint: '0',
                  enabled: _isToday(),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        );
      } else {
        // Single field (odd one)
        rows.add(
          CustomTextField.TextField(
            controller: dynamicControllers[_dynamicGoals[i]['id']]!,
            label: _dynamicGoals[i]['shortTitle'],
            hint: '0',
            enabled: _isToday(),
            keyboardType: TextInputType.number,
          ),
        );
      }

      if (i < _dynamicGoals.length - 1) {
        rows.add(SizedBox(height: 12.h));
      }
    }

    return Column(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's activity",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  final todayNormalized = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );

                  final selected = await showDialog<DateTime>(
                    context: context,
                    builder: (_) => CustomDatePickerDialog(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: todayNormalized,
                    ),
                  );

                  if (selected != null && selected != _selectedDate) {
                    setState(() {
                      _selectedDate = selected;
                    });
                    _loadData();
                  }
                },
                child: Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  padding: EdgeInsets.all(10.w),
                  child: SvgPicture.asset(
                    'assets/icons/svg/calendar.svg',
                    fit: BoxFit.contain,
                    width: 24.w,
                    height: 24.h,
                    colorFilter: ColorFilter.mode(
                      AppColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Dynamic fields based on user goals
          _buildDynamicFields(),
          if (_dynamicGoals.isNotEmpty) SizedBox(height: 12.h),

          // Static reflection fields
          for (var entry in reflectionControllers.entries)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reflectionKeys[entry.key] ?? entry.key,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: entry.value,
                  maxLines: 5,
                  minLines: 4,
                  enabled: _isToday(),
                  decoration: InputDecoration(
                    hintText: reflectionHints[entry.key],
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textPrimary.withOpacity(0.3),
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: _isToday() ? Colors.white : Colors.grey[100],
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(14.w),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.neutral50.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide(
                        color: AppColors.neutral50.withOpacity(0.05),
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
                SizedBox(height: 16.h),
              ],
            ),
          SizedBox(height: 12.h),

          if (_isToday())
            Button(
              onPressed: _isSaving ? null : _saveCheckIn,
              text: 'Save',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: AppColors.brand500,
              isLoading: _isSaving,
            )
          else
            Container(
              height: 54.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(32.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'View Only - Past Date',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
