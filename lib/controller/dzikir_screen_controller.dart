import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran_app/api/request.dart';
import 'package:quran_app/api/url.dart';

class DzikirScreenController extends GetxController {
  final dzikirInputController = TextEditingController();
  final dzikirInputText = ''.obs;
  final listData = [
    {'label': 'x3', 'value': 3},
    {'label': 'x33', 'value': 33},
    {'label': 'x100', 'value': 100},
    {'label': 'x1000', 'value': 1000},
  ];
  final dzikirCount = 0.obs;
  final maxDzikirCount = 3.obs;

  final dzikirStats = <String, int>{}.obs;
  final isLoadingStats = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDzikirStats();
  }

  Future<void> fetchDzikirStats() async {
    isLoadingStats.value = true;
    try {
      final response = await Request().get(Url.dzikirStats);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final Map<String, dynamic> data = response.data['data'];
        dzikirStats.value = data.map(
          (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0),
        );
      }
    } catch (e) {
      print('Error fetching dzikir stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> recordDzikirView(String slug, String title) async {
    try {
      await Request().post(
        Url.dzikirView,
        data: {
          'slug': slug,
          'title': title,
        },
      );
    } catch (e) {
      print('Error recording dzikir view: $e');
    }
  }

  void increment() {
    if (dzikirCount.value >= maxDzikirCount.value) {
      dzikirCount.value = 0;
    }
    dzikirCount.value++;

    if (dzikirCount.value == maxDzikirCount.value) {
      HapticFeedback.vibrate();
    }
  }
}
