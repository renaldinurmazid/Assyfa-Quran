// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class RootController extends GetxController {
//   var isLoading = false.obs;
//   var currentPage = 1.obs;
//   late PageController pageController;

//   // Total pages in the Quran (604 pages)
//   final int totalPages = 604;

//   @override
//   void onInit() {
//     super.onInit();
//     pageController = PageController(initialPage: 0);
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }

//   String getImageUrl(int page) {
//     String pageNumber = page.toString().padLeft(3, '0');
//     return 'https://cdn.statically.io/gh/agusibrahim/quran-image/main/md-tajwid/$pageNumber.png';
//   }

//   void onPageChanged(int index) {
//     currentPage.value = index + 1;
//   }
// }
