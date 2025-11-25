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
  // ignore: unused_field
  String? _colorSelectionSource; // 'palette' or 'custom'

  // Create a working copy of the item
  late VisualItem _editableItem;

  @override
  void initState() {
    super.initState();

    // Create a deep copy of the item to work with
    _editableItem = VisualItem(
      id: widget.item.id,
      title: widget.item.title,
      isCompleted: widget.item.isCompleted,
      sections: widget.item.sections
          .map(
            (section) => VisualSection(
              subtitle: section.subtitle,
              options: List<String>.from(section.options),
              isTextField: section.isTextField,
              fieldType: section.fieldType,
              hintText: section.hintText,
              userInputs: List<String>.from(section.userInputs),
              selectedOptions: section.selectedOptions != null
                  ? List<String>.from(section.selectedOptions!)
                  : null,
            ),
          )
          .toList(),
    );

    _controllers = _editableItem.sections.map((section) {
      return TextEditingController(
        text: section.userInputs.isNotEmpty ? section.userInputs.first : '',
      );
    }).toList();

    // Check if colors already exist and set source
    for (var section in _editableItem.sections) {
      if (section.fieldType == 'color' && section.userInputs.isNotEmpty) {
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

  void _handleBack() {
    context.pop(_editableItem); // Pass back the editable item
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
        section.selectedOptions = [source];
        _colorSelectionSource = source;
        _editableItem.isCompleted = true;
      });
      await _saveItem();

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
        _editableItem.isCompleted = false;
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
      final success = await _visualService.saveVisualItem(
        userId,
        _editableItem,
      );
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
    for (var section in _editableItem.sections) {
      if (section.fieldType == 'color') {
        if (section.userInputs.isEmpty) return false;
      } else if (section.isTextField) {
        if (section.userInputs.isEmpty) return false;
      } else if (section.fieldType == 'chips') {
        if (section.userInputs.isEmpty) return false;
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
      _editableItem.isCompleted = true;
      _isSaving = true;
    });

    try {
      final success = await _visualService.saveVisualItem(
        userId,
        _editableItem,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked as complete!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(_editableItem);
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

  bool get hasColorFeature {
    return _editableItem.sections.any(
      (section) => section.fieldType == 'color',
    );
  }

  bool _isSaveEnabled() {
    for (var section in _editableItem.sections) {
      if (section.isTextField && section.fieldType == 'text') {
        if (section.userInputs.isNotEmpty &&
            section.userInputs.first.trim().isNotEmpty) {
          return true;
        }
      }

      if (section.fieldType == 'chips') {
        if (section.userInputs.isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  Widget _buildColorButtons() {
    return Column(
      children: [
        Button(
          onPressed: _isCompleteButtonEnabled() && !_isSaving
              ? _markAsComplete
              : null,
          text: _isSaving
              ? 'Saving...'
              : _editableItem.isCompleted
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
            onPressed: () => context.pop(_editableItem),
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
    );
  }

  Widget _buildTextOnlyButtons() {
    return Column(
      children: [
        Button(
          onPressed: !_isSaving && _isSaveEnabled() ? _saveItem : null,
          backgroundColor: _isSaveEnabled() && !_isSaving
              ? AppColors.brand500
              : AppColors.brand500.withOpacity(0.3),
          text: _isSaving ? "Saving..." : "Save",
          height: 54.h,
          borderRadius: BorderRadius.circular(32.r),
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          textColor: Colors.white,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.pop(_editableItem),
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
    );
  }

  Widget _buildSectionContent(VisualSection section, int sectionIndex) {
    if (section.fieldType == 'color') {
      if (section.userInputs.isNotEmpty) {
        return _buildColorResultScreen(section, sectionIndex);
      }
      return _buildColorInitialScreen(section, sectionIndex);
    } else if (section.isTextField && section.fieldType == 'text') {
      return TextField(
        controller: _controllers[sectionIndex],
        decoration: InputDecoration(
          hintText: section.hintText ?? 'Enter ${section.subtitle}',
          hintStyle: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textPrimary.withOpacity(0.3),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.neutral50.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.r),
            borderSide: BorderSide(
              color: AppColors.neutral50.withOpacity(0.05),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100.r),
            borderSide: BorderSide(color: AppColors.brand500, width: 1.5),
          ),
          contentPadding: EdgeInsets.all(14.w),
        ),
        onChanged: (value) {
          setState(() {
            section.userInputs = [value];
          });
        },
      );
    } else if (section.fieldType == 'chips') {
      return Container(
        width: double.infinity,
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: section.options.map((option) {
            final isSelected = section.userInputs.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    section.userInputs.remove(option);
                  } else {
                    section.userInputs.add(option);
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
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary.withOpacity(0.7),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: widget.stepTitle, onBack: _handleBack),
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
                      _editableItem.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ..._editableItem.sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      return Column(
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
              decoration: BoxDecoration(),
              child: SafeArea(
                child: hasColorFeature
                    ? _buildColorButtons()
                    : _buildTextOnlyButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
