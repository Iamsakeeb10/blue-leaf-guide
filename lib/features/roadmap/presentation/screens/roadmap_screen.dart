import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_title_subtitle_appbar.dart';

class RoadmapScreen extends StatelessWidget {
  RoadmapScreen({super.key});

  final List<Map<String, dynamic>> roadmaps = [
    {
      "title": "Plant Your Roots",
      "buttonLabel": "0-100 hours",
      "subtitle": "Orientation, Confidence, and Professional Foundation.",

      // Section 1: Description text
      "description":
          "Every professional was once a beginner who dared to take the first step. This is where your habits of excellence begin.",

      // Section 2: Focus Goals (list of strings)
      "focusGoals": [
        "Learn your school systems and routines",
        "Build your mindset and time management skills",
        "Organize your tools and create your personal brand vision",
      ],

      // Section 3: Action Checklist (list of strings)
      "actionChecklist": [
        "Set up your Blue Leaf binder or digital folder",
        "Write your mission statement and define your why",
        "Create professional social handles such as @TomekaStyles",
        "Take your first professional photo for social media",
        "Follow 5 inspiring local salons or barbers",
        "Practice sanitation, draping, and basic client setup",
        "Take at least 100 photos of your mannequin work",
        "Arrive 15 minutes early each day for 2 weeks",
        "Keep your workstation clean and organized daily",
        "Record short daily learning reflections",
      ],

      // Section 4: Milestone Reflection (two fields with labels)
      "milestoneReflection": [
        {
          "label":
              "What skill or mindset has grown the most in me since Day One?",
          "value": "",
        },
        {
          "label":
              "What would my future professional self thank me for learning early?",
          "value": "",
        },
      ],
    },

    // Dummy placeholder for other roadmap items No.2
    {
      "title": "Build Your Brand",
      "buttonLabel": "101-300 hours",
      "subtitle": "Identity, Visibility and Confidence in Your Craft.",

      "description":
          "You are your brand. Every post, every card, every conversation is a seed that grows your reputation.",
      "focusGoals": [
        "Create your professional image online and offline",
        "Start building your client list",
        "Establish habits of consistency and accountability",
      ],

      "actionChecklist": [
        "Design and order business cards with a goal to pass out three each day",
        "Create a simple website or online portfolio",
        "Post weekly to your social or business page",
        "Take before and after photos of all work",
        "Inform family, friends, and classmates about your services",
        "Apply for Salon Centric, Cosmotron, and Trustor professional cards",
        "Create a vision board for your dream salon",
        "Find 2 mentors or industry professionals to learn from",
        "Book 10 potential clients by the end of 3 hundred hours",
      ],

      "milestoneReflection": [
        {
          "label": "What does my brand communicate about me right now?",
          "value": "",
        },
        {
          "label": "How consistent have I been with posting and networking?",
          "value": "",
        },
      ],
    },

    // No.3
    {
      "title": "Grow and Connect",
      "buttonLabel": "301-600 hours",
      "subtitle": "Networking, Real Clients and Professional Exposure",

      "description":
          "Your chair is your stage. Every client is your opportunity to build trust and leave an impression that lasts.",

      "focusGoals": [
        "Develop strong client relationships",
        "Network with local salons and spas",
        "Learn the rhythm and expectations of professionalism",
      ],

      "actionChecklist": [
        "Book 15 consistent clients",
        "Pass out a total of five hundred forty business cards",
        "Attend 2 free classes or industry events",
        "Visit 10 salons, spas, or barbershops and assist if possible",
        "Rebook or prebook every client you serve",
        "Reach a total of at least 690 work photos",
        "Create 1 weekly post about what you are learning",
        "Begin collecting client reviews or testimonials",
        "Reflect weekly on what went well and what can improve",
      ],

      "milestoneReflection": [
        {"label": "How does it feel to serve real clients?", "value": ""},
        {"label": "What type of clients inspire me the most?", "value": ""},
      ],
    },

    // No.4
    {
      "title": "Refine and Shine",
      "buttonLabel": "901-1200 hours",
      "subtitle": "Skill Mastery, Reviews and Professionalism",

      "description":
          "You have planted your seeds. Now polish your shine. Let your work, attitude, and consistency speak louder than words.",

      "focusGoals": [
        "Deepen relationships with repeat clients",
        "Refine technique and professionalism",
        "Build your social presence and reputation",
      ],

      "actionChecklist": [
        "Secure 20 repeat clients",
        "Collect at least 10 positive client reviews",
        "Assist or attend 3 different salons or barbershops",
        "Apply to seven job openings or internships",
        "Post weekly Live from School updates",
        "Keep your uniform, tools, and station spotless",
        "Reach a total of 1035 photos of your work",
        "Pass out 810 business cards in total",
        "Write a thank-you note to a mentor or instructor",
      ],

      "milestoneReflection": [
        {
          "label": "What does professionalism mean to me at this stage?",
          "value": "",
        },
        {
          "label": "Which client or mentor feedback influenced me most?",
          "value": "",
        },
      ],
    },

    // No.5
    {
      "title": "Prepare to Launch",
      "buttonLabel": "1201-1500 hours",
      "subtitle": "Job Readiness and Career Direction",

      "description":
          "This is where school meets the real world. You are not waiting for opportunities anymore you are creating them.",

      "focusGoals": [
        "Finalize job opportunities",
        "Strengthen your personal brand and confidence",
        "Learn to interview and present yourself as a professional",
      ],

      "actionChecklist": [
        "Identify your top three salons, spas, or barbershops that inspire you",
        "Assist or shadow in each one",
        "Create a pros and cons list for each potential workplace",
        "Apply for at least 6 positions",
        "Refine your professional portfolio and resume",
        "Practice mock interviews with a mentor or instructor",
        "Reach 1380 total photos of your work",
        "Pass out 1080 business cards in total",
        "Begin preparing for state board examinations",
      ],

      "milestoneReflection": [
        {
          "label": "Where do I see myself thriving after graduation?",
          "value": "",
        },
        {
          "label": "What strengths have I developed that make me employable?",
          "value": "",
        },
      ],
    },

    // No.6
    {
      "title": "Bloom and Graduate",
      "buttonLabel": "1501-1800 hours",
      "subtitle": "Confidence, Consistency and Career Readiness",

      "description":
          "This is your time to bloom. You have put in the work. Now show the world your growth, your integrity, and your light.",

      "focusGoals": [
        "Finalize employment or booth rental",
        "Prepare for state boards with confidence",
        "Demonstrate professionalism in every action and interaction",
      ],

      "actionChecklist": [
        "Prepare and polish your state board kit",
        "Schedule mock practical and theory reviews",
        "Confirm job offer or internship placement",
        "Arrive 15 minutes early every day without exception",
        "Maintain professional dress and presentation",
        "Complete your full tool checklist including ring light, shears, and clips",
        "Reach 1725 total photos of your work",
        "Celebrate your growth by writing a letter to your Day One self",
      ],

      "milestoneReflection": [
        {
          "label":
              "How has this journey transformed not just my skills but my mindset?",
          "value": "",
        },
        {
          "label": "Who am I now compared to the person who first enrolled?",
          "value": "",
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleSubtitleAppbar(
        title: "Roadmap",
        subtitle: "Plan your project phases",
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
        ),
        itemCount: roadmaps.length,
        itemBuilder: (context, index) {
          final item = roadmaps[index];
          final isFirst = index == 0;
          final isLast = index == roadmaps.length - 1;

          return TimelineItem(
            isFirst: isFirst,
            isLast: isLast,
            title: item["title"]!,
            subtitle: item["subtitle"]!,
            buttonLabel: item["buttonLabel"]!,
            completed: index == 0, // mark the first item as completed
            index: index,
            roadmap: item,
          );
        },
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool completed;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final int index;
  final Map<String, dynamic> roadmap;

  const TimelineItem({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.index,
    required this.roadmap,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotSize = 20.r;
    final lineWidth = 2.w;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          context.push('/roadmapDetails', extra: roadmap);
        },
        child: Stack(
          children: [
            // Connector line
            if (!isLast)
              Positioned(
                left: (dotSize - lineWidth) / 2,
                top: dotSize,
                bottom: 0,
                child: Container(
                  width: lineWidth,
                  color: completed
                      ? AppColors.timelinePrimary
                      : AppColors.timelineBorder,
                ),
              ),

            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dot indicator
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: completed
                        ? AppColors.timelinePrimary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: completed
                        ? null // no border if completed
                        : Border.all(
                            color: AppColors.timelineBorder,
                            width: 2.w,
                          ),
                  ),
                  child: completed
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : null,
                ),

                SizedBox(width: 16.w),

                // Content area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 32.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.sp,
                              color: AppColors.textPrimary.withOpacity(0.8),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: index.isOdd
                                ? Color(0xFFEFE5FA) // odd items color
                                : AppColors
                                      .lightGrey, // default color for even items
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            buttonLabel,
                            style: TextStyle(
                              color: AppColors.textPrimary.withOpacity(0.8),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.3, // line-height: 130%
                              letterSpacing: -0.01 * 10, // letter-spacing: -1%
                            ),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Subtitle
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 200.w,
                          ), // set your max width
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
