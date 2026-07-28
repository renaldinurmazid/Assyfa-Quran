import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';
import 'package:quran_app/models/chat_bot_model.dart';
import 'package:quran_app/widgets/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBotController extends GetxController {
  final textController = TextEditingController();
  final messages = <ChatMessage>[].obs;
  final sessions = <ChatSession>[].obs;

  final isWaitingReply = false.obs;
  final isLoadingSessions = false.obs;
  final isLoadingHistory = false.obs;

  int? currentSessionId;
  String? _guestId;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initGuestId().then((_) {
      getSessions();
    });

    // Add default greeting
    messages.add(
      ChatMessage(
        content:
            "Assalamu'alaikum! Saya Una, asisten virtual Islami Anda. Ada yang bisa Una bantu hari ini?",
        role: 'model',
        isUser: false,
      ),
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _initGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    _guestId = prefs.getString('guest_id');
    if (_guestId == null) {
      // Generate a random guest ID
      final rand = Random();
      _guestId =
          'guest_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(10000)}';
      await prefs.setString('guest_id', _guestId!);
    }
  }

  Future<void> getSessions() async {
    if (_guestId == null) return;
    isLoadingSessions.value = true;
    try {
      final response = await Request().get(
        '${Url.chatBotSessions}?guest_id=$_guestId',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List data = response.data['data'];
        sessions.value = data.map((e) => ChatSession.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error getting sessions: $e');
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> loadSession(int sessionId) async {
    if (_guestId == null) return;
    isLoadingHistory.value = true;
    currentSessionId = sessionId;

    try {
      final response = await Request().get(
        '${Url.chatBotSessions}/$sessionId?guest_id=$_guestId',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final sessionData = ChatSession.fromJson(response.data['data']);
        messages.value = sessionData.messages;
        _scrollToBottom();
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat riwayat obrolan', title: 'Error');
      debugPrint('Error getting messages: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void startNewChat() {
    currentSessionId = null;
    messages.clear();
    messages.add(
      ChatMessage(
        content:
            "Assalamu'alaikum! Saya Una, asisten virtual Islami Anda. Ada yang bisa Syifa bantu hari ini?",
        role: 'model',
        isUser: false,
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // Add user message to UI immediately
    messages.add(ChatMessage(content: text, role: 'user', isUser: true));
    textController.clear();
    _scrollToBottom();

    isWaitingReply.value = true;

    try {
      final response = await Request().post(
        Url.chatBotSend,
        data: {
          'message': text,
          'chat_session_id': currentSessionId,
          'guest_id': _guestId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['session'] != null) {
          final updatedSession = ChatSession.fromJson(responseData['session']);
          // If this is a new session, update currentSessionId and reload sessions
          if (currentSessionId == null) {
            currentSessionId = updatedSession.id;
            getSessions(); // Refresh history
          }
        }

        if (responseData['reply_message'] != null) {
          final reply = ChatMessage.fromJson(responseData['reply_message']);
          messages.add(reply);
          _scrollToBottom();
        }
      }
    } catch (e) {
      AppToast.error(message: 'Gagal mengirim pesan', title: 'Error');
      // Fallback response for UI demo if needed, or just let user try again.
    } finally {
      isWaitingReply.value = false;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
