import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/models/chat_bot_model.dart';
import 'package:quran_app/screen/chat-bot/chat_bot_controller.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatBotController());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 24, color: AppColor.textColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primaryColor.withOpacity(0.2),
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/png/profile-chat-bot.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kak Una',
                  style: pSemiBold16.copyWith(color: AppColor.textColor),
                ),
                Text(
                  'Asisten Virtual Islami',
                  style: pRegular12.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColor.textColor),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      drawer: _buildDrawer(controller),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }

              final messagesCount = controller.messages.length;
              final showTyping = controller.isWaitingReply.value;
              final totalCount = messagesCount + (showTyping ? 1 : 0);

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  if (index == messagesCount && showTyping) {
                    return _buildTypingIndicator();
                  }
                  final message = controller.messages[index];
                  return _buildChatBubble(message);
                },
              );
            }),
          ),
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  Widget _buildDrawer(ChatBotController controller) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(0)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimalist Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat',
                    style: pSemiBold16.copyWith(
                      color: AppColor.textColor,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.startNewChat();
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.add,
                      color: AppColor.textColor,
                      size: 20,
                    ),
                    tooltip: 'Chat Baru',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: Colors.grey.shade200,
                height: 1,
                thickness: 1,
              ),
            ),
            const SizedBox(height: 16),

            // List of Sessions
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSessions.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                      strokeWidth: 2,
                    ),
                  );
                }
                if (controller.sessions.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada obrolan',
                      style: pRegular14.copyWith(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  itemCount: controller.sessions.length,
                  itemBuilder: (context, index) {
                    final session = controller.sessions[index];
                    final isSelected =
                        controller.currentSessionId == session.id;

                    return InkWell(
                      onTap: () {
                        controller.loadSession(session.id);
                        Get.back(); // close drawer
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.grey.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              Container(
                                width: 3,
                                height: 16,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                            else
                              const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pMedium14.copyWith(
                                  color: isSelected
                                      ? AppColor.primaryColor
                                      : AppColor.textColor.withOpacity(0.7),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColor.primaryColor.withOpacity(0.1),
            child: ClipOval(
              child: Image.asset(
                'assets/images/png/profile-chat-bot.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildDot(0), _buildDot(150), _buildDot(300)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double val, child) {
        return Opacity(
          opacity: (val > 0.5 ? 1.0 - val : val) * 2, // pulsing effect
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColor.primaryColor.withOpacity(0.1),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/png/profile-chat-bot.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            const SizedBox(width: 48),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColor.primaryColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
              ),
              child: MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: pRegular14.copyWith(
                    color: message.isUser ? Colors.white : AppColor.textColor,
                    height: 1.4,
                  ),
                  strong: pBold14.copyWith(
                    color: message.isUser ? Colors.white : AppColor.textColor,
                    height: 1.4,
                  ),
                  em: pRegular14.copyWith(
                    color: message.isUser ? Colors.white : AppColor.textColor,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
          if (!message.isUser) ...[const SizedBox(width: 48)],
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatBotController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Obx(
                  () => TextField(
                    controller: controller.textController,
                    style: pRegular14.copyWith(color: AppColor.textColor),
                    enabled: !controller.isWaitingReply.value,
                    decoration: InputDecoration(
                      hintText: 'Tanya Kak Una...',
                      hintStyle: pRegular14.copyWith(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(
              () => GestureDetector(
                onTap: controller.isWaitingReply.value
                    ? null
                    : controller.sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.isWaitingReply.value
                        ? Colors.grey
                        : AppColor.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
