import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/models/daily_activity/activity_group_model.dart';
import 'package:quran_app/screen/daily_activity/activity_group_controller.dart';
import 'package:quran_app/screen/daily_activity/text_input_dialog.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ActivityGroupScreen extends StatelessWidget {
  const ActivityGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<ActivityGroupController>()) {
      Get.delete<ActivityGroupController>();
    }
    final controller = Get.put(ActivityGroupController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.detail.value?.group.name ?? 'Grup Aktivitas',
            style: pSemiBold16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
        ),
        actions: [
          Obx(() {
            if (controller.detail.value?.group.isOwner != true) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton<String>(
              icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
              onSelected: (v) {
                if (v == 'rename') _renameDialog(controller);
                if (v == 'delete') _deleteDialog(controller);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Ubah nama grup')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Hapus grup',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final detail = controller.detail.value;
          if (detail == null) {
            return Center(
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : TextButton(
                      onPressed: controller.load,
                      child: const Text('Coba lagi'),
                    ),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _CodeCard(controller: controller, group: detail.group),
                const SizedBox(height: 24),
                Text('Anggota (${detail.members.length})', style: pBold14),
                const SizedBox(height: 12),
                for (final m in detail.members)
                  _MemberTile(
                    controller: controller,
                    member: m,
                    canRemove: detail.group.isOwner && !m.isOwner,
                  ),
                if (!detail.group.isOwner) ...[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _leaveDialog(controller),
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: const Text('Keluar dari grup'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  final ActivityGroupController controller;
  final ActivityGroup group;
  const _CodeCard({required this.controller, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.primaryColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kode grup',
            style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  group.code,
                  style: pBold24.copyWith(
                    letterSpacing: 4,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Salin',
                onPressed: controller.copyCode,
                icon: const Icon(LucideIcons.copy, size: 20),
              ),
              IconButton(
                tooltip: 'Bagikan',
                onPressed: controller.shareCode,
                icon: const Icon(LucideIcons.share2, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Anggota baru bergabung lewat Aktivitas Harian → Buat / gabung grup.',
            style: pRegular12.copyWith(color: AppColor.globalTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final ActivityGroupController controller;
  final ActivityGroupMember member;
  final bool canRemove;
  const _MemberTile({
    required this.controller,
    required this.member,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    final picture = member.profilePicture;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColor.globalBorder,
            backgroundImage: (picture != null && picture.isNotEmpty)
                ? NetworkImage(picture)
                : null,
            child: (picture == null || picture.isEmpty)
                ? const Icon(LucideIcons.user, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pSemiBold14,
            ),
          ),
          if (member.isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Pembuat',
                style: pSemiBold12.copyWith(color: AppColor.primaryColor),
              ),
            ),
          if (canRemove)
            IconButton(
              tooltip: 'Keluarkan',
              onPressed: () => _removeDialog(controller, member),
              icon: const Icon(LucideIcons.userMinus, size: 18),
              color: Colors.red,
            ),
        ],
      ),
    );
  }
}

// ─── dialogs ─────────────────────────────────────────────────────────────────

void _renameDialog(ActivityGroupController controller) {
  showTextInputDialog(
    title: 'Ubah nama grup',
    confirmLabel: 'Simpan',
    initialValue: controller.detail.value?.group.name,
    onSubmit: controller.rename,
  );
}

void _deleteDialog(ActivityGroupController controller) {
  Get.dialog(
    AlertDialog(
      title: Text('Hapus grup?', style: pBold18),
      content: const Text(
        'Grup, daftar aktivitasnya, dan seluruh riwayat centang anggota akan '
        'dihapus untuk semua orang. Tindakan ini tidak bisa dibatalkan.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteGroup();
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _leaveDialog(ActivityGroupController controller) {
  Get.dialog(
    AlertDialog(
      title: Text('Keluar dari grup?', style: pBold18),
      content: const Text(
        'Anda bisa bergabung lagi nanti dengan kode grup yang sama.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.leaveGroup();
          },
          child: const Text('Keluar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _removeDialog(
  ActivityGroupController controller,
  ActivityGroupMember member,
) {
  Get.dialog(
    AlertDialog(
      title: Text('Keluarkan anggota?', style: pBold18),
      content: Text('${member.name} tidak akan lagi melihat grup ini.'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.removeMember(member);
          },
          child: const Text('Keluarkan', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
