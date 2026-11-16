// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class RootScreen extends StatelessWidget {
//   const RootScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(RootController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: OrientationBuilder(
//           builder: (context, orientation) {
//             // Adjust settings based on orientation
//             final isLandscape = orientation == Orientation.landscape;

//             return PageView.builder(
//               controller: controller.pageController,
//               onPageChanged: controller.onPageChanged,
//               reverse: true, // Right-to-left direction for Arabic reading
//               itemCount: controller.totalPages,
//               itemBuilder: (context, index) {
//                 int pageNumber = index + 1;
//                 String imageUrl = controller.getImageUrl(pageNumber);

//                 // Build the image widget
//                 Widget imageWidget = Image.network(
//                   imageUrl,
//                   fit: isLandscape ? BoxFit.fitWidth : BoxFit.contain,
//                   width: double.infinity,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Center(
//                       child: CircularProgressIndicator(
//                         value: loadingProgress.expectedTotalBytes != null
//                             ? loadingProgress.cumulativeBytesLoaded /
//                                   loadingProgress.expectedTotalBytes!
//                             : null,
//                         color: Colors.white,
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Failed to load page $pageNumber',
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );

//                 // In landscape mode, use SingleChildScrollView for vertical scrolling
//                 // In portrait mode, use InteractiveViewer for zoom functionality
//                 if (isLandscape) {
//                   return SingleChildScrollView(child: imageWidget);
//                 } else {
//                   return InteractiveViewer(
//                     minScale: 2.0,
//                     maxScale: 4.0,
//                     child: Center(child: imageWidget),
//                   );
//                 }
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
