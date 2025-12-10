// lib/shared/widgets/custom_popup_menu.dart
import 'package:blue_leaf_guide/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ==================== SIMPLE MENU POPUP (No Selection State) ====================
class CustomPopupMenu extends StatelessWidget {
  final List<PopupMenuItemData> items;
  final String? iconPath;

  const CustomPopupMenu({Key? key, required this.items, this.iconPath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: Offset(-20.w, 0.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Colors.white,
      padding: EdgeInsets.zero,
      elevation: 4,
      onSelected: (index) {
        items[index].onPressed();
      },
      itemBuilder: (context) => List.generate(
        items.length,
        (index) => PopupMenuItem<int>(
          value: index,
          padding: EdgeInsets.zero,
          child: _SimpleMenuItem(
            item: items[index],
            isLast: index == items.length - 1,
          ),
        ),
      ),
      child: SvgPicture.asset(
        iconPath ?? 'assets/icons/svg/more.svg',
        width: 24.w,
        height: 24.h,
      ),
    );
  }
}

class _SimpleMenuItem extends StatelessWidget {
  final PopupMenuItemData item;
  final bool isLast;

  const _SimpleMenuItem({Key? key, required this.item, required this.isLast})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(minWidth: 120.w),
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
          child: Center(
            child: Text(
              item.text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: item.textColor ?? AppColors.textPrimary.withOpacity(0.8),
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1.25.h,
            thickness: 1.25.h,
            color: AppColors.textPrimary.withOpacity(0.05),
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}

// ==================== SELECTABLE MENU POPUP (With Checkmark) ====================
class SelectablePopupMenu extends StatelessWidget {
  final List<SelectableMenuItemData> items;
  final String? iconPath;

  const SelectablePopupMenu({Key? key, required this.items, this.iconPath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: Offset(-20.w, 0.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Colors.white,
      padding: EdgeInsets.zero,
      elevation: 4,
      onSelected: (index) {
        items[index].onPressed();
      },
      itemBuilder: (context) => List.generate(
        items.length,
        (index) => PopupMenuItem<int>(
          value: index,
          padding: EdgeInsets.zero,
          child: _SelectableMenuItem(
            item: items[index],
            isLast: index == items.length - 1,
          ),
        ),
      ),
      child: SvgPicture.asset(
        iconPath ?? 'assets/icons/svg/filter.svg',
        width: 24.w,
        height: 24.h,
      ),
    );
  }
}

class _SelectableMenuItem extends StatelessWidget {
  final SelectableMenuItemData item;
  final bool isLast;

  const _SelectableMenuItem({
    Key? key,
    required this.item,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(minWidth: 120.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color:
                      item.textColor ?? AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
              if (item.isSelected)
                SvgPicture.asset(
                  item.checkIconPath ?? 'assets/icons/svg/tick.svg',
                  width: 16.w,
                  height: 16.h,
                )
              else
                SizedBox(width: 16.w), // Placeholder to maintain spacing
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1.25.h,
            thickness: 1.25.h,
            color: AppColors.textPrimary.withOpacity(0.05),
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}

// ==================== DATA MODELS ====================
class PopupMenuItemData {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;

  PopupMenuItemData({
    required this.text,
    required this.onPressed,
    this.textColor,
  });
}

class SelectableMenuItemData {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final bool isSelected;
  final String? checkIconPath;

  SelectableMenuItemData({
    required this.text,
    required this.onPressed,
    this.textColor,
    required this.isSelected,
    this.checkIconPath,
  });
}

// ==================== USAGE EXAMPLES ====================
// 
// ========== 1. SIMPLE MENU (Edit/Delete) ==========
//
// CustomPopupMenu(
//   iconPath: 'assets/icons/svg/more.svg',
//   items: [
//     PopupMenuItemData(
//       text: 'Edit',
//       textColor: AppColors.textPrimary.withOpacity(0.8),
//       onPressed: () {
//         context.push(
//           '/add-client',
//           extra: {
//             'clientId': clientId,
//             'clientData': client,
//           },
//         );
//       },
//     ),
//     PopupMenuItemData(
//       text: 'Delete',
//       textColor: AppColors.errorRed,
//       onPressed: () {
//         _showDeleteDialog(context, clientId);
//       },
//     ),
//   ],
// ),
//
// ========== 2. SELECTABLE MENU (With Checkmarks) ==========
//
// SelectablePopupMenu(
//   iconPath: 'assets/icons/svg/filter.svg',
//   items: [
//     SelectableMenuItemData(
//       text: 'All Clients',
//       isSelected: true, // Shows checkmark
//       onPressed: () {
//         // Handle filter change
//       },
//     ),
//     SelectableMenuItemData(
//       text: 'Active Only',
//       isSelected: false, // No checkmark
//       onPressed: () {
//         // Handle filter change
//       },
//     ),
//     SelectableMenuItemData(
//       text: 'Inactive Only',
//       isSelected: false,
//       onPressed: () {
//         // Handle filter change
//       },
//     ),
//   ],
// ),
//
// ========== 3. CUSTOM COLORS ==========
//
// SelectablePopupMenu(
//   items: [
//     SelectableMenuItemData(
//       text: 'Premium',
//       textColor: Colors.purple,
//       isSelected: true,
//       checkIconPath: 'assets/icons/svg/star.svg', // Custom icon
//       onPressed: () {},
//     ),
//     SelectableMenuItemData(
//       text: 'Regular',
//       isSelected: false,
//       onPressed: () {},
//     ),
//   ],
// ),