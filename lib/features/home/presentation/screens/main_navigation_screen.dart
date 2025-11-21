import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Placeholder screens for other tabs
  final List<Widget> _screens = [
    const HomeScreen(),
    const PlaceholderScreen(title: 'Explore'),
    const PlaceholderScreen(title: 'Community'),
    const PlaceholderScreen(title: 'Messages'),
    const PlaceholderScreen(title: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.brand50, width: 1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14332200),
              blurRadius: 42,
              offset: const Offset(0, -16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: 'assets/icons/svg/home.svg',
                  activeIcon: 'assets/icons/svg/home-active.svg',
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: 'assets/icons/svg/progress.svg',

                  activeIcon: 'assets/icons/svg/progress-active.svg',
                  label: 'Explore',
                ),
                _buildNavItem(
                  index: 2,
                  icon: 'assets/icons/svg/map.svg',

                  activeIcon: 'assets/icons/svg/map-active.svg',
                  label: 'Community',
                ),
                _buildNavItem(
                  index: 3,
                  icon: 'assets/icons/svg/check-round.svg',

                  activeIcon: 'assets/icons/svg/check-round-active.svg',
                  label: 'Messages',
                ),
                _buildNavItem(
                  index: 4,
                  icon: 'assets/icons/svg/user-circle.svg',

                  activeIcon: 'assets/icons/svg/user-circle-active.svg',
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              isActive ? activeIcon : icon,
              width: 24.sp,
              height: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.brand500 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screen for other tabs
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_outlined,
              size: 64.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16.h),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
