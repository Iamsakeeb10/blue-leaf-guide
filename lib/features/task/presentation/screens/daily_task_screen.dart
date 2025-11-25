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
  // Keep state for 6 switches
  final List<bool> switchValues = List.generate(6, (_) => false);
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final profileItems = [
      {"icon": "assets/icons/svg/fb.svg", "title": "Review project plan"},
      {"icon": "assets/icons/svg/insta.svg", "title": "Check emails"},
      {"icon": "assets/icons/svg/tik.svg", "title": "Team standup meeting"},
      {"icon": "assets/icons/svg/gallery.svg", "title": "Code review"},
      {"icon": "assets/icons/svg/add.svg", "title": "Update documentation"},
      {"icon": "assets/icons/svg/user-gradient.svg", "title": "Deploy updates"},
    ];

    String formattedDate =
        "${_selectedDate.day.toString().padLeft(2, '0')} "
        "${_monthString(_selectedDate.month)}, ${_selectedDate.year}";

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
                  final selected = await showDialog<DateTime>(
                    context: context,
                    builder: (_) => CustomDatePickerDialog(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    ),
                  );

                  if (selected != null) {
                    print("Selected date: $selected");
                    setState(() {
                      _selectedDate = selected;
                    });
                  }
                },
                child: Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  padding: EdgeInsets.all(
                    8.w,
                  ), // <-- add padding inside container
                  child: SvgPicture.asset(
                    'assets/icons/svg/calendar.svg',
                    fit: BoxFit.contain, // <-- scale down to fit container
                    width: 24.w,
                    height: 24.h,
                    // remove width/height here, let padding control size
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            itemCount: profileItems.length,
            separatorBuilder: (_, __) => SizedBox(height: 4.h),
            itemBuilder: (context, index) {
              return ProfileItem(
                svgIconPath: profileItems[index]["icon"]!,
                iconBackgroundColor: Colors.blue.shade100,
                title: profileItems[index]["title"]!,
                value: switchValues[index],
                onChanged: (val) {
                  setState(() {
                    switchValues[index] = val;
                  });
                },
                showDivider: index != profileItems.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  String _monthString(int month) {
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
    return months[month - 1];
  }
}
