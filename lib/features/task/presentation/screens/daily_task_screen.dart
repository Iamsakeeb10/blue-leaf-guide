import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/custom_date_picker_dialog.dart';
import '../../../../shared/widgets/profile_item.dart';

class DailyTaskScreen extends StatefulWidget {
  const DailyTaskScreen({super.key});

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _userId;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _tasks = [];
  List<bool> _switchValues = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user == null) {
      // Handle unauthenticated state if needed
      Navigator.of(context).pop(); // or show error
      return;
    }
    _userId = user.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load task definitions from 'standalone/default'
    final standaloneDoc = await _firestore
        .collection('standalone')
        .doc('default')
        .get();
    if (!standaloneDoc.exists) {
      // Fallback to hardcoded tasks (for testing or first run)
      _tasks = [
        {"icon": "assets/icons/svg/fb.svg", "title": "Review project plan"},
        {"icon": "assets/icons/svg/insta.svg", "title": "Check emails"},
        {"icon": "assets/icons/svg/tik.svg", "title": "Team standup meeting"},
        {"icon": "assets/icons/svg/gallery.svg", "title": "Code review"},
        {"icon": "assets/icons/svg/add.svg", "title": "Update documentation"},
        {
          "icon": "assets/icons/svg/user-gradient.svg",
          "title": "Deploy updates",
        },
      ];
    } else {
      final data = standaloneDoc.data()!;
      _tasks = List<Map<String, dynamic>>.from(data['items'] ?? []);
    }

    // Initialize switch values
    _switchValues = List.generate(_tasks.length, (_) => false);

    // 2. Load user toggle state for selected date
    await _loadUserTogglesForDate(_selectedDate);

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadUserTogglesForDate(DateTime date) async {
    final formattedDate = _formatDate(date);
    final doc = await _firestore
        .collection('daily_tasks')
        .doc(_userId)
        .collection('dates')
        .doc(formattedDate)
        .get();

    if (doc.exists) {
      final toggles = List<dynamic>.from(doc.data()?['toggles'] ?? []);
      // Ensure correct length and deep copy
      _switchValues = List.generate(_tasks.length, (i) {
        if (i < toggles.length) return toggles[i] as bool;
        return false;
      });
    } else {
      _switchValues = List.generate(_tasks.length, (_) => false);
    }
  }

  Future<void> _saveToggle(int index, bool value) async {
    // Update the state with a new list reference
    setState(() {
      _switchValues = List.from(_switchValues)..[index] = value;
    });

    final formattedDate = _formatDate(_selectedDate);

    try {
      await _firestore
          .collection('daily_tasks')
          .doc(_userId)
          .collection('dates')
          .doc(formattedDate)
          .set({
            'toggles': List.from(_switchValues), // new list for Firestore
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('❌ Error saving toggle: $e');
    }
  }

  bool get _isCurrentDateEditable {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    return selected.isAtSameMomentAs(today); // Only today is editable
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formattedDateString(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _formattedDateString(_selectedDate);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
                      lastDate: todayNormalized, // ← normalized today
                    ),
                  );

                  if (selected != null && selected != _selectedDate) {
                    setState(() {
                      _selectedDate = selected;
                      _loading = true;
                    });

                    await _loadUserTogglesForDate(selected);

                    if (mounted) {
                      setState(() {
                        _loading = false;
                      });
                    }
                  }
                },
                child: Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: SvgPicture.asset(
                    'assets/icons/svg/calendar.svg',
                    fit: BoxFit.contain,
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            itemCount: _tasks.length,
            separatorBuilder: (_, __) => SizedBox(height: 4.h),
            itemBuilder: (context, index) {
              return ProfileItem(
                key: ValueKey('${_formatDate(_selectedDate)}-$index'),
                svgIconPath: _tasks[index]["icon"]!,
                iconBackgroundColor: Colors.blue.shade100,
                title: _tasks[index]["title"]!,
                value: _switchValues[index],
                onChanged: (val) => _saveToggle(index, val),
                showDivider: index != _tasks.length - 1,
                isEditable: _isCurrentDateEditable,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ===== Helper Function (Call Once During Setup/Debug) =====
Future<bool> uploadStandaloneTemplateToFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> templateItems = [
    {"icon": "assets/icons/svg/fb.svg", "title": "Review project plan"},
    {"icon": "assets/icons/svg/insta.svg", "title": "Check emails"},
    {"icon": "assets/icons/svg/tik.svg", "title": "Team standup meeting"},
    {"icon": "assets/icons/svg/gallery.svg", "title": "Code review"},
    {"icon": "assets/icons/svg/add.svg", "title": "Update documentation"},
    {"icon": "assets/icons/svg/user-gradient.svg", "title": "Deploy updates"},
  ];

  try {
    await firestore.collection('standalone').doc('default').set({
      'items': templateItems,
      'version': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Standalone task template uploaded successfully!');
    return true;
  } catch (e) {
    print('❌ Error uploading standalone template: $e');
    return false;
  }
}
