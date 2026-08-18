// import 'dart:convert'; // WebSocket - dinonaktifkan sementara
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:web_socket_channel/web_socket_channel.dart'; // WebSocket - dinonaktifkan sementara
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
  final showContactAdmin = false.obs;

  int? currentSessionId;
  String? _guestId;
  // WebSocketChannel? _channel; // WebSocket - dinonaktifkan sementara
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
            "Assalamu'alaikum! Saya Una, asisten virtual Quranuna. Ada yang bisa Una bantu hari ini?",
        role: 'model',
        isUser: false,
      ),
    );
  }

  @override
  void onClose() {
    // _channel?.sink.close(); // WebSocket - dinonaktifkan sementara
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
        // _connectWebSocket(sessionId); // WebSocket - dinonaktifkan sementara
      }
    } catch (e) {
      AppToast.error(message: 'Gagal memuat riwayat obrolan', title: 'Error');
      debugPrint('Error getting messages: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> deleteSession(int sessionId) async {
    if (_guestId == null) return;
    try {
      final response = await Request().delete(
        '${Url.chatBotSessions}/$sessionId?guest_id=$_guestId',
      );
      if (response.statusCode == 200) {
        sessions.removeWhere((element) => element.id == sessionId);
        if (currentSessionId == sessionId) {
          startNewChat();
        }
        AppToast.success(message: 'Riwayat obrolan berhasil dihapus');
      }
    } catch (e) {
      AppToast.error(
        message: 'Gagal menghapus riwayat obrolan',
        title: 'Error',
      );
      debugPrint('Error deleting session: $e');
    }
  }

  void startNewChat() {
    // _channel?.sink.close(); // WebSocket - dinonaktifkan sementara
    // _channel = null;
    currentSessionId = null;
    showContactAdmin.value = false;
    messages.clear();
    messages.add(
      ChatMessage(
        content:
            "Assalamu'alaikum! Saya Una, asisten virtual Quranuna. Ada yang bisa Una bantu hari ini?",
        role: 'model',
        isUser: false,
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    // Reset contact admin banner setiap kali user kirim pesan baru
    showContactAdmin.value = false;

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
            // _connectWebSocket(currentSessionId!); // WebSocket - dinonaktifkan sementara
          }
        }

        if (responseData['user_message'] != null) {
          final uMsg = ChatMessage.fromJson(responseData['user_message']);
          final optimisticIndex = messages.indexWhere(
            (m) =>
                m.id == null &&
                m.content == uMsg.content &&
                m.role == uMsg.role,
          );
          if (optimisticIndex != -1) {
            messages[optimisticIndex] = uMsg;
          }
        }

        // Cek flag is_escalated dari API
        final isEscalated = responseData['is_escalated'] == true;

        if (responseData['reply_message'] != null) {
          final reply = ChatMessage.fromJson(responseData['reply_message']);
          if (!messages.any((m) => m.id == reply.id)) {
            messages.add(reply);
            _scrollToBottom();
          }
        }

        // Tampilkan banner kontak admin jika: AI eskalasi atau tidak ada balasan
        if (isEscalated || responseData['reply_message'] == null) {
          showContactAdmin.value = true;
        }
      } else {
        // Status code bukan 200 — AI gagal menjawab
        showContactAdmin.value = true;
        AppToast.error(message: 'Gagal mengirim pesan', title: 'Error');
      }
    } catch (e) {
      debugPrint('sendMessage error: $e');
      showContactAdmin.value = true;
      AppToast.error(message: 'Gagal mengirim pesan', title: 'Error');
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

  // ============================================================
  // WebSocket / Reverb - dinonaktifkan sementara
  // Aktifkan kembali setelah SSL Reverb di production sudah setup
  // ============================================================
  // void _connectWebSocket(int sessionId) {
  //   _channel?.sink.close();
  //   try {
  //     _channel = WebSocketChannel.connect(Uri.parse(Url.reverbWsUrl));
  //
  //     // Pusher protocol subscription
  //     _channel!.sink.add(
  //       jsonEncode({
  //         "event": "pusher:subscribe",
  //         "data": {"channel": "chat.$sessionId"},
  //       }),
  //     );
  //
  //     _channel!.stream.listen(
  //       (message) {
  //         try {
  //           final data = jsonDecode(message);
  //           if (data['event'] == 'App\\Events\\MessageSent') {
  //             final payload = jsonDecode(data['data']);
  //             if (payload['message'] != null) {
  //               final newMsg = ChatMessage.fromJson(payload['message']);
  //               if (!messages.any((m) => m.id == newMsg.id)) {
  //                 final optimisticIndex = messages.indexWhere(
  //                   (m) =>
  //                       m.id == null &&
  //                       m.content == newMsg.content &&
  //                       m.role == newMsg.role,
  //                 );
  //                 if (optimisticIndex != -1) {
  //                   messages[optimisticIndex] = newMsg;
  //                 } else {
  //                   messages.add(newMsg);
  //                   _scrollToBottom();
  //                 }
  //               }
  //             }
  //           }
  //         } catch (e) {
  //           debugPrint('Error parsing websocket message: $e');
  //         }
  //       },
  //       onError: (error) => debugPrint('WebSocket Error: $error'),
  //       onDone: () => debugPrint('WebSocket closed'),
  //     );
  //   } catch (e) {
  //     debugPrint('Error connecting to WebSocket: $e');
  //   }
  // }

}
