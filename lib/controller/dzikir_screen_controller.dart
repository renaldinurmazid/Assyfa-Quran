import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  void increment() {
    if (dzikirCount.value >= maxDzikirCount.value) {
      dzikirCount.value = 0;
    }
    dzikirCount.value++;
  }
}
