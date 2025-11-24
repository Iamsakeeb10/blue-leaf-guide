import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';

class ColorPalettePickerScreen extends StatefulWidget {
  final List<String> existingColors;

  const ColorPalettePickerScreen({this.existingColors = const [], super.key});

  @override
  State<ColorPalettePickerScreen> createState() =>
      _ColorPalettePickerScreenState();
}

class _ColorPalettePickerScreenState extends State<ColorPalettePickerScreen> {
  int? selectedPaletteIndex;

  // Predefined color palettes (4 colors each)
  final List<List<String>> palettes = [
    // Palette 1 - Soft Pastels
    ['FFB5C5', 'E8D5C4', 'C9B8D4', 'A8D8EA'],
    // Palette 2 - Earth Tones
    ['8B7355', 'D4A574', 'E8C4A0', 'F5E6D3'],
    // Palette 3 - Ocean Blues
    ['1E3A5F', '2E5984', '4A90A4', '8EC3D9'],
    // Palette 4 - Warm Sunset
    ['FF6B6B', 'FFB347', 'FFC857', 'F4A261'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Color Palette'),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Expanded(
              child: ListView.builder(
                itemCount: palettes.length,
                itemBuilder: (context, index) {
                  final palette = palettes[index];
                  final isSelected = selectedPaletteIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaletteIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brand500
                              : AppColors.neutral50.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.brand500.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Palette ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: palette.map((colorHex) {
                                    return Container(
                                      width: 50.w,
                                      height: 50.w,
                                      margin: EdgeInsets.only(right: 8.w),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          int.parse('0xff$colorHex'),
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.neutral50
                                              .withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.brand500,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Button(
              onPressed: selectedPaletteIndex == null
                  ? null
                  : () {
                      if (selectedPaletteIndex != null) {
                        Navigator.of(
                          context,
                        ).pop(palettes[selectedPaletteIndex!]);
                      }
                    },
              text: 'Add as brand color',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: selectedPaletteIndex != null
                  ? AppColors.brand500
                  : AppColors.brand500.withOpacity(0.3),
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
    );
  }
}
