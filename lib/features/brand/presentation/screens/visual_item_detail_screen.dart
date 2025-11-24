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
  String? _colorSelectionSource; // 'palette' or 'custom'

  @override
  void initState() {
    super.initState();
    _controllers = widget.item.sections.map((section) {
      return TextEditingController(
        text: section.userInputs.isNotEmpty ? section.userInputs.first : '',
      );
    }).toList();

    // Check if colors already exist and set source
    for (var section in widget.item.sections) {
      if (section.fieldType == 'color' && section.userInputs.isNotEmpty) {
        // Try to get the source from metadata if you stored it
        // For now, we'll default to 'custom' if colors exist
        _colorSelectionSource = section.selectedOptions?.isNotEmpty == true
            ? section.selectedOptions!.first
            : 'custom';
        break;
      }
    }
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
    String source,
  ) async {
    List<String>? selectedColors;

    if (source == 'palette') {
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
        // Store the source in selectedOptions for tracking
        section.selectedOptions = [source];
        _colorSelectionSource = source;

        // Mark item as complete when colors are saved
        widget.item.isCompleted = true;
      });
      await _saveItem();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Colors saved and marked as complete!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteColors(VisualSection section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Colors'),
        content: Text('Are you sure you want to delete all selected colors?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        section.userInputs = [];
        section.selectedOptions = [];
        _colorSelectionSource = null;

        // Unmark as complete when colors are deleted
        widget.item.isCompleted = false;
      });
      await _saveItem();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Colors deleted'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
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
      // Show result screen if colors are selected
      if (section.userInputs.isNotEmpty) {
        return _buildColorResultScreen(section, sectionIndex);
      }
      // Show initial selection screen
      return _buildColorInitialScreen(section, sectionIndex);
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

  Widget _buildColorInitialScreen(VisualSection section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose how you want to add your brand colors',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary.withOpacity(0.6),
          ),
        ),
        SizedBox(height: 16.h),
        // Color Palette Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _handleColorSelection(section, sectionIndex, 'palette'),
            icon: Icon(Icons.palette, size: 24.sp),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose from Palette',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Select from curated color palettes',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brand500,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              side: BorderSide(color: AppColors.brand500, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Custom Color Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                _handleColorSelection(section, sectionIndex, 'custom'),
            icon: Icon(Icons.color_lens, size: 24.sp),
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Color',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Create your own color combination',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brand500,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              side: BorderSide(color: AppColors.brand500, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorResultScreen(VisualSection section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display selected colors
        Text(
          'Selected Colors (${section.userInputs.length})',
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
            return Container(
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
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),
        // Edit and Delete buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final source = section.selectedOptions?.isNotEmpty == true
                      ? section.selectedOptions!.first
                      : 'custom';
                  _handleColorSelection(section, sectionIndex, source);
                },
                icon: Icon(Icons.edit, size: 20.sp),
                label: Text(
                  'Edit Colors',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brand500,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(color: AppColors.brand500, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _deleteColors(section),
                icon: Icon(Icons.delete_outline, size: 20.sp),
                label: Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
