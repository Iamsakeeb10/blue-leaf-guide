import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/custom_appbar.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  int _messageCount = 0;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(ChatMessage(text: _controller.text.trim(), isUser: true));

      // Add AI response
      _messageCount++;
      _messages.add(
        ChatMessage(text: _getAIResponse(_messageCount), isUser: false),
      );
    });

    _controller.clear();

    // Scroll to bottom after messages are added
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _getAIResponse(int count) {
    final responses = [
      "That's a great question! Building a client base starts with excellent service and word-of-mouth referrals. Focus on creating memorable experiences for each client.",
      "For salon interviews, showcase your portfolio, demonstrate your passion for cosmetology, and be prepared to discuss your techniques and client interaction style.",
      "Improving cutting technique requires practice and continuous learning. Consider attending workshops, watching tutorials, and practicing on mannequins regularly.",
      "Social media is crucial for cosmetologists! Post before-and-after photos, share beauty tips, engage with followers, and use relevant hashtags to grow your audience.",
      "Remember, consistency is key in building your brand. Stay authentic and let your unique style shine through in everything you do!",
    ];
    return responses[(count - 1) % responses.length];
  }

  void _onFeatureBoxTap(String text) {
    _controller.text = text;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        hideRightIcon: false,
        title: "AI Tutor",
        rightIconPath: "assets/icons/svg/history.svg",
        onRightTap: () => context.push('/chat-history'),
      ),
      body: Column(
        children: [
          /// ---------- MESSAGES OR WELCOME SCREEN ----------
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : _buildMessagesList(),
          ),

          /// ---------- 4 BOXES (only show when no messages) ----------
          if (_messages.isEmpty) _buildFeatureBoxes(),

          SizedBox(height: _messages.isEmpty ? 12.h : 8.h),

          /// ---------- INPUT BAR ----------
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// PNG ICON
            Image.asset(
              "assets/images/gemini-chat.png",
              width: 72.w,
              height: 72.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24.h),

            /// Title
            Text(
              "Welcome to Your AI Tutor",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            SizedBox(height: 8.h),

            /// Subtitle with max width
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300.w),
              child: Text(
                "Ask me anything about cosmetology, career advice, or building your brand",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return message.isUser
            ? _buildUserMessage(message.text)
            : _buildAIMessage(message.text);
      },
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: const Color(0x0D090F05), // #090F050D (5% opacity)
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Gemini icon
          Image.asset(
            "assets/images/gemini-chat.png",
            width: 35.w,
            height: 35.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),

          /// Message text
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBoxes() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFeatureBox("How do I build my client base?"),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildFeatureBox("Tips for my first salon interview?"),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildFeatureBox("How to improve my cutting technique?"),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildFeatureBox(
                  "Social media tips for cosmetologists?",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox(String title) {
    return GestureDetector(
      onTap: () => _onFeatureBoxTap(title),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          4.h,
          16.w,
          MediaQuery.of(context).padding.bottom + 16.h,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              width: 1.5,
              color: AppColors.textPrimary.withOpacity(0.05),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Multi-line TextField
              Flexible(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: "Ask tutor anything...",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
              ),

              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  "assets/icons/svg/file.svg",
                  width: 20.w,
                  height: 20.w,
                ),
              ),

              SizedBox(width: 10.w),

              /// Send button
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.brand500,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/svg/send.svg",
                      width: 20.w,
                      height: 20.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
