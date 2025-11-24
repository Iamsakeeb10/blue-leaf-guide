// lib/features/clients/screens/add_client_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/custom_date_picker_dialog.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/custom_appbar.dart';
import '../../../../shared/widgets/text_field.dart' as custom;
import '../../data/client_service.dart';
import '../widgets/image_source_bottom_sheet.dart';

class AddClientScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const AddClientScreen({super.key, this.extra});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController joinDateController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController tiktokController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();

  String clientType = 'Regular';
  final List<String> clientTypes = ['Regular', 'Premium', 'VIP'];

  String? _selectedImagePath;
  String? _existingImageBase64;
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _clientId;

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  void _loadClientData() {
    if (widget.extra != null) {
      _isEditMode = true;
      _clientId = widget.extra!['clientId'];
      final clientData = widget.extra!['clientData'] as Map<String, dynamic>;

      firstNameController.text = clientData['firstName'] ?? '';
      lastNameController.text = clientData['lastName'] ?? '';
      emailController.text = clientData['email'] ?? '';
      phoneController.text = clientData['phone'] ?? '';
      joinDateController.text = clientData['joinDate'] ?? '';
      instagramController.text = clientData['instagram'] ?? '';
      tiktokController.text = clientData['tiktok'] ?? '';
      linkedinController.text = clientData['linkedin'] ?? '';
      twitterController.text = clientData['twitter'] ?? '';
      clientType = clientData['clientType'] ?? 'Regular';
      _existingImageBase64 = clientData['profileImage'];
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    joinDateController.dispose();
    instagramController.dispose();
    tiktokController.dispose();
    linkedinController.dispose();
    twitterController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showImageSourceBottomSheet(context);
    if (source == null) return;

    final hasPermission = await _requestPermission(source);
    if (!hasPermission) return;

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _selectedImagePath = pickedFile.path);
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;
    String permissionName;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
      permissionName = 'Camera';
    } else {
      if (Platform.isIOS) {
        permission = Permission.photos;
        permissionName = 'Photos';
      } else {
        final isAndroid13OrHigher = await _isAndroid13OrHigher();
        if (isAndroid13OrHigher) {
          permission = Permission.photos;
          permissionName = 'Photos';
        } else {
          permission = Permission.storage;
          permissionName = 'Storage';
        }
      }
    }

    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      if (result.isGranted) return true;
      if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog(permissionName);
        return false;
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(permissionName);
      return false;
    }

    return false;
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  void _showPermissionDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          '$permissionName permission is required to select images. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return CustomDatePickerDialog(
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        joinDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _validatePhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(phone) && phone.length >= 10;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.timelinePrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    if (!_validateEmail(emailController.text)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    if (!_validatePhone(phoneController.text)) {
      _showSnackBar('Please enter a valid phone number', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageBase64;

      if (_selectedImagePath != null) {
        imageBase64 = await ClientService().compressAndEncodeImage(
          _selectedImagePath!,
        );
        if (imageBase64 == null) {
          _showSnackBar(
            'Image size exceeds 1MB after compression. Please select a smaller image.',
            isError: true,
          );
          setState(() => _isLoading = false);
          return;
        }
      } else if (_isEditMode && _existingImageBase64 != null) {
        imageBase64 = _existingImageBase64;
      }

      final clientData = {
        'profileImage': imageBase64 ?? '',
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'clientType': clientType,
        'joinDate': joinDateController.text.trim(),
        'instagram': instagramController.text.trim(),
        'tiktok': tiktokController.text.trim(),
        'linkedin': linkedinController.text.trim(),
        'twitter': twitterController.text.trim(),
      };

      Map<String, dynamic> result;

      if (_isEditMode && _clientId != null) {
        result = await ClientService().updateClient(_clientId!, clientData);
      } else {
        result = await ClientService().addClient(clientData);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success']) {
        _showSnackBar(result['message']);
        context.go('/total-clients');
      } else {
        _showSnackBar(result['message'], isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('An error occurred: $e', isError: true);
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImagePath != null) {
      return Image.file(
        File(_selectedImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: 40.r, color: AppColors.textSecondary);
        },
      );
    } else if (_existingImageBase64 != null &&
        _existingImageBase64!.isNotEmpty) {
      return Image.memory(
        const Base64Decoder().convert(_existingImageBase64!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: 40.r, color: AppColors.textSecondary);
        },
      );
    } else {
      return Icon(Icons.person, size: 40.r, color: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _isEditMode ? 'Edit Client' : 'Add Client'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile image picker
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neutral10.withOpacity(0.2),
                        width: 2,
                      ),
                      color: AppColors.neutral10.withOpacity(0.05),
                    ),
                    child: ClipOval(child: _buildImagePreview()),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16.r,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Name fields
              Row(
                children: [
                  Expanded(
                    child: custom.TextField(
                      controller: firstNameController,
                      label: 'First Name',
                      hint: 'Enter first name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: custom.TextField(
                      controller: lastNameController,
                      label: 'Last Name',
                      hint: 'Enter last name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Email
              custom.TextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Phone
              custom.TextField(
                controller: phoneController,
                label: 'Phone',
                hint: 'Enter phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Client Type Dropdown
              DropdownButtonFormField<String>(
                value: clientType,
                decoration: InputDecoration(
                  labelText: 'Client Type',
                  prefixIcon: Icon(Icons.category_outlined, size: 20.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                items: clientTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() => clientType = value!);
                },
              ),
              SizedBox(height: 16.h),

              // Join Date
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: custom.TextField(
                    controller: joinDateController,
                    label: 'Join Date',
                    hint: 'Select join date',
                    icon: Icons.calendar_today_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Join date is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Social Media Section
              Text(
                'Social Media (Optional)',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),

              // Instagram
              custom.TextField(
                controller: instagramController,
                label: 'Instagram',
                hint: '@username',
                icon: Icons.camera_alt_outlined,
              ),
              SizedBox(height: 16.h),

              // TikTok
              custom.TextField(
                controller: tiktokController,
                label: 'TikTok',
                hint: '@username',
                icon: Icons.video_library_outlined,
              ),
              SizedBox(height: 16.h),

              // LinkedIn
              custom.TextField(
                controller: linkedinController,
                label: 'LinkedIn',
                hint: 'Profile URL',
                icon: Icons.business_outlined,
              ),
              SizedBox(height: 16.h),

              // Twitter
              custom.TextField(
                controller: twitterController,
                label: 'Twitter',
                hint: '@username',
                icon: Icons.alternate_email,
              ),
              SizedBox(height: 32.h),

              // Submit Button
              Button(
                onPressed: _isLoading ? null : _submitForm,
                text: _isEditMode ? 'Update Client' : 'Add Client',
                height: 54.h,
                borderRadius: BorderRadius.circular(32.r),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
                backgroundColor: AppColors.primary,
                isLoading: _isLoading,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
