import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import 'button.dart';

class PickerResult {
  final int year;
  final int? month; // null if "All Year"

  const PickerResult({required this.year, this.month});
}

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const MonthYearPickerDialog({required this.initialDate});

  @override
  State<MonthYearPickerDialog> createState() => MonthYearPickerDialogState();
}

class MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;
  bool isAllYear = false;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    // index 0 is "All Year", then years
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

    // For year picker: index 0 is "All Year", index 1..10 maps to years
    // But user wants "All Year" in the year dropdown.
    // Let's prepend a special value or handle index 0 as "All Year".
    // Wait, "All Year" means we select a year, and we select "All Year" for month?
    // The requirement says: "Adds “All Year” to the year dropdown". 
    // And "When All Year is selected -> Month dropdown is disabled + label shows “Select”".
    // This implies "All Year" is an item in the YEAR dropdown.
    // BUT if I select "All Year" in the year dropdown, what year is it? 
    // "When All Year is selected -> Month dropdown is disabled".
    // Maybe "All Year" means "All Years"? 
    // "When a specific year (e.g., 2025) is selected -> Month dropdown enabled + shows months".
    // This implies "All Year" is mutually exclusive with "2025".
    // IF "All Year" is selected in the YEAR dropdown, then we probably don't filter by year?
    // OR does it mean "Whole Year 2025"?
    // The requirement says:
    // "Adds “All Year” to the year dropdown"
    // "When All Year is selected -> Month dropdown is disabled + label shows “Select”"
    // "When a specific year (e.g., 2025) is selected -> Month dropdown enabled + shows months"
    
    // Rereading carefully: "Adds 'All Year' to the year dropdown".
    // If I select "All Year", typically that means "No specific year" or "All time"?
    // BUT usually usage is "Filter by: Year 2025, Month: All".
    // OR "Filter by: Time: All Year" (meaning all history?).
    
    // Context: Monthly Goals.
    // If I select "All Year", I probably want to see ALL goals ever? Or goals for all years?
    // However, the second point "When All Year is selected -> Month dropdown is disabled" strongly suggests "All Year" is a distict mode.
    // Let's assume "All Year" in the YEAR dropdown means "Ignore Year and Month" (Show everything)?
    // OR does it mean "Select a Year, then select 'All months' in month dropdown?"
    // User said: "Adds “All Year” to the year dropdown".
    // And: "When All Year is selected → Month dropdown is disabled".
    
    // Let's implement exactly as requested: "All Year" is an option in the Year picker.
    // When selected, internal state `isAllYear` = true.
    
    final yearItems = ["All Year", ...years.map((y) => y.toString())];
    
    // Calculate initial item for year picker
    int initialYearIndex;
    if (isAllYear) {
      initialYearIndex = 0;
    } else {
      final yIndex = years.indexOf(selectedYear);
      initialYearIndex = yIndex >= 0 ? yIndex + 1 : 1; // +1 because "All Year" is at 0
    }

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
                      child: IgnorePointer(
                        ignoring: isAllYear,
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
                          children: isAllYear 
                              ? [
                                  Center(
                                    child: Text(
                                      "Select",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary.withOpacity(0.3),
                                      ),
                                    ),
                                  )
                                ]
                              : months.map((month) {
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
                          initialItem: initialYearIndex,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            if (index == 0) {
                              // "All Year" selected
                              isAllYear = true;
                              // We don't change selectedYear, just the mode
                            } else {
                              isAllYear = false;
                              selectedYear = years[index - 1];
                            }
                          });
                        },
                        children: yearItems.map((item) {
                          return Center(
                            child: Text(
                              item,
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
                      if (isAllYear) {
                         Navigator.pop(
                          context,
                          PickerResult(year: -1, month: null), // -1 or ignore year? 
                          // If "All Year" means "All time", then yes.
                          // But typically "All Year" means "Whole specific year".
                          // BUT "All Year" is in the YEAR dropdown.
                          // If I select "All Year" instead of "2025", surely it means "All years"?
                          
                          // Wait, if I want "Whole 2025", I would select "2025" and "All Months"?
                          // But the requirement says: "Adds 'All Year' to the YEAR dropdown".
                          // And "When 'All Year' is selected -> Month dropdown is disabled".
                          // This strongly implies: Select "All Year" -> No specific year, no specific month.
                          
                          // LET'S CONFIRM with logic.
                          // If user wants to see "All goals for 2025", they need "2025" + "All Months".
                          // But if "All Year" is in the YEAR dropdown, then it competes with "2025".
                          // So "All Year" likely means "Show me everything regardless of year".
                          
                          // Actually, looking at "When a specific year (e.g., 2025) is selected -> Month dropdown enabled + shows months".
                          // This implies if I select 2025, I MUST select a month?
                          // The current UI has months "January, February...". It DOES NOT have "All Months".
                          // So currently the user MUST select a specific month for a specific year.
                          
                          // So if I add "All Year" to the YEAR dropdown, it lets me filter by... NOTHING? (All history?)
                          // OR is the user asking for "All of 2025"?
                          // "Adds 'All Year' to the year dropdown"
                          // If I select it, Month is disabled.
                          // This sounds like "All Time".
                          
                          // However, "All Year" is a weird label for "All Time". "All Time" would be better.
                          // Could "All Year" mean "The Entire Current Year"? No, because it's in the dropdown where 2025 is.
                          
                          // Result: I will interpret "All Year" as "All Time" (no year filter, no month filter).
                        );
                      } else {
                        Navigator.pop(
                          context,
                          PickerResult(year: selectedYear, month: selectedMonth),
                        );
                      }
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
