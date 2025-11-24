import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../data/client_service.dart';

class TotalClientsScreen extends StatelessWidget {
  const TotalClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = ClientService().clients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Clients'),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-client'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: clients.isEmpty
          ? const Center(child: Text('No clients added yet.'))
          : Padding(
              padding: EdgeInsets.all(16.w),
              child: ListView.builder(
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  return _buildClientCard(context, clients[index], index);
                },
              ),
            ),
    );
  }

  Widget _buildClientCard(
    BuildContext context,
    Map<String, dynamic> client,
    int index,
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
                CircleAvatar(
                  radius: 30.w,
                  backgroundImage: NetworkImage(client['profileImage'].trim()),
                ),
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
                        ),
                      ),
                      Text(
                        client['clientType'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: implement edit
                    } else if (value == 'delete') {
                      // ✅ Delete client
                      ClientService().removeClient(index);
                      // Rebuild screen (navigate to same page)
                      context.go('/total-clients');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                if (client['instagram'] != null &&
                    client['instagram'].isNotEmpty)
                  _buildSocialIcon('assets/icons/instagram.png'),
                if (client['tiktok'] != null && client['tiktok'].isNotEmpty)
                  _buildSocialIcon('assets/icons/tiktok.png'),
                if (client['linkedin'] != null && client['linkedin'].isNotEmpty)
                  _buildSocialIcon('assets/icons/linkedin.png'),
                if (client['twitter'] != null && client['twitter'].isNotEmpty)
                  _buildSocialIcon('assets/icons/twitter.png'),
              ],
            ),
            SizedBox(height: 12.h),
            Text('Email: ${client['email']}'),
            Text('Phone: ${client['phone']}'),
            Text('Join Date: ${client['joinDate']}'),

            // Add button to go to Add Client Screen
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/add-client'); // GoRouter navigation
                },
                child: const Text('Add Client'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Image.asset(assetPath, width: 24.w, height: 24.h),
    );
  }
}
