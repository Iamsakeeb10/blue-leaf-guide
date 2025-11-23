import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF24AC69),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://peoplify.pics/api/generate/avatar?gender=male',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),
                  // Greeting Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi! Tomeka',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Good Morning',
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
                  // Same Avatar on Right
                  Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF24AC69),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://peoplify.pics/api/generate/avatar?gender=male',
                        ),
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

              // Stats Cards Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatsCard(
                    svgPath: 'assets/icons/svg/multi-user.svg',
                    label: 'Total Client',
                    value: '20',
                    gradientColors: [
                      Colors.white.withOpacity(0),
                      const Color(0xFF24AC69).withOpacity(0.4),
                      const Color(0xFF24AC69),
                    ],
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
              ),
              SizedBox(height: 8.h),
              _buildRoadmapCard(
                title: 'View Roadmap',
                subtitle: 'The Blue Leaf Roadmap to Get Success',
                svgPath: 'assets/icons/svg/card-one.svg',
                color: AppColors.lightPurple40.withOpacity(0.25),
                textColor: AppColors.brand500,
              ),
              SizedBox(height: 8.h),
              _buildRoadmapCard(
                title: 'View Roadmap',
                subtitle: 'The Blue Leaf Roadmap to Get Success',
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
  }) {
    return Container(
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
    );
  }

  Widget _buildRoadmapCard({
    required String title,
    required String subtitle,
    required String svgPath, // path of your SVG asset
    required Color color,
    required Color textColor,
  }) {
    return Container(
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
