import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:latlong2/latlong.dart';
import 'package:quran_app/controller/mosque_charity_controller.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class MosqueMapScreen extends StatelessWidget {
  const MosqueMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MosqueCharityController>();

    // Initial center point (default: Subang, or first mosque in list)
    LatLng initialCenter = const LatLng(-6.5715, 107.7587);
    if (controller.mosqueCharityList.isNotEmpty) {
      final first = controller.mosqueCharityList.first;
      final lat = double.tryParse(first.latitude ?? '') ?? -6.5715;
      final lng = double.tryParse(first.longitude ?? '') ?? 107.7587;
      initialCenter = LatLng(lat, lng);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left_2, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Lokasi Masjid',
          style: pBold16.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.assyfa.quran_app',
              ),
              MarkerLayer(
                markers: controller.mosqueCharityList.map((mosque) {
                  final double lat =
                      double.tryParse(mosque.latitude ?? '') ?? 0;
                  final double lng =
                      double.tryParse(mosque.longitude ?? '') ?? 0;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        _showMosqueInfo(context, mosque);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: AppColor.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(mosque.coverImage),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: AppColor.primaryColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMosqueInfo(BuildContext context, dynamic mosque) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    mosque.coverImage,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: pBold16.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mosque.address,
                        style: pRegular12.copyWith(color: Colors.black45),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terkumpul',
                      style: pMedium10.copyWith(color: Colors.black38),
                    ),
                    Text(
                      'Rp ${mosque.currentAmount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                      style: pBold16.copyWith(color: AppColor.primaryColor),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      Routes.mosqueCharityShow,
                      arguments: {'id': mosque.id},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Infaq Sekarang',
                    style: pBold12.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
