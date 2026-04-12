import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rom_tracker_app/core/constants/app_colors.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_store.dart';
import 'package:rom_tracker_app/features/chat/presentation/models/chat_thread.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({
    super.key,
    required this.userType,
    required this.threadId,
  });

  final String userType;
  final String threadId;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _showAttachmentSheet = false;

  ChatThread? get _thread =>
      ChatStore.threadById(widget.userType, widget.threadId);

  @override
  void initState() {
    super.initState();
    ChatStore.markRead(widget.userType, widget.threadId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;
    if (thread == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Conversation not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.asset(
                    thread.avatarPath,
                    width: 40.w,
                    height: 40.w,
                    fit: BoxFit.cover,
                  ),
                ),
                if (thread.isOnline)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.name,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  thread.subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.primary),
            onPressed: () => _comingSoon(context, 'Video call'),
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.primary),
            onPressed: () => _comingSoon(context, 'Voice call'),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: ChatStore.messagesFor(widget.threadId),
              builder: (context, messages, _) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          if (_showAttachmentSheet) _buildAttachmentSheet(),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final hasText = _messageController.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFD6DEE8)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: const Color(0xFFB0B8C8),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: Color(0xFF7E8AA5)),
                      onPressed: () => _comingSoon(context, 'Camera sharing'),
                    ),
                    IconButton(
                      icon: Icon(
                        _showAttachmentSheet
                            ? Icons.close_rounded
                            : Icons.attach_file_rounded,
                        color: const Color(0xFF7E8AA5),
                      ),
                      onPressed: () {
                        setState(() => _showAttachmentSheet = !_showAttachmentSheet);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: hasText
                  ? _sendMessage
                  : () => _comingSoon(context, 'Voice note'),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasText ? Icons.send_rounded : Icons.mic_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSheet() {
    final items = [
      ('Camera', Icons.camera_alt_outlined, const Color(0xFFFF6B6B)),
      ('Record', Icons.mic_rounded, const Color(0xFF63C9FF)),
      ('Contact', Icons.person_rounded, const Color(0xFF3B82F6)),
      ('Gallery', Icons.image_outlined, const Color(0xFFFBBF24)),
      ('My Location', Icons.location_on_outlined, const Color(0xFF38BDF8)),
      ('Document', Icons.insert_drive_file_outlined, const Color(0xFF4ADE80)),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Wrap(
        runSpacing: 22.h,
        spacing: 0,
        children: items.map((item) {
          return SizedBox(
            width: (1.sw - 40.w) / 3,
            child: InkWell(
              onTap: () {
                setState(() => _showAttachmentSheet = false);
                _comingSoon(context, item.$1);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: item.$3.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.$2, color: item.$3),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    item.$1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    ChatStore.sendText(
      userType: widget.userType,
      threadId: widget.threadId,
      text: text,
    );
    _messageController.clear();
    setState(() {});
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is not available yet')),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: message.isMe ? 80.w : 6.w,
              right: message.isMe ? 6.w : 80.w,
              bottom: 4.h,
            ),
            child: Text(
              message.time,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF9AA5B5),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            constraints: BoxConstraints(maxWidth: 0.72.sw),
            decoration: BoxDecoration(
              color: message.isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: message.isMe ? Radius.circular(18.r) : Radius.zero,
                bottomRight: message.isMe ? Radius.zero : Radius.circular(18.r),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                color: message.isMe ? Colors.white : const Color(0xFF2B2B2B),
                fontSize: 14.sp,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
