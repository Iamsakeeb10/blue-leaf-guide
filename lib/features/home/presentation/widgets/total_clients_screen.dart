// lib/features/clients/screens/total_clients_screen.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/button.dart';
import '../../data/client_service.dart';

class TotalClientsScreen extends StatelessWidget {
  const TotalClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Clients'),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-client'),
            icon: Icon(Icons.add, size: 24.r),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ClientService().getClientsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading clients',
                style: TextStyle(color: AppColors.danger, fontSize: 16.sp),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final clients = snapshot.data?.docs ?? [];

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80.r,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No clients added yet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap + to add your first client',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final doc = clients[index];
                final client = doc.data() as Map<String, dynamic>;
                final clientId = doc.id;
                return _buildClientCard(context, client, clientId);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientCard(
    BuildContext context,
    Map<String, dynamic> client,
    String clientId,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildProfileImage(client['profileImage']),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${client['firstName']} ${client['lastName']}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        client['clientType'] ?? 'Regular',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push(
                        '/add-client',
                        extra: {'clientId': clientId, 'clientData': client},
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, clientId);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 20.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 20.r,
                            color: AppColors.danger,
                          ),
                          SizedBox(width: 8.w),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildSocialIcons(client),
            SizedBox(height: 12.h),
            _buildInfoRow(Icons.email, client['email'] ?? 'N/A'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.phone, client['phone'] ?? 'N/A'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.calendar_today, client['joinDate'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? base64Image) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neutral10.withOpacity(0.1),
      ),
      child: base64Image != null && base64Image.isNotEmpty
          ? ClipOval(
              child: Image.memory(
                const Base64Decoder().convert(base64Image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 30.r,
                    color: AppColors.textSecondary,
                  );
                },
              ),
            )
          : Icon(Icons.person, size: 30.r, color: AppColors.textSecondary),
    );
  }

  Widget _buildSocialIcons(Map<String, dynamic> client) {
    final socials = <String, String>{};
    if (client['instagram']?.isNotEmpty ?? false) {
      socials['Instagram'] = 'assets/icons/instagram.png';
    }
    if (client['tiktok']?.isNotEmpty ?? false) {
      socials['TikTok'] = 'assets/icons/tiktok.png';
    }
    if (client['linkedin']?.isNotEmpty ?? false) {
      socials['LinkedIn'] = 'assets/icons/linkedin.png';
    }
    if (client['twitter']?.isNotEmpty ?? false) {
      socials['Twitter'] = 'assets/icons/twitter.png';
    }

    if (socials.isEmpty) return const SizedBox.shrink();

    return Row(
      children: socials.values.map((path) {
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Image.asset(
            path,
            width: 24.w,
            height: 24.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.link,
                size: 24.r,
                color: AppColors.textSecondary,
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String clientId) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteClientDialog(clientId: clientId),
    );
  }
}

class DeleteClientDialog extends StatefulWidget {
  final String clientId;

  const DeleteClientDialog({super.key, required this.clientId});

  @override
  State<DeleteClientDialog> createState() => _DeleteClientDialogState();
}

class _DeleteClientDialogState extends State<DeleteClientDialog> {
  bool _isDeleting = false;

  Future<void> _deleteClient() async {
    setState(() => _isDeleting = true);

    final result = await ClientService().deleteClient(widget.clientId);

    if (!mounted) return;

    if (result['success']) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.timelineBorder,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36.r)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete Client',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 280.w),
              child: Text(
                'Are you sure you want to delete this client? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Button(
              onPressed: _isDeleting ? null : _deleteClient,
              text: 'Delete',
              height: 54.h,
              borderRadius: BorderRadius.circular(32.r),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              textColor: Colors.white,
              backgroundColor: AppColors.danger,
              isLoading: _isDeleting,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isDeleting
                    ? null
                    : () => Navigator.of(context).pop(),
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
