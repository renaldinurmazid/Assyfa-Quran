import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/screen/dzikir&doa/list_doa_screen_controller.dart';
import 'package:quran_app/theme/font.dart';

class ListDoaScreen extends StatelessWidget {
  const ListDoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ListDoaScreenController());
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: context.theme.colorScheme.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Kumpulan Doa',
                style: pBold18.copyWith(color: Colors.white),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.theme.colorScheme.primary,
                          context.theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      IconlyLight.document,
                      size: 150,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(IconlyLight.arrow_left_2, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return SizedBox(
                  height: Get.height * 0.7,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                );
              }

              if (controller.data.isEmpty) {
                return SizedBox(
                  height: Get.height * 0.7,
                  child: Center(
                    child: Text(
                      'Tidak ada data doa',
                      style: pRegular14.copyWith(
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final doa = controller.data[index];
                  return _DoaCard(doa: doa, index: index + 1);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: controller.data.length,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DoaCard extends StatefulWidget {
  final dynamic doa;
  final int index;

  const _DoaCard({required this.doa, required this.index});

  @override
  State<_DoaCard> createState() => _DoaCardState();
}

class _DoaCardState extends State<_DoaCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index}',
                          style: pBold16.copyWith(
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doa.nama,
                            style: pBold16.copyWith(
                              color: context.theme.colorScheme.primary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.doa.grup,
                            style: pMedium10.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? IconlyLight.arrow_up_2
                          : IconlyLight.arrow_down_2,
                      color: context.theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      // Teks Arab
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.primary.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.theme.colorScheme.primary.withOpacity(0.05),
                          ),
                        ),
                        child: Text(
                          widget.doa.ar,
                          style: GoogleFonts.amiri(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 2.2,
                            color: context.theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Transliterasi Latin
                      Text(
                        'Artinya:',
                        style: pBold12.copyWith(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.doa.idn,
                        style: pRegular14.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 20),
                      // Row Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      "${widget.doa.nama}\n\n${widget.doa.ar}\n\n${widget.doa.idn}",
                                ),
                              );
                              Get.snackbar(
                                'Berhasil',
                                'Doa berhasil disalin',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: context.theme.colorScheme.primary,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(20),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: context.theme.colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
