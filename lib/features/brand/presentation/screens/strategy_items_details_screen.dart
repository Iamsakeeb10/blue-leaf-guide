import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../data/strategy_service.dart';
import '../../models/strategy_item.dart';

class StrategyItemDetailScreen extends StatefulWidget {
  final StrategyItem item;
  final String stepTitle;
  const StrategyItemDetailScreen({
    required this.item,
    required this.stepTitle,
    super.key,
  });

  @override
  State<StrategyItemDetailScreen> createState() =>
      _StrategyItemDetailScreenState();
}

class _StrategyItemDetailScreenState extends State<StrategyItemDetailScreen> {
  late StrategyItem editableItem;
  final StrategyService _strategyService = StrategyService();
  bool _isSaving = false;
  Map<int, TextEditingController> _textControllers = {};

  @override
  void dispose() {
    _textControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  // Dropdown options
  final List<String> ageRanges = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
  ];

  final List<String> incomeLevels = [
    '25k',
    '50k',
    '75k',
    '100k',
    '150k',
    '200k+',
  ];

  @override
  void initState() {
    super.initState();
    editableItem = StrategyItem(
      id: widget.item.id,
      title: widget.item.title,
      sections: widget.item.sections
          .map(
            (s) => StrategySection(
              subtitle: s.subtitle,
              bullets: s.bullets,
              isTextField: s.isTextField,
              fieldType: s.fieldType,
              userInputs: List.from(s.userInputs),
            ),
          )
          .toList(),
      isCompleted: widget.item.isCompleted,
    );
  }

  bool canSave() {
    if (editableItem.id == "branding_basics") return true;

    for (var section in editableItem.sections) {
      if (section.isTextField) {
        if (section.fieldType == 'chips') {
          // Brand personality requires at least 1 selection
          if (section.userInputs.isEmpty) return false;
        } else if (section.userInputs.isEmpty ||
            section.userInputs.any((e) => e.isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  Future<void> _saveItem() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please login to save')));
      return;
    }

    setState(() => _isSaving = true);

    editableItem.isCompleted = canSave();

    final success = await _strategyService.saveStrategyItem(
      userId,
      editableItem,
    );

    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop(editableItem);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save. Please try again.')),
      );
    }
  }

  Widget _buildSection(StrategySection section, int sectionIndex) {
    if (section.fieldType == 'chips') {
      return _buildChipSection(section, sectionIndex);
    } else if (section.fieldType == 'dropdown') {
      // Check if next section is also a dropdown
      final isNextDropdown =
          sectionIndex + 1 < editableItem.sections.length &&
          editableItem.sections[sectionIndex + 1].fieldType == 'dropdown';

      // Check if this is the second dropdown in a pair
      final isPreviousDropdown =
          sectionIndex > 0 &&
          editableItem.sections[sectionIndex - 1].fieldType == 'dropdown';

      if (isNextDropdown) {
        // This is the first dropdown, combine with next
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownSection(section, sectionIndex),
                SizedBox(width: 12.w),
                _buildDropdownSection(
                  editableItem.sections[sectionIndex + 1],
                  sectionIndex + 1,
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        );
      } else if (isPreviousDropdown) {
        // This is the second dropdown, already rendered in the row above
        return SizedBox.shrink();
      } else {
        // Single dropdown, full width
        return Column(
          children: [
            _buildDropdownSection(section, sectionIndex),
            SizedBox(height: 24.h),
          ],
        );
      }
    } else if (section.isTextField) {
      return _buildTextFieldSection(section, sectionIndex);
    } else {
      return _buildStaticSection(section);
    }
  }

  Widget _buildDropdownSection(StrategySection section, int sectionIndex) {
    List<String> options = [];
    if (section.subtitle.toLowerCase().contains('age')) {
      options = ageRanges;
    } else if (section.subtitle.toLowerCase().contains('income')) {
      options = incomeLevels;
    }

    String? currentValue = section.userInputs.isNotEmpty
        ? section.userInputs[0]
        : null;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(
                color: AppColors.neutral50.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<String>(
              key: ValueKey('dropdown_$sectionIndex'),
              value: currentValue,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
                hintText: "Select...",
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textPrimary.withOpacity(0.3),
                  fontWeight: FontWeight.w500,
                ),
              ),
              isExpanded: true,
              icon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textPrimary.withOpacity(0.5),
                  size: 24.sp,
                ),
              ),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              elevation: 8,
              menuMaxHeight: 300.h,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    section.userInputs = [value];
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(StrategySection section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: section.bullets.map((trait) {
            final isSelected = section.userInputs.contains(trait);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    section.userInputs.remove(trait);
                  } else {
                    section.userInputs.add(trait);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEFE5FA)
                      : const Color(0xFF090F05).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Text(
                  trait,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildTextFieldSection(StrategySection section, int sectionIndex) {
    if (!_textControllers.containsKey(sectionIndex)) {
      _textControllers[sectionIndex] = TextEditingController(
        text: section.userInputs.isNotEmpty ? section.userInputs[0] : '',
      );
    }

    final controller = _textControllers[sectionIndex]!;

    // Determine number of lines
    final subtitleLower = section.subtitle.toLowerCase();
    print('🟨 Subtitel $subtitleLower');

    final isMultiLine =
        subtitleLower.contains('story') ||
        subtitleLower.contains('vision') ||
        subtitleLower.contains('mission');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtitleLower != 'your brand story')
          Text(
            section.subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withOpacity(0.7),
              height: 1.4,
            ),
          ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: isMultiLine ? 5 : 1,
          minLines: isMultiLine ? 4 : 1,
          decoration: InputDecoration(
            hintText: "Write your reflection here...",
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary.withOpacity(0.3),
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white,
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.all(14.w),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppColors.neutral50.withOpacity(0.05),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.brand500, width: 1.5),
            ),
          ),
          onChanged: (value) {
            if (section.userInputs.isEmpty) {
              section.userInputs.add(value);
            } else {
              section.userInputs[0] = value;
            }
            setState(() {}); // Trigger rebuild to update canSave button state
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildStaticSection(StrategySection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(16.r),
          ),
          margin: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: section.bullets
                .map(
                  (bullet) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "•",
                          style: TextStyle(
                            fontSize: 18.sp,
                            height: 1.2,
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            bullet,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.stepTitle),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                editableItem.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
              height:
                  (editableItem.sections.isNotEmpty &&
                      editableItem.sections[0].subtitle.toLowerCase() ==
                          'your brand story')
                  ? 12.h
                  : 24.h,
            ),

            Expanded(
              child: ListView.builder(
                itemCount: editableItem.sections.length,
                itemBuilder: (context, index) {
                  return _buildSection(editableItem.sections[index], index);
                },
              ),
            ),
            Button(
              onPressed: _saveItem,
              text: _isSaving ? 'Saving...' : 'Save',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: canSave()
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
