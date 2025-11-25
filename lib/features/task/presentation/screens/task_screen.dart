import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/custom_segment_tab.dart';
import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String title = "Daily Task";
  String subtitle = "Manage your daily tasks";

  final List<String> tabs = ["Daily Task", "Check-in", "Monthly Goal"];
  final List<String> subtitles = [
    "Manage your daily tasks",
    "Check your progress",
    "Track your monthly goals",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging)
        return; // wait for animation to finish
      setState(() {
        title = tabs[_tabController.index];
        subtitle = subtitles[_tabController.index];
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTitleSubtitleAppbar(title: title, subtitle: subtitle),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomSegmentTab(
                tabs: tabs,
                tabViews: [
                  Center(child: Text("Daily Task Content")),
                  Center(child: Text("Check-in Content")),
                  Center(child: Text("Monthly Goal Content")),
                ],
                // Pass the same TabController so we can listen for index changes
                controller: _tabController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
