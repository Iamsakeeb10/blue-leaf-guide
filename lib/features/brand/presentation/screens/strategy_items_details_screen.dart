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
  const StrategyItemDetailScreen({required this.item, super.key});

  @override
  State<StrategyItemDetailScreen> createState() =>
      _StrategyItemDetailScreenState();
}

class _StrategyItemDetailScreenState extends State<StrategyItemDetailScreen> {
  late StrategyItem editableItem;
  final StrategyService _strategyService = StrategyService();
  bool _isSaving = false;

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
    'Under \$25,000',
    '\$25,000 - \$50,000',
    '\$50,000 - \$75,000',
    '\$75,000 - \$100,000',
    '\$100,000 - \$150,000',
    'Over \$150,000',
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
      return _buildDropdownSection(section, sectionIndex);
    } else if (section.isTextField) {
      return _buildTextFieldSection(section, sectionIndex);
    } else {
      return _buildStaticSection(section);
    }
  }

  Widget _buildChipSection(StrategySection section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.subtitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: section.bullets.map((trait) {
            final isSelected = section.userInputs.contains(trait);
            return FilterChip(
              label: Text(trait),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (!section.userInputs.contains(trait)) {
                      section.userInputs.add(trait);
                    }
                  } else {
                    section.userInputs.remove(trait);
                  }
                });
              },
              selectedColor: AppColors.brand500.withOpacity(0.2),
              checkmarkColor: AppColors.brand500,
            );
          }).toList(),
        ),
        SizedBox(height: 24.h),
      ],
    );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.subtitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
          hint: Text('Select ${section.subtitle}'),
          items: options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: (value) {
            setState(() {
              if (value != null) {
                section.userInputs = [value];
              }
            });
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildTextFieldSection(StrategySection section, int sectionIndex) {
    if (section.userInputs.isEmpty) {
      section.userInputs.add('');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.subtitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: section.userInputs[0],
          maxLines: section.subtitle.toLowerCase().contains('story') ? 5 : 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            hintText: 'Enter ${section.subtitle.toLowerCase()}',
          ),
          onChanged: (value) {
            section.userInputs[0] = value;
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        ...section.bullets.map(
          (bullet) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 16.sp)),
                Expanded(
                  child: Text(bullet, style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: editableItem.title),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
