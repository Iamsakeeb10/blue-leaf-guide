import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../brand/data/visual_template_upload.dart';
import '../../../roadmap/presentation/screens/roadmap_screen.dart';
import '../../data/client_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inside your HomeScreen build method, replace the header Row
    final userData = context.watch<AuthProvider>().userData;
    final firstName = userData?['firstName'] ?? 'User';
    final photoURL = userData?['photoURL'];

    print('🟨 Photo URL $photoURL');

    String _getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return "Good Morning";
      if (hour < 18) return "Good Afternoon";
      return "Good Evening";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      context.push('/profile');
                    },
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF24AC69),
                        image: (photoURL != null && photoURL.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(photoURL),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (photoURL == null || photoURL.isEmpty)
                          ? Center(
                              child: Text(
                                firstName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),

                  SizedBox(width: 12.w),
                  // Greeting Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $firstName',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary.withOpacity(0.5),
                            height: 1.3,
                            letterSpacing: 12 * 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: ClipOval(
                      child: SvgPicture.asset(
                        'assets/icons/svg/bell.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Subtitle
              Text(
                "Let's make today count",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),

              SizedBox(height: 20.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: ClientService().getClientsStream(),
                    builder: (context, snapshot) {
                      int totalClients = 0;
                      if (snapshot.hasData) {
                        totalClients = snapshot.data?.docs.length ?? 0;
                      }

                      return _buildStatsCard(
                        svgPath: 'assets/icons/svg/multi-user.svg',
                        label: 'Total Client',
                        value:
                            '$totalClients', // dynamically show total clients
                        gradientColors: [
                          Colors.white.withOpacity(0),
                          const Color(0xFF24AC69).withOpacity(0.4),
                          const Color(0xFF24AC69),
                        ],
                        onTap: () {
                          context.push('/total-clients');
                        },
                      );
                    },
                  ),

                  _buildStatsCard(
                    svgPath: 'assets/icons/svg/dollar.svg',
                    label: 'Total Earned',
                    value: '3K',
                    gradientColors: [
                      Colors.white.withOpacity(0),
                      const Color(0xFF2C63FD).withOpacity(0.4),
                      const Color(0xFF2C63FD),
                    ],
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  _buildStatsCard(
                    svgPath: 'assets/icons/svg/goal.svg',
                    label: 'Goal Completed',
                    value: '4m',
                    gradientColors: [
                      Colors.white.withOpacity(0),
                      const Color(0xFF6628EA).withOpacity(0.4),
                      const Color(0xFF6628EA),
                    ],
                    onTap: () async {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Coming soon!'),
                      //     behavior: SnackBarBehavior.floating,
                      //   ),
                      // );

                      final success = await uploadVisualTemplateToFirestore();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Visual template uploaded!')),
                        );
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Quick Action Section
              Text(
                'Quick Action',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),

              SizedBox(height: 16.h),

              // Roadmap Cards
              _buildRoadmapCard(
                title: 'View Roadmap',
                subtitle: 'The Blue Leaf Roadmap to Get Success',
                svgPath: 'assets/icons/svg/card-two.svg',
                color: AppColors.lightBlue40.withOpacity(0.25),
                textColor: AppColors.timelinePrimary,
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoadmapScreen()),
                  );
                },
              ),
              SizedBox(height: 8.h),
              _buildRoadmapCard(
                title: 'Build Brand',
                subtitle: 'Build your brand step by step',
                svgPath: 'assets/icons/svg/card-one.svg',
                color: AppColors.lightPurple40.withOpacity(0.25),
                textColor: AppColors.brand500,
                onTap: () {
                  context.push('/build-brand');
                },
              ),
              SizedBox(height: 8.h),
              _buildRoadmapCard(
                title: 'View Daily Task',
                subtitle: 'Track your daily activities and monthly goals',
                svgPath: 'assets/icons/svg/card-three.svg',
                color: AppColors.lightPink33.withOpacity(0.2),
                textColor: AppColors.brightPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String svgPath,
    required String label,
    required String value,
    required List<Color> gradientColors,
    List<double>? gradientStops,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r), // match card's radius
      onTap: onTap,
      child: Container(
        width: 109.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: RadialGradient(
            center: const Alignment(-0.9, 0.9), // bottom-left glow
            radius: 2.5,
            colors: gradientColors,
            stops: gradientStops ?? const [0.0, 0.3, 1.0],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      svgPath,
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapCard({
    required String title,
    required String subtitle,
    required String svgPath, // path of your SVG asset
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200.w),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SvgPicture.asset(
              svgPath,
              width: 80.w,
              height: 80.h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

// Main app wrapper with ScreenUtil initialization
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Home Screen',
          theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Roboto'),
          home: child,
        );
      },
      child: const HomeScreen(),
    );
  }
}
