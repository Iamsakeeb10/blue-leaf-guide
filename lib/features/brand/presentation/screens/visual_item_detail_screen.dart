import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../data/visual_service.dart';
import '../../models/visual_item.dart';
import 'color_palette_picker_screen.dart';
import 'color_picker_screen.dart';

class VisualItemDetailScreen extends StatefulWidget {
  final VisualItem item;
  final String stepTitle;

  const VisualItemDetailScreen({
    required this.item,
    required this.stepTitle,
    super.key,
  });

  @override
  State<VisualItemDetailScreen> createState() => _VisualItemDetailScreenState();
}

class _VisualItemDetailScreenState extends State<VisualItemDetailScreen> {
  final VisualService _visualService = VisualService();
  bool _isSaving = false;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.item.sections.map((section) {
      return TextEditingController(
        text: section.userInputs.isNotEmpty ? section.userInputs.first : '',
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleColorSelection(
    VisualSection section,
    int sectionIndex,
  ) async {
    // Show bottom sheet to choose between custom color or palette
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.neutral50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'Choose Color Option',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.brand500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.palette, color: AppColors.brand500),
              ),
              title: Text(
                'Choose from Palette',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Select from curated color palettes',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
              ),
              onTap: () => Navigator.pop(context, 'palette'),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.brand500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.color_lens, color: AppColors.brand500),
              ),
              title: Text(
                'Custom Color',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Create your own color combination',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
              ),
              onTap: () => Navigator.pop(context, 'custom'),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );

    if (choice == null) return;

    List<String>? selectedColors;

    if (choice == 'palette') {
      selectedColors = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ColorPalettePickerScreen(existingColors: section.userInputs),
        ),
      );
    } else {
      selectedColors = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ColorPickerScreen(existingColors: section.userInputs),
        ),
      );
    }

    if (selectedColors != null && selectedColors.isNotEmpty) {
      setState(() {
        section.userInputs = selectedColors!;
      });
      await _saveItem();
    }
  }

  Future<void> _saveItem() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final success = await _visualService.saveVisualItem(userId, widget.item);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _isCompleteButtonEnabled() {
    for (var section in widget.item.sections) {
      if (section.fieldType == 'color') {
        if (section.userInputs.isEmpty) return false;
      } else if (section.isTextField) {
        if (section.userInputs.isEmpty) return false;
      } else if (section.fieldType == 'chips') {
        if (section.selectedOptions?.isEmpty ?? true) return false;
      }
    }
    return true;
  }

  Future<void> _markAsComplete() async {
    if (!_isCompleteButtonEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all sections first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      widget.item.isCompleted = true;
      _isSaving = true;
    });

    try {
      final success = await _visualService.saveVisualItem(userId, widget.item);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(widget.item);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildSectionContent(VisualSection section, int sectionIndex) {
    if (section.fieldType == 'color') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.userInputs.isNotEmpty) ...[
            Text(
              'Selected Colors (${section.userInputs.length}/4)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: section.userInputs.map((colorHex) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Color(int.parse('0xff$colorHex')),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neutral50.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            section.userInputs.remove(colorHex);
                          });
                          _saveItem();
                        },
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: section.userInputs.length >= 4
                  ? null
                  : () => _handleColorSelection(section, sectionIndex),
              icon: Icon(Icons.add, size: 20.sp),
              label: Text(
                section.userInputs.isEmpty
                    ? 'Add Brand Colors'
                    : 'Add More Colors (${section.userInputs.length}/4)',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: section.userInputs.length >= 4
                    ? AppColors.brand500.withOpacity(0.3)
                    : AppColors.brand500,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          if (section.userInputs.length >= 4)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Maximum 4 colors reached',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textPrimary.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      );
    } else if (section.isTextField && section.fieldType == 'text') {
      return TextField(
        controller: _controllers[sectionIndex],
        decoration: InputDecoration(
          hintText: section.hintText ?? 'Enter ${section.subtitle}',
          hintStyle: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.4),
            fontSize: 14.sp,
          ),
          filled: true,
          fillColor: AppColors.neutral50.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.neutral50.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.neutral50.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.brand500, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        onChanged: (value) {
          setState(() {
            section.userInputs = [value];
          });
        },
        onEditingComplete: _saveItem,
      );
    } else if (section.fieldType == 'chips') {
      return Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: section.options.map((option) {
          final isSelected = section.selectedOptions?.contains(option) ?? false;
          return ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  section.selectedOptions ??= [];
                  section.selectedOptions!.add(option);
                } else {
                  section.selectedOptions?.remove(option);
                }
              });
              _saveItem();
            },
            selectedColor: AppColors.brand500,
            backgroundColor: AppColors.neutral50.withOpacity(0.1),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(
                color: isSelected
                    ? AppColors.brand500
                    : AppColors.neutral50.withOpacity(0.2),
              ),
            ),
          );
        }).toList(),
      );
    }

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.stepTitle),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ...widget.item.sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
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
                        _buildSectionContent(section, index),
                        SizedBox(height: 24.h),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Button(
                    onPressed: _isCompleteButtonEnabled() && !_isSaving
                        ? _markAsComplete
                        : null,
                    text: _isSaving
                        ? 'Saving...'
                        : widget.item.isCompleted
                        ? 'Completed ✓'
                        : 'Mark as Complete',
                    height: 54.h,
                    borderRadius: BorderRadius.circular(32.r),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    textColor: Colors.white,
                    backgroundColor: _isCompleteButtonEnabled() && !_isSaving
                        ? AppColors.brand500
                        : AppColors.brand500.withOpacity(0.3),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        'Go Back',
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
        ],
      ),
    );
  }
}
