import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../data/client_service.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

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

  // Profile image (static network image for now)
  String profileImageUrl =
      'https://www.w3schools.com/howto/img_avatar.png'; // static image

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newClient = {
        'profileImage': profileImageUrl.trim(),
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'clientType': clientType,
        'joinDate': joinDateController.text,
        'instagram': instagramController.text,
        'tiktok': tiktokController.text,
        'linkedin': linkedinController.text,
        'twitter': twitterController.text,
      };

      // ✅ Add to global list
      ClientService().addClient(newClient);

      // ✅ Go back to list screen (no extra data needed)
      context.go('/total-clients');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Client')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile image picker container
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                      image: DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Camera icon overlay
                  GestureDetector(
                    onTap: () {
                      // TODO: Add image picker functionality
                    },
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Name fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Other fields
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),

              DropdownButtonFormField<String>(
                value: clientType,
                items: clientTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    clientType = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Client Type'),
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: joinDateController,
                decoration: const InputDecoration(labelText: 'Join Date'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),

              TextFormField(
                controller: instagramController,
                decoration: const InputDecoration(labelText: 'Instagram'),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: tiktokController,
                decoration: const InputDecoration(labelText: 'TikTok'),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn'),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: twitterController,
                decoration: const InputDecoration(labelText: 'Twitter'),
              ),
              SizedBox(height: 24.h),

              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Client'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
