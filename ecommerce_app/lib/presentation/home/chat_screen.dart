import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'text': text, 'isMe': true});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Support Chat',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF26215C),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: const Color(0xFFEEEDFE),
              child: Icon(Icons.headset_mic_outlined,
                  size: 18.r, color: const Color(0xFF534AB7)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64.r, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                        fontSize: 15.sp, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Start a conversation\nwith our support team.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF534AB7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isMe
                            ? Colors.white
                            : const Color(0xFF26215C),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Input bar ──────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EFE8),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            fontSize: 13.sp, color: Colors.grey[400]),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44.r, height: 44.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF534AB7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.send_rounded,
                        size: 20.r, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}