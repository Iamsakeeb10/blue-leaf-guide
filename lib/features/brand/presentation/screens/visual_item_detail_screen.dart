import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/custom_dialog.dart';
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
    context.pop(_editableItem); // Return updated item instead of original
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
      await _saveItem(shouldPop: false);

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
      builder: (context) => CustomDialog(
        title: 'Delete Colors',
        subtitle: 'Are you sure you want to delete all selected colors?',
        primaryButtonText: 'Yes, Delete',
        primaryButtonOnPressed: () {
          Navigator.of(context).pop(true);
        },
        secondaryButtonText: 'Cancel',
        secondaryButtonOnPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
    );

    if (confirm == true) {
      setState(() {
        section.userInputs = [];
        section.selectedOptions = [];
        _colorSelectionSource = null;
        _editableItem.isCompleted = false;
      });
      await _saveItem(shouldPop: false);

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

  Future<void> _saveItem({bool shouldPop = true}) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Update userInputs from controllers before saving
    for (int i = 0; i < _editableItem.sections.length; i++) {
      final section = _editableItem.sections[i];
      if (section.isTextField && section.fieldType == 'text') {
        section.userInputs = [_controllers[i].text];
      }
    }

    // Mark as complete if all sections are filled
    if (_isCompleteButtonEnabled()) {
      _editableItem.isCompleted = true;
    } else {
      _editableItem.isCompleted = false;
    }

    setState(() => _isSaving = true);

    try {
      final success = await _visualService.saveVisualItem(
        userId,
        _editableItem,
      );
      if (success && mounted) {
        // Reload fresh data from Firestore if not popping
        if (!shouldPop) {
          await _reloadItemFromFirestore();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        if (shouldPop) {
          context.pop(_editableItem);
        }
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

  Future<void> _reloadItemFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final freshItem = await _visualService.getVisualItem(
        userId,
        _editableItem.id,
      );
      if (freshItem != null && mounted) {
        setState(() {
          _editableItem = VisualItem(
            id: freshItem.id,
            title: freshItem.title,
            isCompleted: freshItem.isCompleted,
            sections: freshItem.sections
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

          // Update controllers with fresh data
          for (int i = 0; i < _editableItem.sections.length; i++) {
            final section = _editableItem.sections[i];
            if (section.isTextField && i < _controllers.length) {
              _controllers[i].text = section.userInputs.isNotEmpty
                  ? section.userInputs.first
                  : '';
            }
          }

          // Update color selection source
          for (var section in _editableItem.sections) {
            if (section.fieldType == 'color' && section.userInputs.isNotEmpty) {
              _colorSelectionSource =
                  section.selectedOptions?.isNotEmpty == true
                  ? section.selectedOptions!.first
                  : 'custom';
              break;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error reloading item: $e');
    }
  }

  bool _isCompleteButtonEnabled() {
    for (int i = 0; i < _editableItem.sections.length; i++) {
      final section = _editableItem.sections[i];

      if (section.fieldType == 'color') {
        if (section.userInputs.isEmpty) return false;
      } else if (section.isTextField && section.fieldType == 'text') {
        // For the Business Name item, the Tagline field is optional.
        if (_editableItem.id == 'business_name' &&
            section.subtitle.toLowerCase().contains('tagline')) {
          // skip tagline (optional)
        } else {
          if (_controllers[i].text.trim().isEmpty) return false;
        }
      } else if (section.fieldType == 'chips') {
        // ✅ At least one chip must be selected
        if (section.selectedOptions == null ||
            section.selectedOptions!.isEmpty) {
          return false;
        }
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

    // Update userInputs from controllers before saving
    for (int i = 0; i < _editableItem.sections.length; i++) {
      final section = _editableItem.sections[i];
      if (section.isTextField && section.fieldType == 'text') {
        section.userInputs = [_controllers[i].text];
      }
    }

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
    // For Business Name, require the Name field specifically (Tagline optional)
    if (_editableItem.id == 'business_name') {
      for (int i = 0; i < _editableItem.sections.length; i++) {
        final section = _editableItem.sections[i];
        if (section.isTextField &&
            section.fieldType == 'text' &&
            section.subtitle.toLowerCase().contains('name')) {
          return _controllers.length > i &&
              _controllers[i].text.trim().isNotEmpty;
        }
      }
      // If no Name field found, don't allow save
      return false;
    }

    // Default behavior: allow save if any text input has content or any chips selected
    for (int i = 0; i < _editableItem.sections.length; i++) {
      final section = _editableItem.sections[i];

      if (section.isTextField && section.fieldType == 'text') {
        if (_controllers[i].text.trim().isNotEmpty) {
          return true;
        }
      }

      if (section.fieldType == 'chips') {
        // Allow saving with at least one selection
        if (section.selectedOptions != null &&
            section.selectedOptions!.isNotEmpty) {
          return true;
        }
      }
    }

    return false;
  }

  // ignore: unused_element
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
            onPressed: () => context.pop(_editableItem), // Return original item
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
            onPressed: () => context.pop(_editableItem), // Return original item
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
          setState(() {});
        },
      );
    } else if (section.fieldType == 'chips') {
      return Container(
        width: double.infinity,
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: section.options.map((option) {
            // Check selectedOptions for chips
            final isSelected =
                section.selectedOptions?.contains(option) ?? false;
            return GestureDetector(
              onTap: () {
                setState(() {
                  section.selectedOptions ??= [];
                  if (isSelected) {
                    section.selectedOptions!.remove(option);
                  } else {
                    section.selectedOptions!.add(option);
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
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Create your brand color',
            style: TextStyle(
              fontSize: 20.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 200.w,
            ), // adjust max width as needed
            child: Text(
              'You can choose a color from the default palette. or create your own custom shade.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimary.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: 45.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 34.w),
            child: Button(
              onPressed: () =>
                  _handleColorSelection(section, sectionIndex, 'custom'),
              text: 'Generate custom color',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: AppColors.brand500,
            ),
          ),

          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 34.w),
            child: Button(
              onPressed: () =>
                  _handleColorSelection(section, sectionIndex, 'palette'),
              text: 'Select form pallete',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: AppColors.textPrimary,
              backgroundColor: AppColors.textPrimary.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorResultScreen(VisualSection section, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Display selected colors
        Text(
          'Your brand color',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: section.userInputs.map((colorHex) {
            return Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: Color(int.parse('0xff$colorHex')),
                shape: BoxShape.circle,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 28.h),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Button(
            onPressed: () {
              final source = section.selectedOptions?.isNotEmpty == true
                  ? section.selectedOptions!.first
                  : 'custom';
              _handleColorSelection(section, sectionIndex, source);
            },
            text: 'Edit your color',
            height: 54.h,
            borderRadius: BorderRadius.circular(32.r),
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            textColor: Colors.white,
            backgroundColor: AppColors.brand500,
          ),
        ),
        SizedBox(height: 12.h),

        TextButton(
          onPressed: () => _deleteColors(section),
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
          child: Text(
            'Delete color',
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.5),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          context.pop(_editableItem);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: widget.stepTitle, onBack: _handleBack),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: hasColorFeature
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisAlignment: hasColorFeature
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              // Scrollable content
              Expanded(
                child: hasColorFeature
                    ? Center(
                        child: SingleChildScrollView(
                          child: _buildContentColumn(),
                        ),
                      )
                    : SingleChildScrollView(child: _buildContentColumn()),
              ),

              // Buttons
              hasColorFeature ? SizedBox.shrink() : _buildTextOnlyButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracted content column
  Widget _buildContentColumn() {
    return Column(
      crossAxisAlignment: hasColorFeature
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        // Title
        if (_editableItem.title != "Color Palette")
          Text(
            _editableItem.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: hasColorFeature ? TextAlign.center : TextAlign.start,
          ),

        SizedBox(height: 24.h),

        // Sections
        ..._editableItem.sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return Column(
            crossAxisAlignment: hasColorFeature
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (_editableItem.title != "Color Palette")
                Text(
                  section.subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.4,
                  ),
                  textAlign: hasColorFeature
                      ? TextAlign.center
                      : TextAlign.start,
                ),
              SizedBox(height: 12.h),
              _buildSectionContent(section, index),
              SizedBox(height: 24.h),
            ],
          );
        }).toList(),
      ],
    );
  }
}
