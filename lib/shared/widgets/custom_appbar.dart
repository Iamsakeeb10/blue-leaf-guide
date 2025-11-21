import 'package:flutter/material.dart' hide BackButtonIcon;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import 'back_button_icon.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool hideBackButton; // <-- new optional prop

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.hideBackButton = false, // default false
  });

  @override
  Size get preferredSize => Size.fromHeight(55.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // don't add padding at bottom
      child: Container(
        height: preferredSize.height,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hideBackButton)
              Align(
                alignment: Alignment.centerLeft,
                child: BackButtonIcon(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                ),
              ),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  letterSpacing: -0.01 * 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
